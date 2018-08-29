function suntime_db = load_sunrise_sunset (file_path)

temp = readtable(file_path);
%temp = temp(2:end, :); % not reading the first line as variable name is a workaround for the fact that afterwards the second colonm is deteced as daetime variable and cannot be concatenated.
%temp.Properties.VariableNames = {'station_name'  'date'  'hour_LST' ...
 %                               'temperature' 'temperature_max' 'temperature_min' 'temperature_near_ground'};


%temp2 = readtable(ims_path); % workaround to handle that otherwise it reads it as cell and i cannot convert it to double.
%temp2.Properties.VariableNames = {'station_name'  'date'  'hour_LST' ...
                             %   'temperature' 'temperature_max' 'temperature_min' 'temperature_near_ground'};



for i= 1:length(stations)
    idx = strcmp(temp.station_name , stations(i));
    ims_db.(stations(i)).time = datetime(strcat(temp.date(idx) , {' '} ,temp.hour_LST(idx) ),'InputFormat','dd/MM/yyyy HH:mm');
    ims_db.(stations(i)).time.Format = 'dd.MM.yyyy HH:mm:ss';
    ims_db.(stations(i)).temperature = str2double(temp.temperature(idx));  
    ims_db.(stations(i)).temperature_max = str2double(temp.temperature_max(idx));  
    ims_db.(stations(i)).temperature_min = str2double(temp.temperature_min(idx));  
    ims_db.(stations(i)).temperature_near_ground = str2double(temp.temperature_near_ground(idx));  
end

end