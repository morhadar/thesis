%% load smbit data
db_path = 'C:\Users\mhadar\Documents\personal\smbit\data\TAU\';
db_path2 = 'C:\Users\mhadar\Documents\personal\smbit\data\data08052018\';

variables_names = ...
["RSSI Avarage"  , "CinrAVG"     , "Modulation"  , "Radio Throughput" ; 
 "time_rssi"     , "time_cinr"   , "time_mod"    , "time_radio"; %TODO - unified time axis for all variables and remove duplicates
 "rssi"          , "cinrAVG"     , "modulation"  , "radio_throughput"]; 

meta_data = readtable('meta_data.xlsx', 'ReadVariableNames', true , 'ReadRowNames',true );
meta_data = DMS2DD(meta_data);

db1 = smbit_load_rssi_data_type1(meta_data , db_path , variables_names);
db2 = smbit_load_rssi_data_type2(meta_data , db_path2, variables_names);
db = unify_db(meta_data, db1 , db2,variables_names);

db_t = convert_minus128_to_nan(meta_data,db);
save('meta_data.mat', 'meta_data');
save('db.mat', 'db' , 'db1' , 'db2' );    

%% load erricson data
path_meta = 'data\Ericsson\Metadata_2015_2017_2018\mw_meta_20170105_1455.csv';
path_raw = 'C:\Users\mhadar\Documents\personal\smbit\data\Ericsson\Rawdata_2017';
path_raw_eband = 'C:\Users\mhadar\Documents\personal\smbit\data\Ericsson\80GHZ for Mor\E_band\e_band_rx_power';

ericsson_meta = readtable(path_meta);
ericsson_meta.LinkID = strrep(ericsson_meta.LinkID,'-','_');
ericsson_db = ericsson_load_raw_data(ericsson_meta , path_raw);
ericsson_db_eband = ericsson_load_raw_data_eband(path_raw_eband); 

save( 'ericsson_db_eband.mat' , 'ericsson_db_eband');

%% load ims data 
paths = {'data\ims_201801.csv' 'data\ims_201802.csv' 'data\ims_201803.csv' 'data\ims_201804.csv' 'data\ims_201805.csv'};
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

for i = 2:5%:length(paths)
   path = char(paths(i));
   ims_db = load_ims_data(path, ims_db, stations, measurements);
end

save('ims_db.mat' , 'ims_db');
clear paths stations measurements
%% load gamliel
%TODO - consider unified with ims
path = 'data\COPY_Gamliel_08_05_2018.xls';

gamliel_db = load_gamliel(path);
save('gamliel.mat' , 'gamliel_db');
clear path

%% load sunrise/sunset table
file_path = 'C:\Users\mhadar\Documents\personal\smbit\data\sunrise_sunset.csv';

suntime_db = load_sunrise_sunset (file_path);
save( 'suntime_db.mat' , 'suntime_db');
clear file_path;
