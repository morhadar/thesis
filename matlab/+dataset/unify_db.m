function db = unify_db (meta_data, db1 , db2, variables_names) 
redundant_data = 1 ; %0 - combine measurments ( times are not overlapped in seconds). 1 - throw redundant samples from db2. 

db = []; 
for i = 1:length(meta_data.link_name)
    cn = char(meta_data.link_name(i));
    for j = 1:size(variables_names,2)
        time = variables_names(2,j);
        measurement = variables_names(3,j);
        last_t = db1.(cn).(time)(end);
        ind_new_data = db2.(cn).(time) > last_t;
        db.(cn).(time) = [db1.(cn).(time) ; db2.(cn).(time)(ind_new_data)];
        db.(cn).(measurement) = [db1.(cn).(measurement) ; db2.(cn).(measurement)(ind_new_data)];
    end
end

end