function ims_db = load_ims_data (path, ims_db, stations, measurements)

table = readtable(path, 'TreatAsEmpty',{'-'}  );
table = readtable(path, 'Format','%s %s %{HH:mm}D %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'TreatAsEmpty',{'-'});

for i= 1:length(stations)
    idx = strcmp(table.station , stations(i));
    date = table.date(idx);
    date = strrep(date, '-' , '/');
    date = datetime(date, 'InputFormat' , 'dd/MM/uuuu');
    time = datetime(table.hour_LST(idx) ,'InputFormat' , 'HH:mm');
    date_time = date + timeofday(time);
    date_time.Format = 'dd.MM.yyyy HH:mm:ss';
    %date_time.TimeZone = '+02:00';
    ims_db.(stations(i)).time =[  ims_db.(stations(i)).time   ;   date_time   ];
    for j = 1:length(measurements)
        field = char(measurements(j));
        m = table.(field)(idx);
        ims_db.(stations(i)).(field)  = [ ims_db.(stations(i)).(field) ; m ];  
    end
end

end