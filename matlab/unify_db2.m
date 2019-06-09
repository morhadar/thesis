function db = unify_db2 (meta_data, db , db3) 

for i = 1:length(meta_data.link_name)
    cn = char(meta_data.link_name(i));
    if( isfield(db , cn) )
        if ( isempty(db.(cn).time_rssi) )
            db.(cn).time_rssi = db3.(cn).time_rssi;
            db.(cn).rssi = db3.(cn).rssi;
            continue;
        end
        last_t = db.(cn).time_rssi(end);
        if( isempty(db3.(cn).time_rssi) )
            continue;
        end
        ind_new_data = db3.(cn).time_rssi > last_t;
        db.(cn).time_rssi = [db.(cn).time_rssi  ; db3.(cn).time_rssi(ind_new_data)];
        db.(cn).rssi = [db.(cn).rssi ; db3.(cn).rssi(ind_new_data)];
        
    else
        db.(cn) = db3.(cn);
    end
end

end