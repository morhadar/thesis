%% load SMBIT meta data
% meta_data_file1 = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\smbit\meta_data_delete.xlsx'; %TODO - delete
% meta_data1 = readtable(meta_data_file1, 'ReadVariableNames', true , 'ReadRowNames',true );
% meta_data1 = DMS2DD(meta_data1);
% save('meta_data1.mat', 'meta_data1');

meta_data_file = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\smbit\meta_data.csv';
meta_data = readtable(meta_data_file, 'ReadVariableNames', true , 'ReadRowNames',true );
meta_data = sortrows(meta_data, 'length_KM' );
save('meta_data.mat', 'meta_data');

clear meta_data_file1 meta_data_file
%% load SMBIT data
db_path1 = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\smbit\packet1\';
db_path2 = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\smbit\packet2\';
variables_names = ...
["RSSI Avarage"  , "CinrAVG"    , "Modulation"  , "Radio Throughput" ; 
 "time_rssi"     , "time_cinr"   , "time_mod"    , "time_radio";
 "rssi"          , "cinrAVG"     , "modulation"  , "radio_throughput"]; 

db1 = load_smbit_rssi_data_type1(meta_data1 , db_path1 , variables_names); %TODO - metadata can also be used
db2 = load_smbit_rssi_data_type2(meta_data1 , db_path2, variables_names); %TODO - metadata can also be used
db = unify_db(meta_data1, db1 , db2, variables_names);

save('db.mat', 'db' , 'db1' , 'db2' );
clear db_path1 db_path2 variables_names db1 db2

%% load SMBIT online data 
db_path3 = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\smbit\packet3\';

if(1)
    db3 = [];
    for i = 1:size(meta_data,1)
        link_name = meta_data.link_name(i);
        link_name = link_name{1};
        db3.(link_name).time_rssi = [];
        db3.(link_name).rssi = [];
    end
end

months = {  'smbit_2018_01', 
            'smbit_2018_02', 
            'smbit_2018_03',
            'smbit_2018_04',
            'smbit_2018_05', 
            'smbit_2018_06', 
            'smbit_2018_07', 
            'smbit_2018_08', 
            'smbit_2018_09',
            'smbit_2018_10',
            'smbit_2018_11', 
            'smbit_2018_12',
            'smbit_2019_01',
            'smbit_2019_02'};
        %TODO - need to parse better links that changed their names! look at the table at onenote.
db3 = load_smbit_rssi_data_type3(meta_data ,db3, db_path3, months(14)); %change month index!
%db = unify_db2(meta_data, db , db3);
db3_2019_02 = db3; %********* change name to db3_2018_10 ******
%save('db.mat', 'db3_2018_12' , 'db' , '-append'); %******* change name to db3_2018_10 ********

%% load erricson data
path_meta = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\Ericsson\Metadata_2015_2017_2018\mw_meta_20170105_1455.csv';
path_raw = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\Ericsson\Rawdata_2017';
path_raw_eband = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\Ericsson\80GHZ for Mor\E_band\e_band_rx_power';
%TODO - verift times are standart time (otherwise -fix)!!!!!!!!!!!!!!!!!
ericsson_meta = readtable(path_meta);
ericsson_meta.LinkID = strrep(ericsson_meta.LinkID,'-','_');
ericsson_db = ericsson_load_raw_data(ericsson_meta , path_raw); % TODO - need to parse the ziped files!! 
ericsson_db_eband = ericsson_load_raw_data_eband(path_raw_eband); 

save( 'ericsson_db_eband.mat' , 'ericsson_db_eband');
save( 'ericsson_db' , 'ericsson_db');

%% load SMBIT kfar_saba:
file_path = '..\..\thesis_materials\data\skfar_saba_siklu\rssi.csv';
file = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\kfar_saba_siklu\rssi.csv';
db_kfar_saba = readtable(file);
figure; plot( db_kfar_saba.Var1 , db_kfar_saba.Var2);
save( 'db_kfar_saba' ,'db_kfar_saba');
%% load ceragon
path = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\ceragon';
l11 = readtable( fullfile(path , '72541_adumim_mishteret_ishai_10.239.11.205.csv'           ));
l12 = readtable( fullfile(path , '72542_mishteret_ishai_80L_maale adumi_10.239.11.206.csv'  ));
l21 = readtable( fullfile(path , '72593_KarneySohmron__PelephoneNofim_HI_10.239.106.214.csv')); 
l22 = readtable( fullfile(path , '72594_PelephoneNofim__KarneySohmron_LO.csv'               )); 
l31 = readtable( fullfile(path , '71911_maaleadumim_80H_keidar_10.239.11.212.csv'           )); 
l32 = readtable( fullfile(path , '71912_keidar_80L_maale_adumim_10.239.11.213.csv'          )); 

save( 'ceragon.mat' , 'l11' ,'l12', 'l21', 'l22', 'l31', 'l32');
clear path
 %% convert to hdf5:
 time = posixtime(db.siklu_leonardo_to_junc1.time_rssi);
 rsl = db.siklu_leonardo_to_junc1.rssi;
 h5create('f.h5','/leonardo_junc1/time', size(time))
 h5write('f.h5','/leonardo_junc1/time',time)
 h5create('f.h5','/leonardo_junc1/rssi', size(rsl))
 h5write('f.h5','/leonardo_junc1/rssi',rsl)
