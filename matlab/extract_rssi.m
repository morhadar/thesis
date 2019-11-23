function [rssi , hops_ID] = extract_rssi(hops, db , ds ,de , meta_data)
    N_hops = length(hops);
    time_axis = ds:seconds(30):de;
    N_samples = length(time_axis);
    
    rssi = nan(N_samples, 2*N_hops);
    links_ID = nan(2*N_hops, 1);
    
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
            ind = t > ds & t < de;
            if( sum(ind)< th_dead_link ); continue; end
            
            %%% normalize signal - reduce avarage and normalize in hop's length
            avg = db.(hop).(direction).mean;
            rsl = rsl - avg; %TODO: think if this is correct
            rsl = rsl/meta_data.length(hop); %TODO: think if this is correct
            
            %%% inteploate for uniform time axis and for fill missing samples
            ts  = timeseries( rsl(ind), datestr( t(ind) ) );
            tmp =  ts.resample( datestr(time_axis), 'zoh' );
            
            %disp(['hop' num2str(i) 'link' num2str(j)]);
            rssi(:,i_link) = tmp.Data - mean(tmp.Data, 'omitnan');
            links_ID(i_link) = meta_data.hop_ID(hop);
            
%             hold on; plot(time_axis , tmp.Data, '--');
%             hold on; plot(t(ind) , rsl(ind));

        end
    end


end