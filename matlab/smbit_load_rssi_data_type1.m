function db = smbit_load_rssi_data_type1(meta_data , db_path,variables_names)
single_time_first_half_min = 1; %if there is only one single sample at specific minute then put it in the first half minute rather than the second half.
how_to_handle_missing_data = 0; %0-do nothing, 1-NAN, 2-linear interpolation. %TODO - add functonality

db = [];
for i = 1:length(meta_data.link_name) %TODO run the for loop in the names itselfs
    link_name = char(meta_data.link_name(i));
    temp = readtable( [db_path link_name '-RSSI Avarage.csv']);
    db.(link_name).time_rssi = temp.Var3;
    db.(link_name).rssi = temp.Var4; 
    
    % shift 30 seconds ahead the second sample of a duplicate pair.
    db.(link_name).time_rssi.Format = 'dd.MM.yyyy HH:mm:ss';
    [~ , ia , ~ ] = unique( db.(link_name).time_rssi , 'last');
    if (single_time_first_half_min)
        db.(link_name).time_rssi(ia) = db.(link_name).time_rssi(ia) + seconds(30);
    else % NO NEED FOR NOW
        [~ , ia2 , ~ ] = unique( db.(link_name).time_rssi , 'first');
        %TODO - return the values that are in ia but not in ia2
    end
    
    temp = readtable( [db_path link_name '.csv']);
    for j = 2:size(variables_names,2)
        idx = strcmp(temp.Var2 , variables_names(1,j));
        db.(link_name).(variables_names(2,j)) = temp.Var3(idx);
        db.(link_name).(variables_names(3,j)) = temp.Var4(idx); 
    end
end
