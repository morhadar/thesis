%%
storms_info   = cell(253,1);
%% run full algorithm for all rain events:
events_to_check = 1:253; %total event is 253.
%options for mode= 
%'all_links' - calculate tau between each pair of link
%'all_links_avg' - calcualte tau between each pair of link and then avg between similar pairs.
%'independent_links' - take M-1 measurements between a pivot and all other links
%'independent_linksM' - take M measurments between circular links
%'all_hops' - pick randomaly one link out of two links combining a hop and then tau between all posible pairs.
%super_mode - 'all_links_avg' + 'independent_linksM' - avg meaurements and then take M circular link
mode = 'super_mode';

v_wind0 = 20;
alpha_wind0 = 360;
lb = [0,0];
ub = [200,360];

%%% get a list of desiered hops where list is sorted according to hop ID:
hops_in_total = pick_hops(meta_data , 0.01);
[distanceG, phiG] = calc_phi_and_distance_for_each_pair_of_hops(hops_in_total, meta_data);

%%% Exclude of links with missing georpahical meta-data. TODO:get mate-data.
hops_in_total(strcmp(hops_in_total , 'muni_katzirnew')) = [];
hops_in_total(strcmp(hops_in_total , 'katzirnew_katzirtichon')) = [];

%%% Exclude one crazy hop (was disturbed by a tree)
% hops_in_total(strcmp(hops_in_total , 'junc11_junc10')) = []; %TODO: think if to exclude it 

for eventID = events_to_check
    eventID_s = ['event' num2str(eventID)];
    disp(eventID_s);
    
    %%% get event's date-time info:
    rows_event = storms_in_rehovot.eventID == eventID;
    N_sequences = sum(rows_event);
    dates = [storms_in_rehovot.ds(rows_event), storms_in_rehovot.de(rows_event)];
    ds_event = dates(1,1); de_event = dates(1,2);
    exclude_hops = storms_in_rehovot.exclude_hops(rows_event); %TODO exclude only single link out of the hop

    for seq = 1:N_sequences
        ds = dates(seq,1); de = dates(seq,2);
        
        hops = hops_in_total;
        
        %%% exclude noisy/broken/mulfunctioning hops specific to this event
        [~,ia,~] = intersect(hops, exclude_hops{seq}, 'stable');
        hops(ia) = [];
        
        %%% extract rssi of required hops and intepolated for missing values.
        %%% In addition normalize by reducing link's baseline and by division in link's length.
        %%% In addition reduce rssi avg within specific time frame  
        [rssi, hops_ID] = extract_rssi(hops, db, ds, de, meta_data, true, true);
        [rssi, hops_ID, tau, distance, phi] = calc_xcorr_between_specific_links(rssi, hops_ID, meta_data, distanceG, phiG, mode);
        
        %%% LS (x - is the parameter to estimate)
        weight = 1; %weight = 1./(meta_data.length(valid_hops) * meta_data.length(valid_hops)');
        residual = @(x) weight(:).*(tau - (distance/x(1)) .* cosd(phi - x(2)));
        x = lsqnonlin(residual,[v_wind0 alpha_wind0]);
        %x = lsqnonlin(residual,[v_wind0 alpha_wind0], lb ,ub); %TODO: try to bound optimization

        storms_info{eventID}.v_wind{seq} = x(1);  
        storms_info{eventID}.alpha_wind{seq} = wrapTo360(x(2)); 
        
        %%% sort hops by geographical location given the estimated wind direction 
        [~, sort_index] = sort_hops_by_geographic_location(hops_ID, meta_data, storms_info{eventID}.alpha_wind{seq});
        hops_ID = hops_ID(sort_index);
        rssi = rssi(:,sort_index);
        
        %%% save output
        storms_info{eventID}.rssi{seq}          = rssi;
        storms_info{eventID}.hops{seq}          = u.hop_ID2name(hops_ID, meta_data);
        storms_info{eventID}.active_links{seq}   = length(hops_ID);
        storms_info{eventID}.storm_strength{seq}= max(max(rssi));        
    end
    disp(['end of ' eventID_s]);
end

%save('storms_info_independent_linksM.mat' , 'storms_info');
clear k map s ind_period