function [rssi , hops_ID] = extract_rssi(hops, db , ds ,de , meta_data)
    N_hops = length(hops);
    time_axis = ds:seconds(30):de;
    N_samples = length(time_axis);
    N_max_links = 2*N_hops; %This is the maximum posible. Some of the hops has only one link
    
    rssi = nan(N_samples, N_max_links);
    hops_ID = nan(N_max_links, 1);
    
    %TODO: enable adujstable threshold
    th_dead_link = 10;% 0.1 * N_samples; % #ofsamples that below that link is dead during event
    
    i_link = 0;
    for i = 1:N_hops
        hop = char(hops(i));
        directions = fieldnames(db.(hop));
        for j = 1:length(directions)
            direction = char(directions(j));
            i_link = i_link+1;
            
            %%% read measurements
            rsl = db.(hop).(char(direction)).raw(:,2);
            t = u.pos2t(db.(hop).(char(direction)).raw(:,1));
            ind = t>=ds & t<=de;
            if( sum(ind)< th_dead_link || sum(~isnan(rsl(ind))) < th_dead_link ); continue; end
            
            %%% normalize signal - reduce avarage and normalize in hop's length
            avg = db.(hop).(direction).mean;
            rsl = rsl - avg; %TODO: think if this is correct
            rsl = rsl/meta_data.length(hop); %TODO: think if this is correct
            
            %%% inteploate for uniform time axis and for fill missing samples
            ts  = timeseries( rsl(ind), datestr( t(ind) ) );
            tmp = ts.resample( datestr(time_axis), 'zoh' );
            
            %%% extarpolate for missing samples at the edges
            %TODO: maybe the correct way is to extarpolate using samples outside of the time frame.
            nan_samples = isnan(tmp.Data);
            xq = 1:length(time_axis);       
            yq = interp1( xq(~nan_samples) , tmp.Data(~nan_samples) , xq , 'linear' , 'extrap');
            
            
            %rssi(:,i_link) = tmp.Data - mean(tmp.Data, 'omitnan');
            %TODO: does it is correct to reduce mean value?? Hagit says it increase SNR. try to read about it. 
            rssi(:,i_link) = yq - mean(yq);
            hops_ID(i_link) = meta_data.hop_ID(hop);
            
            %disp([DEBUG: extract_rssi: 'hop' num2str(i) 'link' num2str(j)]);
        end
    end
    
    %%% exclude dead links. 
    i_valid = any(rssi); 
    rssi = rssi(:, i_valid);
    hops_ID = hops_ID(i_valid);
end