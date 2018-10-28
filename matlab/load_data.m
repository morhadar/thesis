%% load smbit data
meta_data_file1 = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\smbit\meta_data_delete.xlsx'; %TODO - delete
db_path1 = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\smbit\packet1\';
db_path2 = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\smbit\packet2\';


variables_names = ...
["RSSI Avarage"  , "CinrAVG"    , "Modulation"  , "Radio Throughput" ; 
 "time_rssi"     , "time_cinr"   , "time_mod"    , "time_radio";
 "rssi"          , "cinrAVG"     , "modulation"  , "radio_throughput"]; 

meta_data1 = readtable(meta_data_file1, 'ReadVariableNames', true , 'ReadRowNames',true );
meta_data1 = DMS2DD(meta_data1);

db1 = load_smbit_rssi_data_type1(meta_data1 , db_path1 , variables_names); %TODO - metadata can also be used
db2 = load_smbit_rssi_data_type2(meta_data1 , db_path2, variables_names); %TODO - metadata can also be used
db = unify_db(meta_data1, db1 , db2, variables_names);

db = convert_minus128_to_nan(meta_data1,db); %TODO - are there any other error types. 

save('meta_data1.mat', 'meta_data1');
save('db.mat', 'db' , 'db1' , 'db2' );

clear meta_data_file1 db_path1 db_path2 variables_names db1 db2

%% data3!!
meta_data_file = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\smbit\meta_data.csv';
db_path3 = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\smbit\packet3\';

meta_data = readtable(meta_data_file, 'ReadVariableNames', true , 'ReadRowNames',true );
meta_data = sortrows(meta_data, 'length_KM' );
save('meta_data.mat', 'meta_data');


if(1)
    db3 = [];
    for i = 1:size(meta_data,1)
        link_name = meta_data.link_name(i);
        link_name = link_name{1};
        db3.(link_name).time_rssi = [];
        db3.(link_name).rssi = [];
    end
end

months = {'smbit_2018_05' , 'smbit_2018_06' , 'smbit_2018_07', 'smbit_2018_08', 'smbit_2018_09' };
db3 = load_smbit_rssi_data_type3(meta_data ,db3, db_path3, months()); %chagne month index!
db3 = convert_minus128_to_nan(meta_data,db3); 
%db = unify_db2(meta_data, db , db3);
%db3_2018_<> = db3;
%save('db.mat', 'db' , 'db3_2018_', '-append'); %change name of month

%% TODO - fill missing data with nan in presentation! 


%% load erricson data
path_meta = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\Ericsson\Metadata_2015_2017_2018\mw_meta_20170105_1455.csv';
path_raw = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\Ericsson\Rawdata_2017';
path_raw_eband = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\Ericsson\80GHZ for Mor\E_band\e_band_rx_power';
%TODO - verift time are standart time (otherwise -fix)!!!!!!!!!!!!!!!!!
ericsson_meta = readtable(path_meta);
ericsson_meta.LinkID = strrep(ericsson_meta.LinkID,'-','_');
ericsson_db = ericsson_load_raw_data(ericsson_meta , path_raw);
ericsson_db_eband = ericsson_load_raw_data_eband(path_raw_eband); 

save( 'ericsson_db_eband.mat' , 'ericsson_db_eband');

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

for i = 6:9%:length(paths)
   ims_db = load_ims_data(char(paths(i)) , ims_db, stations, measurements);
end

save('ims_db.mat' , 'ims_db');
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
%TODO - verift time are standart time (otherwise -fix)!!!!!!!!!!!!!!!!!
%TODO - take from the new website i have found! 
suntime_db = load_sunrise_sunset (file_path);
save( 'suntime_db.mat' , 'suntime_db');
clear file_path;

%% load smbit kfar_saba:
file_path = '..\..\thesis_materials\data\skfar_saba_siklu\rssi.csv';
file = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\kfar_saba_siklu\rssi.csv';
db_kfar_saba = readtable(file);
figure; plot( db_kfar_saba.Var1 , db_kfar_saba.Var2);


