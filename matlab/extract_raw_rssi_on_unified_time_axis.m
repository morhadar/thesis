function [rssi, rssi_avg, hops_ID, link_ID] = extract_raw_rssi_on_unified_time_axis(hops, db, ds, de, meta_data)
% extract raw data from db of specified hops between certain dates de-ds.
% inputs:
%   hops(cell array)(1xN_hops) - each entry is the name of hop.
%   db(struct) - the dataset
%   ds(datetime) - date of start
%   de(datetime) - date of end
% outputs:
%   rssi(double)(N_samples x 2*N_hops) - nan if data is not available or
%   link doesnt exists.

    N_hops = length(hops);
    time_axis = ds:seconds(30):de;
    N_samples = length(time_axis);
    N_links = 2*N_hops; %This is the maximum posible links. Some of the hops has only one link
    
    rssi = nan(N_samples, N_links);
    rssi_avg = nan(N_samples, N_links);
    hops_ID = nan(N_links, 1);
    link_ID = cell(N_links, 1);
    
    i = 0;
    directions = {'up', 'down'};
    for n = 1:N_hops
        hop = char(hops(n));
        for j = 1:2
            i = i + 1;
            direction = char(directions(j));
                        
            hops_ID(i) = meta_data.hop_ID(hop);
            link_ID{i} = direction;
            
            if( ~isfield(db.(hop), char(direction)))
                continue;
            end
            %%% read measurements
            rsl = db.(hop).(char(direction)).raw(:,2);
            avg = db.(hop).(direction).mean;
            t = u.pos2t(db.(hop).(char(direction)).raw(:,1));
            
            ind = t>=ds & t<=de;
            if ~any(ind)
                continue;
            end
%             if( sum(ind)< th_dead_link || sum(~isnan(rsl(ind))) < th_dead_link ); continue; end
                       
            %%% inteploate for uniform time axis and for fill missing samples
            ts  = timeseries( rsl(ind), datestr( t(ind) ) );
            tmp = ts.resample( datestr(time_axis), 'zoh' );
            rssi(:,i) = tmp.Data;
            
            ts  = timeseries( avg(ind), datestr( t(ind) ) );
            tmp = ts.resample( datestr(time_axis), 'zoh' );
            rssi_avg(:,i) = tmp.data;
        end
    end
end