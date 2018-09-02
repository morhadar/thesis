function db = load_smbit_rssi_data_type2(meta_data , db_path, variables_names)
how_to_handle_missing_data = 0; %0-do nothing, 1-NAN, 2-linear interpolation. %TODO - add functonality

db = [];
for i = 1:length(meta_data.link_name) %TODO run the foor loop in the names itselfs
    link_name = char(meta_data.link_name(i));
    temp = readtable( [db_path link_name '.csv']);
    for j = 1:size(variables_names,2)
        idx = strcmp(temp.Item_name , variables_names(1,j));
        time = temp.Time(idx);
        
        %convert to standart time instead of DST
        time.TimeZone = 'local';
        dst_idx = isdst(time);
        time.TimeZone = '';
        time( dst_idx ) = time( dst_idx ) - hours(1);
        
        time.Format = 'dd.MM.yyyy HH:mm:ss';
        db.(link_name).(variables_names(2,j)) = time;
        db.(link_name).(variables_names(3,j)) = temp.Value(idx); 
    end
    %db.(link_name).time_rssi.Format = 'dd.MM.yyyy HH:mm:ss';
end
