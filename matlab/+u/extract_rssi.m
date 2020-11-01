function [rssi , hops_ID, link_ID] = extract_rssi(hops, db, ds ,de , meta_data, normalize, extarp)
    N_hops = length(hops);
    time_axis = ds:seconds(30):de;
    N_samples = length(time_axis);
    N_links = 2*N_hops; %This is the maximum posible links. Some of the hops has only one link
    
    rssi = nan(N_samples, N_links);
    hops_ID = nan(N_links, 1);
    link_ID = cell(N_links, 1);
    
    %TODO: enable adujstable threshold
    th_dead_link = 10;% 0.1 * N_samples; % #ofsamples that below that link is dead during event
    
    i = 0;
    directions = {'up', 'down'};
    for n = 1:N_hops
        hop = char(hops(n));
%         directions = fieldnames(db.(hop));
        for j = 1:2 %length(directions)
            dir = char(directions(j));
            i = i +1;
            
            hops_ID(i) = meta_data.hop_ID(hop);
            link_ID{i} = dir;
            
            if( ~isfield(db.(hop),char(dir)))
                continue;
            end
            %%% read measurements
            rsl = db.(hop).(char(dir)).raw(:,2);
            t = u.pos2t(db.(hop).(char(dir)).raw(:,1));
            
            ind = t>=ds & t<=de;
            if( sum(ind)< th_dead_link || sum(~isnan(rsl(ind))) < th_dead_link ); continue; end
            
            %%% normalize signal - reduce avarage and normalize in hop's length
            if (normalize)
                avg = db.(hop).(dir).mean;
                rsl = rsl - avg; %TODO: think if this is correct
                rsl = rsl/meta_data.length(hop); %TODO: think if this is correct
            end
            
            %%% inteploate for uniform time axis and for fill missing samples
            ts  = timeseries( rsl(ind), datestr( t(ind) ) );
            tmp = ts.resample( datestr(time_axis), 'zoh' );
            rssi(:,i) = tmp.Data;
            
            %%% extarpolate for missing samples at the edges
            if(extarp)
                %TODO: maybe the correct way is to extarpolate using samples outside of the time frame.
                nan_samples = isnan(tmp.Data);
                xq = 1:length(time_axis);       
                yq = interp1( xq(~nan_samples) , tmp.Data(~nan_samples) , xq , 'linear' , 'extrap');
                rssi(:,i) = yq;
            end
            
            %%% save outputs
            if(normalize)
                rssi(:,i) = rssi(:,i)- mean(rssi(:,i), 'omitnan');
            end

            %disp([DEBUG: extract_rssi: 'hop' num2str(i) 'link' num2str(j)]);
        end
    end
    
    %%% exclude dead links. 
    i_valid = any(rssi); 
    rssi = rssi(:, i_valid);
    hops_ID = hops_ID(i_valid);
    link_ID = link_ID(i_valid); 
end