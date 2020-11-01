load('../results/storms_info.mat');
storms_info_article = storms_info;
load('../results/storms_info_average4.mat');
storms_info_average4 = storms_info;
clear storms_info
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
    fig_event = figure('Name' , [eventID_s ' - ' char(ds_event) ' - ' char(de_event)], 'units','normalized','outerposition',[0 0 1 1], 'visible','off');

    subplot(4,2, [6 8]);
    title('map');
    u.show_hops_on_map ( storms_info{eventID}.valid_hops_arranged{1} , meta_data, true, false);
    %add_wind_to_plot ( x_min , x_max , y_min , y_max, alpha_wind ,v_wind);
    
    subplot(4,2,[1 3]);     
    title('rssi');
    bias = 0;
    for ii = 1:storms_info{eventID}.active_hops{1}
        hop = char(storms_info{eventID}.valid_hops_arranged{1}(ii));
        hop_ID = meta_data.hop_ID(hop);
        hold on; plot( storms_info{eventID}.valid_time_axis{1}   , storms_info{eventID}.valid_rssi_arranged{1}(: , ii) - bias ,'color' , meta_data.color(hop_ID, :) , 'DisplayName', [num2str(hop_ID) '-' hop]);
        hold on; text( storms_info{eventID}.valid_time_axis{1}(1), storms_info{eventID}.valid_rssi_arranged{1}(1 , ii) - bias  , num2str(hop_ID), 'color' , meta_data.color(hop_ID, :));
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
    
    
%     for k = 1:numel(ims_db.stations)
%         s = char(ims_db.stations(k));
%         ind_period = ims_db.(s).time > ds_event & ims_db.(s).time<de_event;
% 
%         subplot(4,2,5); title('|v|'); xlabel('date and time'); ylabel('|v| m/s');
%         hold on; plot(ims_db.(s).time(ind_period) ,ims_db.(s).wind_speed(ind_period), 'DisplayName', s, 'color' , ims_db.(s).color);
%         %hold on; plot(ims_db.(s).time(ind_period) ,ims_db.(s).speed_of_the_upper_wind(ind_period), '--', 'HandleVisibility','off','color' , ims_db.(s).color);
%         gt_parameters(eventID, 1 , k) = mean(ims_db.(s).wind_speed(ind_period));
%          
%         subplot(4,2,7); title('wind direction'); xlabel('date and time'); ylabel('|v| m/s'); 
%         hold on; plot(ims_db.(s).time(ind_period) ,u.convert_IMS_wind_direction(ims_db.(s).wind_direction(ind_period)) ,'DisplayName', s , 'color' , ims_db.(s).color);
%         %hold on; plot(ims_db.(s).time(ind_period) ,u.convert_IMS_wind_direction(ims_db.(s).direction_of_the_upper_wind(ind_period)), '--', 'HandleVisibility','off', 'color' , ims_db.(s).color);
%         gt_parameters(eventID, 2 , k) = u.convert_IMS_wind_direction(mean(ims_db.(s).wind_direction(ind_period), 'omitnan'));
%         
%         subplot(4,2,[2 4]); title('rain gauges'); xlabel('date and time'); ylabel('R mm/h'); legend('show'); 
%         hold on; plot(ims_db.(s).time(ind_period) ,ims_db.(s).rain(ind_period), 'DisplayName', s, 'color' , ims_db.(s).color);
%     end    
    saveas(fig_event , [dir_name eventID_s '.jpg']);
    disp(['end of ' eventID_s]);

    close all
end
%% 
events_to_check = [2 2 3 7 22 28 42 47 51 51 53 71 82 136 166 175 232 233 236 253];
seqs            = [3 4 3 1 7 2 2 2 3 4 1 1 3 1 1 1 1 2 6 1 ];
dir_name = '..\results\average_4\';

i=0;
for eventID = events_to_check
    eventID_s = ['event' num2str(eventID)];
    disp(eventID_s);
    i = i+1;
    
    rows_event = storms_in_rehovot.eventID == eventID;
    length_of_sequence = sum(rows_event);
    dates = [ storms_in_rehovot.ds(rows_event) , storms_in_rehovot.de(rows_event)];
    
    
    for seq = seqs(i)
        ds = dates(seq,1); de = dates(seq,2);
        
        %std histogram:
%         fig = figure('Name' , [eventID_s ' -- ' char(ds) ' - ' char(de)], 'units','normalized','outerposition',[0 0 1 1]);   
%         histogram( storms_info{eventID}.probes{seq}.std_s, 1:5:500);
%         title(fig.Name);
%         saveas(fig, [dir_name eventID_s '_seq' num2str(seq) '_std_histogram.jpg']);
%         
        %std histogram:
