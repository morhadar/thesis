
%% run full algorithm for all rain events:
% this is true for pick_rain_event1:
events_to_check = 129; %april 21
events_to_check = 131; %no rain
events_to_check = 1:131; 

events_to_check(events_to_check==9) = [];%TODO - debug why failing for tho
events_to_check(events_to_check==10) = [];%TODO - debug why failing for tho
events_to_check(events_to_check==11) = [];%TODO - debug why failing for tho
events_to_check(events_to_check==12) = [];%TODO - debug why failing for tho
events_to_check(events_to_check==13) = [];%TODO - debug why failing for tho
events_to_check(events_to_check==14) = [];%TODO - debug why failing for tho
events_to_check(events_to_check==15) = [];%TODO - debug why failing for tho
events_to_check(events_to_check==52) = [];%TODO - debug why failing for tho
events_to_check(events_to_check==79) = [];%TODO - debug why failing for tho
events_to_check(events_to_check==86) = [];%TODO - debug why failing for tho
events_to_check(events_to_check==112) = [];%TODO - debug why failing for tho


% events_to_check = 1:10;
n_events = length(events_to_check);

alpha_wind = nan(length(events_to_check), 1);
v_wind     = nan(length(events_to_check), 1);
gt_parameters = nan(length(events_to_check), 2, 4);

hops = pick_hops(4.2);
hops(strcmp(hops , 'muni_katzirnew')) = []; %TODO - tmp until I will have all cordinates
hops(strcmp(hops , 'katzirnew_katzirtichon')) = []; %TODO - tmp until I will have all cordinates

dir_name = 'C:\Users\mhadar\Documents\personal\thesis_materials\graphs_and_figures\herztel_street\';

