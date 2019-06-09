%% load ims data 
paths = {   'C:\Users\mhadar\Documents\personal\thesis_materials\data\ims\ims_201801.csv' ...
            'C:\Users\mhadar\Documents\personal\thesis_materials\data\ims\ims_201802.csv' ...
            'C:\Users\mhadar\Documents\personal\thesis_materials\data\ims\ims_201803.csv' ... 
            'C:\Users\mhadar\Documents\personal\thesis_materials\data\ims\ims_201804.csv' ...
            'C:\Users\mhadar\Documents\personal\thesis_materials\data\ims\ims_201805.csv' ...
            'C:\Users\mhadar\Documents\personal\thesis_materials\data\ims\ims_201806.csv' ...
            'C:\Users\mhadar\Documents\personal\thesis_materials\data\ims\ims_201807.csv' ...
            'C:\Users\mhadar\Documents\personal\thesis_materials\data\ims\ims_201808.csv' ...
            'C:\Users\mhadar\Documents\personal\thesis_materials\data\ims\ims_201809.csv' ...
            'C:\Users\mhadar\Documents\personal\thesis_materials\data\ims\ims_201810.csv' ...
            'C:\Users\mhadar\Documents\personal\thesis_materials\data\ims\ims_201811.csv' ...
            'C:\Users\mhadar\Documents\personal\thesis_materials\data\ims\ims_201812.csv' ...
            };
stations = ["beit_dagan" , "hafetz_haim" , "nahshon" , "kvotzat_yavne"];
measurements = ["temperature" ,	"temperature_max" , 	"temperature_min",	"temperature_near_ground",	"rh" ,...
                "atmospheric_pressure"	,"global_radiation"	,"direct_radiation"	,"diffuse_radiation"	,"rain" ,...
                "wind_speed",	"wind_direction"	,"std_wind_direction"	,"speed_of_the_upper_wind",	...
                "direction_of_the_upper_wind"	,"max_wind_speed_1min",	"max_wind_speed_10min",	"time_end_of_10min" ];
if (0) %init
    ims_db = [];
    for i= 1:length(stations)
        ims_db.(stations(i)).time = [];
        for j = 1:length(measurements)
            ims_db.(stations(i)).(measurements(j)) = []; 
        end
    end
end

for i = 12%1:length(paths)
   ims_db = load_ims_data(char(paths(i)) , ims_db, stations, measurements);
end

%save('ims_db.mat' , 'ims_db');
clear paths stations measurements

%% load ims clouds data
paths = {   'C:\Users\mhadar\Documents\personal\thesis_materials\data\ims\ims_clouds_201802_08.csv' ... %TODO - make is appandable.
            };
stations = ["beit_dagan_m"];
measurements = ["total_clouds" , "total_lower_clouds" , "height_lower_clouds" ,...
                "type_lower_clouds" , "type_medium_clouds" , "type_higher_clouds" ,...
                "current_weather" , "past_weather" , "horizontal_visibility" ];
            
if (1) %init
    ims_db_clouds = [];
    for i= 1:length(stations)
        ims_db_clouds.(stations(i)).time = [];
        for j = 1:length(measurements)
            ims_db_clouds.(stations(i)).(measurements(j)) = []; 
        end
    end
end

for i = 1:length(paths)
   ims_db_clouds = load_ims_data( char(paths(i)) , ims_db_clouds, stations, measurements);
end

save('ims_db_clouds.mat' , 'ims_db_clouds');
clear paths stations measurements

%% load gamliel
%TODO - consider unified with ims
path = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\COPY_Gamliel_08_05_2018.xls';
%TODO - verift time are standart time (otherwise -fix)!!!!!!!!!!!!!!!!!
gamliel_db = load_gamliel(path);
save('gamliel.mat' , 'gamliel_db');
clear path

%% load sunrise/sunset table
file_path = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\ims\sunrise_sunset.csv';
%TODO - verify time are standart time (otherwise -fix)!!!!!!!!!!!!!!!!!
%TODO - take from the new website i have found! 
t = load_sunrise_sunset (file_path);
suntime_db.date = datetime(2018,01,01):datetime(2019,01,01);
suntime_db.sunrise = interp1( t.time , t.sunrize , suntime_db.date);
suntime_db.sunset  = interp1( t.time , t.sunset  , suntime_db.date);
save( 'suntime_db.mat' , 'suntime_db');
clear file_path t 