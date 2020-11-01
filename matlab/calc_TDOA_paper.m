function [valid_hops , tau  , valid_rssi, valid_time_axis ] = calc_TDOA_paper(hops, db, ds, de, meta_data)
    N_hops = length(hops);
    time_axis = ds:seconds(30):de;
    N_samples = length(time_axis);
    rssi_mat_interpolated = zeros(N_samples , length(hops));
    for i = 1:N_hops
        hop = char(hops(i));
        directions = fieldnames(db.(hop));
        for j = 1%1:length(directions) %{'up' ,'down'} %TODO take also the second direction!
            direction = char(directions(j));
            rsl = db.(hop).(char(direction)).raw(:,2);
            avg = db.(hop).(direction).mean;
            rsl = rsl - avg;
            rsl = rsl/meta_data.length(hop);
            t = datetime(db.(hop).(char(direction)).raw(:,1), 'ConvertFrom', 'posixtime') ;
            ind = t > ds & t < de;
            if( sum(ind)<10 ); continue; end
            ts  = timeseries( rsl(ind) , datestr( t(ind) ) );
            tmp =  ts.resample( datestr(time_axis), 'zoh');
            rssi_mat_interpolated(:,i) = tmp.Data - mean(tmp.Data, 'omitnan');
        end
    end

    %exclude empty links.
    ind_valid = any(rssi_mat_interpolated); 
    valid_rssi = rssi_mat_interpolated(:,ind_valid);
    valid_hops = hops(ind_valid);
    valid_N_hops = length(valid_hops);

    %exclude NaN samples at the beginig and ending of sequence:
    valid_rows = sum(isnan(valid_rssi), 2) == 0 ;
    valid_rssi = valid_rssi(valid_rows , :);
    disp(['valid rows:' num2str(sum(valid_rows)) '/' num2str(N_samples)]);
    valid_time_axis = time_axis(valid_rows);
    

    %compute cross-correlation between all links:
    [R,lag] = xcorr(valid_rssi);
    auto_correlation = R(: , 1:valid_N_hops:end ); %TODO - check why for some links the autocorrelation is not symetric.
    cross_correlation = R;
    cross_correlation(: , 1:valid_N_hops:end ) = [];
    [~,I] = max(abs(R));
    delay_estimated = lag(I);
    tau = reshape(delay_estimated , [valid_N_hops , valid_N_hops ])';
    tau = tau * 30;
    disp(['sanity check: tau_transpose+tau=' num2str(any(any(tau' +tau)))]); % 0 is the expected result.

%     figure; plot( lag,auto_correlation ); title('auto correaltion');
%     figure; plot( lag,cross_correlation ); title('cross correaltion');
end