%% load ims data 
ims_db_path = '../data/raw_data/ims';
months = {'ims_201801.csv'%1
          'ims_201802.csv'%2
          'ims_201803.csv'%3
          'ims_201804.csv'%4
          'ims_201805.csv'%5
          'ims_201806.csv'%6
          'ims_201807.csv'%7
          'ims_201808.csv'%8
          'ims_201809.csv'%9
          'ims_201810.csv'%10
          'ims_201811.csv'%11
          'ims_201812.csv'%12
          'ims_201901.csv'%13
          'ims_201902.csv'%14
          'ims_201903.csv'%15
          'ims_201904.csv'%16
          'ims_201905.csv'%17
          'ims_201906.csv'%18
            };
stations = ["beit_dagan" , "hafetz_haim" , "nahshon" , "kvotzat_yavne"];
measurements = ["temperature" ,	"temperature_max" , 	"temperature_min",	"temperature_near_ground",	"rh" ,...
                "atmospheric_pressure"	,"global_radiation"	,"direct_radiation"	,"diffuse_radiation"	,"rain" ,...
                "wind_speed",	"wind_direction"	,"std_wind_direction"	,"speed_of_the_upper_wind",	...
                "direction_of_the_upper_wind"	,"max_wind_speed_1min",	"max_wind_speed_10min",	"time_end_of_10min" ];
ims_db = load_ims_data(ims_db, stations, measurements, ims_db_path, months(11:18));
%save('ims_db.mat' , 'ims_db');
clear paths stations measurements

%% load ims clouds data
months = {'../data/raw_data/ims/ims_clouds_201802_08.csv' ... %TODO - make is appandable.
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

for i = 1:length(months)
    %TODO - time for these stations is in UTC. need to fix since the
    %function 'load_ims_data' is working with LTS time( winter clock all
    %year long).
   ims_db_clouds = load_ims_data( char(months(i)) , ims_db_clouds, stations, measurements);
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