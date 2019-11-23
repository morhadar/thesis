%%
storms_info   = cell(253,1);
%% run full algorithm for all rain events:
events_to_check = 1:253; %allevents

v_wind0 = 20;
alpha_wind0 = 360;
lb = [0,0]; %TODO - use it see if improves results
ub = [200,360]; %TODO - use it see if improves results

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
    
    %%% get event's date-time:
    rows_event = storms_in_rehovot.eventID == eventID;
    N_sequences = sum(rows_event);
    dates = [ storms_in_rehovot.ds(rows_event) , storms_in_rehovot.de(rows_event)];
    ds_event = dates(1,1); de_event = dates(1,2);
    exclude_hops = storms_in_rehovot.exclude_hops(rows_event); %TODO exclude only single link out of the hop

    for seq = 1:N_sequences
        ds = dates(seq,1); de = dates(seq,2);
        
        hops = hops_in_total;
        %%% exclude noisy/broken/mulfunctioning hops specific to this event
        [~,ia,~] = intersect(hops,exclude_hops{seq}, 'stable');
        hops(ia) = [];
    
        [rssi , hops_ID] = extract_rssi(hops, db , ds ,de , meta_data);
        %[links_ID , tau  , rssi, valid_time_axis, distance, phi ,valid_rows , N_samples ] = calc_xcorr_between_hops_ALLLIKNS(hops, db, ds, de, meta_data, distanceG, phiG );
        [links_ID , tau  , rssi, valid_time_axis, distance, phi, valid_rows , N_samples ] = calc_xcorr_between_hops_indepenend_links(hops, db, ds, de, meta_data , distanceG, phiG);
        
        % MLE (x - is the parameter to estimate)
        %weight = 1./(meta_data.length(valid_hops) * meta_data.length(valid_hops)');
        weight = 1;
        residual = @(x) weight(:).*(tau - (distance/x(1)) .* cosd(phi - x(2)));
        %x = lsqnonlin(residual,[v_wind0 alpha_wind0]);
        x = lsqnonlin(residual,[v_wind0 alpha_wind0], lb ,ub);

        storms_info{eventID}.v_wind{seq} = x(1);  
        storms_info{eventID}.alpha_wind{seq} = wrapTo360(x(2)); 
        
        [hops_sorted , sort_index] = sort_hops_by_geographic_location(links_ID , meta_data , storms_info{eventID}.alpha_wind{seq});

        storms_info{eventID}.valid_rssi_arranged{seq}   = rssi(: , sort_index);
        storms_info{eventID}.valid_hops_arranged{seq}   = hops_sorted;
        storms_info{eventID}.active_hops{seq}           = length(hops_sorted);
        storms_info{eventID}.valid_time_axis{seq}       = valid_time_axis;
        storms_info{eventID}.storm_strength{seq}        = max(max(rssi));
        storms_info{eventID}.valid_rows_precentage{seq} = sum(valid_rows)/N_samples;
        
    end
    disp(['end of ' eventID_s]);
end

%save('storms_info_independent.mat' , 'storms_info');
clear k map s ind_period