%         fig = figure('Name' , [eventID_s ' -- ' char(ds) ' - ' char(de)], 'units','normalized','outerposition',[0 0 1 1]);   
%         epsilon = 0.01;
%         histogram(storms_info{eventID}.probes{seq}.avg_s./(storms_info{eventID}.probes{seq}.std_s+epsilon), -30:1:30);
%         title(fig.Name);
%         saveas(fig, [dir_name eventID_s '_seq' num2str(seq) '_inv_snr_histogram.jpg']);
%         
        %samples vs avg
        fig = figure('Name' , [eventID_s ' -- ' char(ds) ' - ' char(de)], 'units','normalized','outerposition',[0 0 1 1]);   
        hold on; plot( storms_info{eventID}.probes{seq}.avg_s, '*r');
        hold on; plot( storms_info{eventID}.probes{seq}.avg_samples_mat(:, 3), '*b');
        hold on; plot( storms_info{eventID}.probes{seq}.avg_samples_mat(:, 4), '*b');
        hold on; plot( storms_info{eventID}.probes{seq}.avg_samples_mat(:, 5), '*b');
        hold on; plot( storms_info{eventID}.probes{seq}.avg_samples_mat(:, 6), '*b');
%         storms_info{eventID}.probes{seq}.avg_samples_mat(:, 3:6);
%         z = [storms_info{eventID}.probes{seq}.avg_samples_mat , storms_info{eventID}.probes{seq}.avg_s, storms_info{eventID}.probes{seq}.std_s]; 
        saveas(fig, [dir_name eventID_s '_seq' num2str(seq) '_samples_vs_avg.jpg']);

    end
    disp(['end of ' eventID_s]);

    %close all
end
%% plot rssi on full figure window:
events_to_check = 1; %allevents

dir_name = fullfile('..', 'resutls');

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
        for ii = 1:storms_info{eventID}.active_links{seq}
            hop = char(storms_info{eventID}.valid_hops_arranged{seq}(ii));
            hop_ID = meta_data.hop_ID(hop);
            hold on; plot( storms_info{eventID}.valid_time_axis{seq}   , storms_info{eventID}.valid_rssi_arranged{seq}(: , ii)  - bias ,'color' ,meta_data.color(hop_ID, :), 'DisplayName', [num2str(hop_ID) '-' hop]);
            hold on; text( storms_info{eventID}.valid_time_axis{seq}(1), storms_info{eventID}.valid_rssi_arranged{seq}(1 , ii) - bias  , num2str(hop_ID), 'color' , meta_data.color(hop_ID, :));
            bias = bias+5;
        end
        
        subplot(1,3,[3]);
        title(['map' 'v=' num2str(storms_info{eventID}.v_wind{seq}) 'direction=' num2str(storms_info{eventID}.alpha_wind{seq}) ]);
        u.show_hops_on_map ( storms_info{eventID}.valid_hops_arranged{seq}, meta_data, true,false);

        %saveas(fig_rssi_only , [dir_name eventID_s '_seq' num2str(seq) '_rssi.jpg']);
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

%% extract resilts from structers:
events_to_check = 1:253;
       
duration           = nan(405,1);

v_wind_article     = nan(405,1);
alpha_wind_article = nan(405,1);

v_wind_average4     = nan(405,1);
alpha_wind_average4 = nan(405,1);

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
        duration(counter) = minutes(de-ds);
        
        v_wind_article(counter)     = storms_info_article{eventID}.v_wind{seq};
        alpha_wind_article(counter) = storms_info_article{eventID}.alpha_wind{seq};
        
        v_wind_average4(counter)     = storms_info_average4{eventID}.v_wind{seq};
        alpha_wind_average4(counter) = storms_info_average4{eventID}.alpha_wind{seq};
    end
    disp(['end of ' eventID_s]);
end
%% plot histograms
% map = brewermap(3,'Set1'); 
if(0)
    parametr_list = {v_wind_article , v_wind_average4};
    name = 'wind speed';
    th_for_clipping = 200;
    th_for_histogram = 50;
    y_lim = 20;
else
    parametr_list = {alpha_wind_article, alpha_wind_average4};
    name = 'wind direction';
    th_for_clipping = 360;
    th_for_histogram = 360;
    y_lim = 7;
end
colors = {'r', 'g'};
description = {'article', 'average4'};
figure;
for i = 1:length(parametr_list)
    subplot(1,2,i);
    histogram(parametr_list{i},0:0.5:th_for_histogram,'facecolor',colors{i},'facealpha',.5,'edgecolor','none');
    
    title([name ' histogram']);
    xlabel(name);
    ylabel('amount of events');
    box off;
    axis tight;
    legend(description{i}, 'location', 'northeast');
    legend boxoff;
    ylim([0,y_lim]);
end
saveas(gcf, ['../results/hist_articel_Vs_average4_' name '.jpg']);
figure;
scatter(parametr_list{1}, parametr_list{2}, '*');
hold on;
plot([1, th_for_clipping], [1, th_for_clipping]);
xlim([0, th_for_clipping]);
ylim([0, th_for_clipping]);
title('scatter plot');
xlabel('article');
ylabel('average4');
saveas(gcf, ['../results/scatter_articel_Vs_average4_' name '.jpg']);

