function [max_daily , timestamp_of_max] = extract_max_daily( time_series , value_series , where_are_the_periods)
    [start,len,k1] = u.ZeroOnesCount(where_are_the_periods);
    %disp([start(1:k1); len(1:k1)]);
    max_daily = nan(k1,1);
    timestamp_of_max = NaT(k1,1);
    for i = 1:k1
        daily_night = start(i):(start(i) + len(i) -1);
        daily_time = time_series(daily_night);
        daily_rh = value_series(daily_night);
        [max_val , ind_max] = max(daily_rh);
        max_daily(i) = max_val;
        timestamp_of_max(i) = daily_time(ind_max);  
    end
end