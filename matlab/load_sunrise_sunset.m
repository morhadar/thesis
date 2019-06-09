function suntime_db = load_sunrise_sunset (file_path)

%temp = readtable(file_path);
%table = readtable(file_path, 'Format','%{dd/mm/yyyy}D %f %f %f %f %f %f %f %f %f');
table = readtable(file_path, 'Format','%{dd/MM/yyyy}D %{HH:mm}D %s %{HH:mm}D %f %f %f %f %f %f' , 'TreatAsEmpty',{'-'});
suntime_db.time = table.date;
%suntime_db.time.Format = 'dd/MM/yyyy'; %TODO - all dates are January!!
suntime_db.sunrize = timeofday(datetime(table.sunrise_hour ,'InputFormat' , 'HH:mm'));
%suntime_db.noon = timeofday(datetime(table.noon_hour,'InputFormat' , 'HH:mm'))
suntime_db.sunset = timeofday(datetime(table.sunset_hour ,'InputFormat' , 'HH:mm'));
end