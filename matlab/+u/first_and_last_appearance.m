function meta_data = first_and_last_appearance(meta_data, db)
%expands metadata with first and last appearance column for each hop
    meta_data.first_appearance = NaT( size(meta_data,1) ,1);
    meta_data.last_appearance = NaT( size(meta_data,1) ,1);
    for i = 1:length(meta_data.hop_name)
        hop = char(meta_data.hop_name(i));
        directions = fieldnames(db.(hop));
        meta_data.first_appearance(i) = NaT;
        for j = 1:length(directions)
            direction = char(directions(j));
            meta_data.first_appearance(i) = min(datetime(db.(hop).(direction).raw(1,1), 'ConvertFrom', 'posixtime') , meta_data.first_appearance(i));
            meta_data.last_appearance(i) = max(datetime(db.(hop).(direction).raw(end ,1), 'ConvertFrom', 'posixtime') , meta_data.last_appearance(i));
        end  
    end
end