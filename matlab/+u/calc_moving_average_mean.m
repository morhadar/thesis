function db = calc_moving_average_mean(db)
    fn = fieldnames(db);
    win_size = (2*60*24) * 10; % num_of_samples_in_a_day * num_of_days.
    for k = 1:numel(fn)
        hop = char(fn(k));
        directions = fieldnames(db.(hop));
        for j = 1:length(directions)
            direction = char(directions(j));
            db.(hop).(direction).mean = movmean( db.(hop).(direction).raw(:,2),win_size,'omitnan');
        end
    end
end