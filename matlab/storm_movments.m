%%
storms_info   = cell(253,1);
gt_parameters = nan( 253 ,2 , 4);
%%
%load('storms_info_normalized.mat');
%storms_info = storms_info_normalized;

load('storms_info.mat');

%% run full algorithm for all rain events:
events_to_check = [28 42]; %allevents

v_wind0 = 20;
alpha_wind0 = 360;
lb = [0,0];
ub = [200,360];

hops_in_total = pick_hops(meta_data , 0);
hops_in_total(strcmp(hops_in_total , 'muni_katzirnew')) = []; %TODO - tmp until I will have all cordinates
hops_in_total(strcmp(hops_in_total , 'katzirnew_katzirtichon')) = []; %TODO - tmp until I will have all cordinates

for eventID = events_to_check
    eventID_s = ['event' num2str(eventID)];
    disp(eventID_s);
    
    rows_event = storms_in_rehovot.eventID == eventID;
    length_of_sequence = sum(rows_event);
    dates = [ storms_in_rehovot.ds(rows_event) , storms_in_rehovot.de(rows_event)];
    ds_event = dates(1,1); de_event = dates(1,2);
    exclude_hops = storms_in_rehovot.exclude_hops(rows_event);

    for seq = 1:length_of_sequence
        ds = dates(seq,1); de = dates(seq,2);
        
        hops = hops_in_total;
        [~,ia,~] = intersect(hops,exclude_hops{seq}, 'stable');
        hops(ia) = [];
    
        [valid_hops , tau , valid_rssi , valid_time_axis] = calc_xcorr_between_hops(hops, db, ds, de ,meta_data);
        [distance, phi] = calc_phi_and_distance_for_each_pair_of_hops( valid_hops, meta_data);

        % MLE (x - is the parameter to estimate)
        %weight = 1./(meta_data.length(valid_hops) * meta_data.length(valid_hops)');
        weight = 1;
        residual = @(x) weight(:).*(tau(:) - (distance(:)/x(1)) .* cosd(phi(:) - x(2)));

        x = lsqnonlin(residual,[v_wind0 alpha_wind0]);
        %x = lsqnonlin(residual,[v_wind0 alpha_wind0], lb ,ub);

        storms_info{eventID}.v_wind{seq} = x(1);  
        storms_info{eventID}.alpha_wind{seq} = wrapTo360(x(2)); 
        
        [~ , valid_hops_arranged, sort_index] = calc_effective_distance_and_sort_hops(valid_hops , meta_data , storms_info{eventID}.alpha_wind{seq}, true);

        storms_info{eventID}.valid_rssi_arranged{seq} = valid_rssi(: , sort_index);
        storms_info{eventID}.valid_hops_arranged{seq} = valid_hops_arranged;
        storms_info{eventID}.active_hops{seq} = length(storms_info{eventID}.valid_hops_arranged{seq});
        storms_info{eventID}.valid_time_axis{seq} = valid_time_axis;
        storms_info{eventID}.storm_strength{seq} = max(max(storms_info{eventID}.valid_rssi_arranged{seq}));
        
    end
    disp(['end of ' eventID_s]);
end

%save('storms_info.mat' , 'storms_info');
clear k map s ind_period

%% print storm_info to table
events_to_print = 1:253;
T = table( 0 , datetime , datetime , 0 ,0,0 ,0, 0,0) ;
T.Properties.VariableNames = {'eventID' , 'start_time', 'end_time' , 'duration' , 'active_hops' , 'v' , 'direction', 'storm_strength','valid_rows'};
ii = 0;
for eventID = events_to_print
    disp(eventID);
    
    rows_event = storms_in_rehovot.eventID == eventID;
    length_of_sequence = sum(rows_event);
    dates = [ storms_in_rehovot.ds(rows_event) , storms_in_rehovot.de(rows_event)];
    
    for seq = 1:length_of_sequence
        ii = ii+1;
        ds = dates(seq,1); de = dates(seq,2);
        T{ii , 'eventID'} =  eventID;
        T{ii , 'start_time'} = ds;
        T{ii , 'end_time'} = de;
        T{ii, 'duration'} = hours(de-ds);
        T{ii, 'active_hops'} = storms_info{eventID}.active_hops{1};
        T{ii, 'v'} = storms_info{eventID}.v_wind{seq};
        T{ii , 'direction'} = storms_info{eventID}.alpha_wind{seq};
        if (isempty(storms_info{eventID}.storm_strength{seq}))
             T{ii , 'storm_strength'} = -1;
        else
             T{ii , 'storm_strength'} = storms_info{eventID}.storm_strength{seq};
        end
        %T{ii , 'valid_rows'} = storms_info{eventID}.valid_rows_precentage{seq};
        T{ii , 'valid_rows'} = sum(storms_info{eventID}.valid_rows_precentage{seq} ~=0)/length(storms_info{eventID}.valid_rows_precentage{seq});

    end
end
%% print result per event and not per sequence:
events_to_check = 1:253; %allevents

dir_name = 'C:\Users\mhadar\Documents\personal\thesis_materials\graphs_and_figures\all_hops_all_events\';

for eventID = events_to_check
    eventID_s = ['event' num2str(eventID)];
    disp(eventID_s);
    
    rows_event = storms_in_rehovot.eventID == eventID;
    length_of_sequence = sum(rows_event);
    dates = [ storms_in_rehovot.ds(rows_event) , storms_in_rehovot.de(rows_event)];
    ds_event = dates(1,1); de_event = dates(1,2);
    
    %present result
    fig_event = figure('Name' , [eventID_s ' - ' char(ds) ' - ' char(de)], 'units','normalized','outerposition',[0 0 1 1], 'visible','off');

    subplot(4,2, [6 8]);
    title('map');
    show_hops_on_map ( storms_info{eventID}.valid_hops_arranged{1} , meta_data, map_color_by_hop, true, false);
    %add_wind_to_plot ( x_min , x_max , y_min , y_max, alpha_wind ,v_wind); %TODO  - solve it
    
    subplot(4,2,[1 3]);     
    title('rssi');
    bias = 0;
    for ii = 1:storms_info{eventID}.active_hops{1}
        hop = char(storms_info{eventID}.valid_hops_arranged{1}(ii));
        hop_ID = meta_data.hop_ID(hop);
        hold on; plot( storms_info{eventID}.valid_time_axis{1}   , storms_info{eventID}.valid_rssi_arranged{1}(: , ii)  - bias ,'color' , map_color_by_hop(hop_ID,: ) , 'DisplayName', [num2str(hop_ID) '-' hop]);
        hold on; text( storms_info{eventID}.valid_time_axis{1}(1), storms_info{eventID}.valid_rssi_arranged{1}(1 , ii) - bias  , num2str(hop_ID), 'color' , map_color_by_hop(hop_ID,: ));
        bias = bias+2;
    end
    xlim([ds_event de_event]);
    
    min_rssi = min(min(storms_info{eventID}.valid_rssi_arranged{1}));
    max_rssi = max(max(storms_info{eventID}.valid_rssi_arranged{1}));
    for seq = 1:length_of_sequence
        ds = dates(seq,1); de = dates(seq,2);
        subplot(4,2,[5]); 
        title('|v|');
        hold on;
        plot( ds:seconds(30):de , storms_info{eventID}.v_wind{seq} * ones(size(ds:seconds(30):de)) , 'k');
        hold off;
       
        subplot(4,2,[7]);
        title('direction');
        hold on;
        plot( ds:seconds(30):de , storms_info{eventID}.alpha_wind{seq} * ones(size(ds:seconds(30):de)) , 'k');
        hold off;

        subplot(4,2,[1 3]);
        hold on;
%         xline(ds, '-' , {'seq1'});
%         xline(de, '-' , {'seq1'});
        plot([ds ds],[min_rssi max_rssi], 'k');
        hold off;
    end
    
    
%     for k=1:numel(stations)
%         s = char(stations(k));
%         ind_period = ims_db.(s).time > ds_event & ims_db.(s).time<de_event;
% 
%         subplot(4,2,5); title('|v|'); xlabel('date and time'); ylabel('|v| m/s');
%         hold on; plot(ims_db.(s).time(ind_period) ,ims_db.(s).wind_speed(ind_period), 'DisplayName', s, 'color' , map_color_by_station(k,:));
%         %hold on; plot(ims_db.(s).time(ind_period) ,ims_db.(s).speed_of_the_upper_wind(ind_period), '--', 'HandleVisibility','off','color' , map_color_by_station(k,:));
%         gt_parameters(eventID, 1 , k) = mean(ims_db.(s).wind_speed(ind_period));
%          
%         subplot(4,2,7); title('wind direction'); xlabel('date and time'); ylabel('|v| m/s'); 
%         hold on; plot(ims_db.(s).time(ind_period) ,convert_IMS_wind_direction(ims_db.(s).wind_direction(ind_period)) ,'DisplayName', s , 'color' , map_color_by_station(k,:));
%         %hold on; plot(ims_db.(s).time(ind_period) ,convert_IMS_wind_direction(ims_db.(s).direction_of_the_upper_wind(ind_period)), '--', 'HandleVisibility','off', 'color' , map_color_by_station(k,:));
%         gt_parameters(eventID, 2 , k) = convert_IMS_wind_direction(mean(ims_db.(s).wind_direction(ind_period), 'omitnan'));
%         
%         subplot(4,2,[2 4]); title('rain gauges'); xlabel('date and time'); ylabel('R mm/h'); legend('show'); 
%         hold on; plot(ims_db.(s).time(ind_period) ,ims_db.(s).rain(ind_period), 'DisplayName', s, 'color' , map_color_by_station(k,:));
%     end    
    saveas(fig_event , [dir_name eventID_s '.jpg']);
    disp(['end of ' eventID_s]);

    close all
end

%% plot rssi on full figure window:
events_to_check = 42; %allevents

dir_name = 'C:\Users\mhadar\Documents\personal\thesis_materials\graphs_and_figures\all_hops_all_events\rssi_sequences\';

for eventID = events_to_check
    eventID_s = ['event' num2str(eventID)];
    disp(eventID_s);
    
    rows_event = storms_in_rehovot.eventID == eventID;
    length_of_sequence = sum(rows_event);
    dates = [ storms_in_rehovot.ds(rows_event) , storms_in_rehovot.de(rows_event)];
    
    for seq = 1:length_of_sequence
        ds = dates(seq,1); de = dates(seq,2);
        
        fig_rssi_only = figure('Name' , [eventID_s ' rssi - ' char(ds) ' - ' char(de)], 'units','normalized','outerposition',[0 0 1 1]);
        subplot(1,3,[1 2]);
        title('rssi');
        bias = 0;
        for ii = 1:storms_info{eventID}.active_hops{seq}
            hop = char(storms_info{eventID}.valid_hops_arranged{seq}(ii));
            hop_ID = meta_data.hop_ID(hop);
            hold on; plot( storms_info{eventID}.valid_time_axis{seq}   , storms_info{eventID}.valid_rssi_arranged{seq}(: , ii)  - bias ,'color' , map_color_by_hop(hop_ID,: ) , 'DisplayName', [num2str(hop_ID) '-' hop]);
            hold on; text( storms_info{eventID}.valid_time_axis{seq}(1), storms_info{eventID}.valid_rssi_arranged{seq}(1 , ii) - bias  , num2str(hop_ID), 'color' , map_color_by_hop(hop_ID,: ));
            bias = bias+5;
        end
        
        subplot(1,3,[3]);
        title(['map' 'v=' num2str(storms_info{eventID}.v_wind{seq}) 'direction=' num2str(storms_info{eventID}.alpha_wind{seq}) ]);
        show_hops_on_map ( storms_info{eventID}.valid_hops_arranged{seq} , meta_data, map_color_by_hop, true,false);

        saveas(fig_rssi_only , [dir_name eventID_s '_seq' num2str(seq) '_rssi.jpg']);
    end
    disp(['end of ' eventID_s]);

    %close all
end
clear events_to_check  dir_name eventID eventID_s rows_event length_of_sequence dates fig_rssi_only bias seq
%% analysis:
events_to_check = 1:253;
       
dir_name = 'C:\Users\mhadar\Documents\personal\thesis_materials\graphs_and_figures\all_hops_all_events\';
f_v_vs_date = figure('Name' ,'parameters_vs_date', 'units','normalized','outerposition',[0 0 1 1]);
f_v_vs_storm_strength = figure('Name' ,'parametrs_vs_length', 'units','normalized','outerposition',[0 0 1 1]);
storms_info_for_presentation1 = storms_info_normalized;

counter = 0;
for eventID = events_to_check
    eventID_s = ['event' num2str(eventID)];
    disp(eventID_s);
    
    rows_event = storms_in_rehovot.eventID == eventID;
    length_of_sequence = sum(rows_event);
    dates = [ storms_in_rehovot.ds(rows_event) , storms_in_rehovot.de(rows_event)];
    if( length_of_sequence>1)
        starting_sequence =2;
    else
        starting_sequence = 1;
    end
    for seq = starting_sequence:length_of_sequence
        counter = counter+1;
        
        storm_strength = storms_info_for_presentation1{eventID}.storm_strength{seq};
        if( storm_strength < 20); continue; end
        figure(f_v_vs_storm_strength);
        subplot(2,1,1); title('v'); ylabel('|v| m/s'); xlabel('storm strength');
        hold on; plot( storm_strength , storms_info_for_presentation1{eventID}.v_wind{seq}, '*b', 'MarkerSize' , 3 );
        subplot(2,1,2); title('direction'); ylabel('degree'); xlabel('storm strength');
        hold on; plot( storm_strength , storms_info_for_presentation1{eventID}.alpha_wind{seq}, '*b' ,'MarkerSize' , 3 );
       
        
        ds = dates(seq,1);
        figure(f_v_vs_date);
        subplot(2,1,1); title('v'); ylabel('|v| m/s'); xlabel('time');
        hold on; plot( ds , storms_info_for_presentation1{eventID}.v_wind{seq}, '*b' , 'MarkerSize' , 3 );
        subplot(2,1,2); title('direction'); ylabel('degree'); xlabel('time');
        hold on; plot( ds , storms_info_for_presentation1{eventID}.alpha_wind{seq}, '*b' , 'MarkerSize' , 3 );
        
 
    end
    disp(['end of ' eventID_s]);
end
% saveas(f_v_vs_date , [dir_name f_v_vs_date.Name '.jpg']);

%% 
events_to_check = 1:253;
       
dir_name = 'C:\Users\mhadar\Documents\personal\thesis_materials\graphs_and_figures\all_hops_all_events\';
f_hist = figure('Name' ,'histogram', 'units','normalized','outerposition',[0 0 1 1]);
storms_info_for_presentation1 = storms_info;
v_wind     = nan(405,1);
alpha_wind = nan(405,1);
duration   = nan(405,1);
counter = 0;
for eventID = events_to_check
    eventID_s = ['event' num2str(eventID)];
    disp(eventID_s);
    
    rows_event = storms_in_rehovot.eventID == eventID;
    length_of_sequence = sum(rows_event);
    dates = [ storms_in_rehovot.ds(rows_event) , storms_in_rehovot.de(rows_event)];
    if( length_of_sequence>1)
        starting_sequence =2;
    else
        starting_sequence = 1;
    end
    for seq = starting_sequence:length_of_sequence
        ds = dates(seq,1); de = dates(seq,2);
        counter = counter+1;     
        v_wind(counter)     = storms_info_for_presentation1{eventID}.v_wind{seq};
        alpha_wind(counter) = storms_info_for_presentation1{eventID}.alpha_wind{seq};
        duration(counter) = minutes(de-ds);
    end
    disp(['end of ' eventID_s]);
end
% figure;
% histogram(v_wind, 0:100);

% figure; 
% histogram(alpha_wind, 0:360)

figure; 
histogram(duration, 0:1:1000)
