function db_out = convert_minus128_to_nan(meta_data,db)

for n = 1:size(meta_data,1)
    cn = char(meta_data.link_name(n));
    db.(cn).rssi ( db.(cn).rssi == -128) = nan;
    db_out = db;
end

end