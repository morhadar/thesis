function [links_ID , tau  , rssi, valid_time_axis, distance, phi, valid_rows , N_samples ] = calc_xcorr_between_hops_indepenend_links(hops, db, ds, de, meta_data , distanceG, phiG)
%take only M-1 measurements. 
    N_hops = length(hops);
    time_axis = ds:seconds(30):de;
    N_samples = length(time_axis);
    
    rssi = nan(N_samples , N_hops-1);
    links_ID = nan(N_hops-1, 1 );
%     figure;
    %extract rssi
    %N_links = 0;
    for i = 1:N_hops
        hop = char(hops(i));
        directions = fieldnames(db.(hop));
        jj = randi(length(directions));
        for j = jj
            %N_links = N_links+1;
            direction = char(directions(j));
            rsl = db.(hop).(char(direction)).raw(:,2);
            avg = db.(hop).(direction).mean;
            rsl = rsl - avg;
            rsl = rsl/meta_data.length(hop);
            t = datetime(db.(hop).(char(direction)).raw(:,1), 'ConvertFrom', 'posixtime') ;
            ind = t > ds & t < de;
            if( sum(ind)<10 ); continue; end
            ts  = timeseries( rsl(ind) , datestr( t(ind) ) );
            tmp =  ts.resample( datestr(time_axis), 'zoh' );
            
            %disp(['hop' num2str(i) 'link' num2str(j)]);

            rssi(:,i) = tmp.Data - mean(tmp.Data, 'omitnan');
            links_ID(i) = meta_data.hop_ID(hop);
            
%             hold on; plot(time_axis , tmp.Data, '--');
%             hold on; plot(t(ind) , rsl(ind));

        end
    end

    %exclude empty links. 
    ind_valid = any(rssi); 
    rssi = rssi(:,ind_valid);
    links_ID = links_ID(ind_valid);
    hops = hops(ind_valid);
    M = length(links_ID);

    %exclude NaN samples at the beginig and ending of sequence: %TODO- why nan at the edges???
    valid_rows = sum(isnan(rssi), 2) == 0 ;
    rssi = rssi(valid_rows , :);
    disp(['valid rows:' num2str(sum(valid_rows)) '/' num2str(N_samples)]);
    valid_time_axis = time_axis(valid_rows);
    
    %pick pivot:
    [~ , sort_ind] = sort(meta_data.length(hops), 'descend');
    rssi = rssi(:, sort_ind);
    links_ID = links_ID(sort_ind);
    pivot = links_ID(1);
    
    %compute cross-correlation between all links:
    [R,lag] = xcorr(rssi);
    [~,I] = max(abs(R));
    tau = lag(I);
    if(isempty(tau))
        tau = zeros(1,M*M);
    end
    tau = tau * 30;
    tau = reshape(tau , [M M]);
    tau = tau(1,2:end);
    %disp(['sanity check: tau_transpose+tau=' num2str(any(any(tau' +tau)))]); % 0 is the expected result.
    distance = distanceG(pivot, links_ID);
    distance(1) = [];
    
    phi = phiG(pivot, links_ID);
    phi(1) = [];  
end