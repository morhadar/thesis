function [links_ID , tau  , rssi, valid_time_axis, distance, phi, valid_rows , N_samples ] = calc_xcorr_between_hops_ALLLIKNS(hops, db, ds, de, meta_data , distanceG, phiG)
    N_hops = length(hops);
    time_axis = ds:seconds(30):de;
    N_samples = length(time_axis);
    
    rssi = nan(N_samples , 2*N_hops);
    links_ID = nan(2*N_hops,1 );
%     figure;
    %extract rssi
    N_links = 0;
    for i = 1:N_hops
        hop = char(hops(i));
        directions = fieldnames(db.(hop));
        for j = 1:length(directions)
            N_links = N_links+1;
            direction = char(directions(j));
            rsl = db.(hop).(char(direction)).raw(:,2);
            avg = db.(hop).(direction).mean;
            rsl = rsl - avg;
            rsl = rsl/meta_data.length(hop);
            t = datetime(db.(hop).(char(direction)).raw(:,1), 'ConvertFrom', 'posixtime') ;
            %ind = t > ds-seconds(30) & t < de+seconds(30);
            ind = t > ds & t < de;
            if( sum(ind)<10 ); continue; end
            ts  = timeseries( rsl(ind) , datestr( t(ind) ) );
            tmp =  ts.resample( datestr(time_axis), 'zoh' );
            
            %disp(['hop' num2str(i) 'link' num2str(j)]);

            rssi(:,N_links) = tmp.Data - mean(tmp.Data, 'omitnan');
            links_ID(N_links) = meta_data.hop_ID(hop);
            
%             hold on; plot(time_axis , tmp.Data, '--');
%             hold on; plot(t(ind) , rsl(ind));

        end
    end

    %exclude empty links. 
    ind_valid = any(rssi); 
    rssi = rssi(:,ind_valid);
    links_ID = links_ID(ind_valid);
    M = length(links_ID);

    %exclude NaN samples at the beginig and ending of sequence: %TODO- why nan at the edges???
    valid_rows = sum(isnan(rssi), 2) == 0 ;
    rssi = rssi(valid_rows , :);
    disp(['valid rows:' num2str(sum(valid_rows)) '/' num2str(N_samples)]);
    valid_time_axis = time_axis(valid_rows);
        
    
    %compute cross-correlation between all links:
    [R,lag] = xcorr(rssi);
    [~,I] = max(abs(R));
    tau = lag(I);
    tau = tau * 30;
    %disp(['sanity check: tau_transpose+tau=' num2str(any(any(tau' +tau)))]); % 0 is the expected result.
    if(sum(valid_rows) ==0)
        tau = zeros(M*M,1);
    end
    distance = distanceG(links_ID,links_ID);
    distance = distance(:);
    
    phi = phiG(links_ID,links_ID);
    phi = phi(:);
    
%     switch(mode)
%         case 'all_links'
%             tau = nan;
%             links_ID = 0;
%         case 'pivot'
%             if (0)
%                 
%             else %random
%                 pivot = randi(M);
%             end
%             tau = reshape(tau , [M , M ])';
%             tau = tau(pivot,2:end);
%             distance = distanceG(pivot,links_ID);
%             distance(pivot) = [];
%             
%         case 'random1'
%             
%     end
    
end