% events_info=struct('eventID',[], 'ds',[], 'de',[],'duration' , [], 'new_hops' , [], ...
%                     'tau', [], 'v', [],'direction',[], 'hops_arranged', []...
%                     );
for i = 1:n_events
    eventID = events_to_check(i);
    eventID_s = ['event' num2str(eventID)];
    disp(eventID_s);
    
    [ds ,de] = pick_rain_event(eventID);
    
    [valid_hops , tau , valid_rssi , valid_time_axis] = calc_xcorr_between_hops(hops, db, ds, de ,meta_data);
    [distance, phi] = calc_phi_and_distance_for_each_pair_of_hops( valid_hops, meta_data);
    
    % MLE (x - is the parameter to estimate)
    weight = 1./(meta_data.length(valid_hops) * meta_data.length(valid_hops)');
    residual = @(x) weight(:).*(tau(:) - (distance(:)/x(1)) .* cosd(phi(:) - x(2))); %TODO how is it possible to get the same results when it was 'sind' instead of 'cosd'
%     residual = @(x) tau(:) - (distance(:)/x(1)) .* cosd(phi(:) - x(2)); %TODO how is it possible to get the same results when it was 'sind' instead of 'cosd'
    v_wind0 = 20;
    alpha_wind0 = 360;
    start = [v_wind0 alpha_wind0];
    x = lsqnonlin(residual,start);
    v_wind(i) = x(1); 
    alpha_wind(i) = wrapTo360(x(2)); 
    % WLS (x - is the input)
%     x = [distance(:) ,phi(:)];
%     modelFun = @(b,x) (x(1)./b(1)).*cosd(x(2)-b(2));
%     nlm = fitnlm(x, tau(:),modelFun,start);
    
    [~ , valid_hops_arranged, sort_index] = calc_effective_distance_and_sort_hops(valid_hops , meta_data , alpha_wind(i), true);

    %present result
    fig_event = figure('Name' , [eventID_s ' - ' char(ds) ' - ' char(de)], 'units','normalized','outerposition',[0 0 1 1], 'visible','off');

    subplot(4,2, [5 7]);
    u.show_hops_on_map (valid_hops_arranged, meta_data, true);
    %add_wind_to_plot ( x_min , x_max , y_min , y_max, alpha_wind ,v_wind); %TODO  - solve it
    title(['v = ' num2str(v_wind(i)) 'm/s' ' , ' 'direction = ' num2str(alpha_wind(i))]);
   
    subplot(4,2,[1 3]); 
    title('rssi');
    map_hops = distinguishable_colors(length(valid_hops_arranged), {'w','k'}); %TODO - distinguishable FIX! colors
    bias = 0;
    for ii = 1:length(valid_hops_arranged)
        hop = char(valid_hops_arranged(ii));
        hold on; plot( valid_time_axis , valid_rssi(: , ii) - bias ,'color' , map_hops(ii,: ) , 'DisplayName', hop);
        hold on; text( valid_time_axis(1), valid_rssi(20 , ii) - bias, num2str(ii), 'color' , map_hops(ii,: ));
        bias = bias+1;
    end
    
    for k = 1:numel(ims_db.stations)
        s = char(ims_db.stations(k));
        ind_period = ims_db.(s).time > ds & ims_db.(s).time<de;

%         subplot(4,2,6); title('|v|'); xlabel('date and time'); ylabel('|v| m/s'); legend('show'); 
%         hold on; plot(ims_db.(s).time(ind_period) ,ims_db.(s).wind_speed(ind_period), 'DisplayName', s, 'color', ims_db.(s).color);
%         hold on; plot(ims_db.(s).time(ind_period) ,ims_db.(s).speed_of_the_upper_wind(ind_period), '--', 'HandleVisibility', 'off', 'color', ims_db.(s).color);
         gt_parameters(i , 1 , k) = mean(ims_db.(s).speed_of_the_upper_wind(ind_period));
%         
%         subplot(4,2,8); title('wind direction'); xlabel('date and time'); ylabel('|v| m/s'); 
%         hold on; plot(ims_db.(s).time(ind_period) ,convert_IMS_wind_direction(ims_db.(s).wind_direction(ind_period)) ,'DisplayName', s , 'color', ims_db.(s).color);
%         hold on; plot(ims_db.(s).time(ind_period) ,convert_IMS_wind_direction(ims_db.(s).direction_of_the_upper_wind(ind_period)), '--', 'HandleVisibility','off', 'color', ims_db.(s).color);
         gt_parameters(i , 2 , k) = convert_IMS_wind_direction(mean(ims_db.(s).direction_of_the_upper_wind(ind_period), 'omitnan'));
        
        subplot(4,2,[2 4]); title('rain gauges'); xlabel('date and time'); ylabel('R mm/h'); legend('show'); 
        hold on; plot(ims_db.(s).time(ind_period) ,ims_db.(s).rain(ind_period), 'DisplayName', s, 'color', ims_db.(s).color);
    end
%     subplot(4,2,6);
%     hold on; plot( ds:seconds(30):de, (estimated_parameters(i , 1)  * ones(size(ds:seconds(30):de))) , 'DisplayName', '|v|',  'color' , 'm');
%     legend('show');
% 
%     subplot(4,2,8);
%     hold on; plot( ds:seconds(30):de, (estimated_parameters(i , 2)  * ones(size(ds:seconds(30):de))) , 'DisplayName', 'alpha',  'color' , 'm'); 
%     legend('show');
    
    saveas(gcf , [dir_name eventID_s '.jpg']);

    %save results in struct:
    events_info(i).eventID = eventID;
    events_info(i).ds = ds;
    events_info(i).de = de;
    events_info(i).duration = hours(de-ds);
    events_info(i).new_hops = valid_hops;
    events_info(i).tau = tau;
    events_info(i).v = v_wind(i);
    events_info(i).hops_arranged = valid_hops_arranged;
    events_info(i).direction = alpha_wind(i);
%     events_info(i_event).gt_v = 
%     events_info(i_event).gt_direction = 
    
end
figure('Name' , 'scatter plot', 'units','normalized','outerposition',[0 0 1 1]); 
subplot(1,2,1); 
title('|v|'); 
xlabel('gt'); 
ylabel('estimated |v| m/s');
hold on; scatter( mean( gt_parameters(: , 1 , :) ,3, 'omitnan') , v_wind(:) );
v_max = max(v_wind);
%hold on; plot(mean( gt_parameters(: , 1 , :) ,3, 'omitnan') , v_wind0*ones(1, n_events));
hold on; plot( 1:v_max , 1:v_max);
ylim([0 v_max]); xlim([0 v_max]);

subplot(1,2,2); 
title('wind direction'); 
xlabel('gt'); 
ylabel('estimated alpha m/s');
hold on; scatter( mean( gt_parameters(: , 2 , :),3, 'omitnan') , alpha_wind(:) );
%hold on; plot(mean( gt_parameters(: , 2 , :) ,3, 'omitnan') , alpha_wind0*ones(1, n_events) );
hold on; plot( 1:360 , 1:360);
ylim([0 360]); xlim([0 360]);
saveas(gcf , [dir_name 'scatter.jpg']);

clear fn k map s ind_period

%% print event info!
T = struct2table(events_info);
for i= 1:height(T)
    T{i,10} = length(T{i,5}{1});
end
T1 = T(:,[1 2 3 4 7 8 10]);
