%% plot rssi on full figure window:
events_to_check = 28; seq = 2;
%events_to_check = 42; seq = 2;

    
dir_name = 'C:\Users\mhadar\Documents\personal\thesis_materials\graphs_and_figures\all_hops_all_events\good_events\';
str_name = '';
for eventID = events_to_check
    eventID_s = ['event' num2str(eventID)];
    disp(eventID_s);
    
    rows_event = storms_in_rehovot.eventID == eventID;
    length_of_sequence = sum(rows_event);
    dates = [ storms_in_rehovot.ds(rows_event) , storms_in_rehovot.de(rows_event)];
    

    ds = dates(seq,1); de = dates(seq,2);

    fig_rssi_only_28 = figure('Name' , [eventID_s ' rssi - ' char(ds) ' - ' char(de)], 'units','normalized','outerposition',[0 0 1 1]);
    subplot(1,3,[1 2]);
    title('RSL');
    bias = 0;
    for ii = 1:storms_info{eventID}.active_hops{seq}
        hop = char(storms_info{eventID}.valid_hops_arranged{seq}(ii));
        hop_ID = meta_data.hop_ID(hop);
        hold on; plot( storms_info{eventID}.valid_time_axis{seq}   , storms_info{eventID}.valid_rssi_arranged{seq}(: , ii)  - bias ,'color' , map_color_by_hop(hop_ID,: ) , 'DisplayName', [num2str(hop_ID) '-' hop]);
        hold on; text( storms_info{eventID}.valid_time_axis{seq}(1), storms_info{eventID}.valid_rssi_arranged{seq}(1 , ii) - bias  , num2str(hop_ID), 'color' , map_color_by_hop(hop_ID,: ));
        bias = bias+5;
    end

    subplot(1,3,[3]);
    show_hops_on_map ( storms_info{eventID}.valid_hops_arranged{seq} , meta_data, map_color_by_hop, false,true);

    disp(['end of ' eventID_s]);
end
subplot(1,3,[1 2]);
title('RSL measurements during storm event');
xlabel('Date');
ylabel('RSL (relative units)');

subplot(1,3,[3]);
title('Map - Active hops during event');
xlabel('Eastings UTM');
ylabel('Northings UTM')

saveas(fig_rssi_only_28 , [dir_name eventID_s '_seq' num2str(seq) str_name '.jpg']);
saveas(fig_rssi_only_28 , [dir_name eventID_s '_seq' num2str(seq) str_name]);

disp(['v =' num2str(storms_info{eventID}.v_wind{seq}) '(' eventID_s ')']);
disp(['theta =' num2str(storms_info{eventID}.alpha_wind{seq}) '(' eventID_s ')']);
disp(['streght =' num2str(storms_info{eventID}.storm_strength{seq}) '(' eventID_s ')']);

% clear events_to_check eventID eventID_s rows_event length_of_sequence dates fig_rssi_only bias seq
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% pie
M= meta_data;
M([37 38],:) = [];
L = M.length;
figure; pie((M.length))
dir_name = 'C:\Users\mhadar\Documents\personal\thesis_materials\graphs_and_figures\all_hops_all_events\good_events\';
str_name = '_length_hist';

h = histogram(L, 0:0.1:3);
title("Hops' length distributaion");
xlabel("Length [km]");
ylabel('Count');
saveas(gcf , [dir_name str_name '.jpg']);
precent_under_400m = sum(h.Values(1:4))/sum(h.Values);
x = [h.Values(1:10) sum(h.Values(11:end))];
labels = {'0-100m','100-200m','200-300m' , '300-400m', '400-500m', '500-600m', '600-700m', '700-800m', '800-900m' , '900-1000m', '>1km'};
figure; pie(x,labels);
str_name = '_pie2';
saveas(gcf , [dir_name str_name '.jpg']);

% histogrma:
%% 
dir_name = 'C:\Users\mhadar\Documents\personal\thesis_materials\graphs_and_figures\all_hops_all_events\good_events\';
str_name = '_hist';
saveas(gcf ,[dir_name str_name '.jpg'] )

%% theta_naive:
%event 28: 
x1 = meta_data.x_center(meta_data.hop_ID == 5);
y1 = meta_data.y_center(meta_data.hop_ID == 5);
x2 = meta_data.x_center(meta_data.hop_ID == 18);
y2 = meta_data.y_center(meta_data.hop_ID == 18);
delta_x = abs(x1-x2);
delta_y = abs(y1-y2);
a = atand(delta_y/delta_x);
%a = atand(delta_x/delta_y);
theta_naive = 180+ 180 -a

%event 42:
x1 = meta_data.x_center(meta_data.hop_ID == 30);
y1 = meta_data.y_center(meta_data.hop_ID == 30);
x2 = meta_data.x_center(meta_data.hop_ID == 18);
y2 = meta_data.y_center(meta_data.hop_ID == 18);
delta_x = abs(x1-x2);
delta_y = abs(y1-y2);
a = atand(delta_y/delta_x);
theta_naive = 180 +180 -a