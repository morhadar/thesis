%%
storms_info   = cell(253,1);
%% run full algorithm for all rain events:
events_to_check = 1:253; %total event is 253.
mode = 'average_4';

v_wind0 = 20;
alpha_wind0 = 360;
lb = [0,0];
ub = [200,360];

%%% get a list of desired hops where list is sorted according to hop ID:
hops_in_total = pick_hops(meta_data , 0.01);
[distanceG, phiG] = calc_phi_and_distance_for_each_pair_of_hops(hops_in_total, meta_data);

%%% Exclude links with missing georpahical meta-data. TODO:get mate-data.
hops_in_total(strcmp(hops_in_total , 'muni_katzirnew')) = [];
hops_in_total(strcmp(hops_in_total , 'katzirnew_katzirtichon')) = [];

%%% Exclude one crazy hop (was disturbed by a tree)
% hops_in_total(strcmp(hops_in_total , 'junc11_junc10')) = []; %TODO: consider if to exclude it 

for eventID = events_to_check %42 %28
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
        [rssi, hops_ID_orig, link_ID] = extract_rssi(hops, db, ds, de, meta_data, true, true);
        [hops_ID, tau, distance, phi] = calc_xcorr_between_specific_links(rssi, hops_ID_orig, meta_data, distanceG, phiG, mode);
        
        %%% LS (x - is the parameter to estimate)
        weight = 1; %weight = 1./(meta_data.length(valid_hops) * meta_data.length(valid_hops)');
        residual = @(x) weight(:).*(tau - (distance/x(1)) .* cosd(phi - x(2)));
        x = lsqnonlin(residual,[v_wind0 alpha_wind0]);
        %x = lsqnonlin(residual,[v_wind0 alpha_wind0], lb ,ub); %TODO: try to bound optimization

        storms_info{eventID}.v_wind{seq} = x(1);  
        storms_info{eventID}.alpha_wind{seq} = wrapTo360(x(2)); 
        
        %%% sort hops by geographical location given the estimated wind direction 
        [~, sort_index] = sort_hops_by_geographic_location(hops_ID, meta_data, storms_info{eventID}.alpha_wind{seq});
        hops_ID = hops_ID(sort_index); %TODO - make sure this is still true even after excluding links)
        rssi = rssi(:,sort_index);
        
        %%% save output
        storms_info{eventID}.rssi{seq}          = rssi;
        storms_info{eventID}.hops{seq}          = u.hop_ID2name(hops_ID, meta_data);
        storms_info{eventID}.active_links{seq}   = length(hops_ID);
        storms_info{eventID}.storm_strength{seq}= max(max(rssi));        
    end
    disp(['end of ' eventID_s]);
end

save('storms_info_average4.mat' , 'storms_info');
clear k map s ind_period

%% print storm_info to table
events_to_print = 1:253;
T = table( 0, datetime, datetime, 0, 0, 0, 0, 0) ;
T.Properties.VariableNames = {'eventID' , 'start_time', 'end_time' , 'duration' , 'active_links' , 'v' , 'direction', 'storm_strength'};
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
        T{ii, 'active_links'} = storms_info{eventID}.active_links{1};
        T{ii, 'v'} = storms_info{eventID}.v_wind{seq};
        T{ii , 'direction'} = storms_info{eventID}.alpha_wind{seq};
        if (isempty(storms_info{eventID}.storm_strength{seq}))
             T{ii , 'storm_strength'} = -1;
        else
             T{ii , 'storm_strength'} = storms_info{eventID}.storm_strength{seq};
        end
    end
end
