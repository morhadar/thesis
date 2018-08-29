function ericsson_db_eband = ericsson_load_raw_data_eband(path_raw_eband)
%dbstop if error;
txt_files = dir(fullfile(path_raw_eband, 'rxPow_*.txt'));

ericsson_db_eband = [];
ericsson_db_eband.time = [];
ericsson_db_eband.rssi= [];
ericsson_db_eband.volt = [];


for n = 1:810%length(txt_files)
    if (n==22 || n==35 || n==91 || n==104 || n==201|| n==282 || n==314 || ...
            n==380 || n==381 || n==417 || n==536 || n==639 || n==688 || n==699 ||...
            n==706 || n==714 || n==795 || n==810) 
        continue; 
    end
    %disp(n);
    temp = readtable( fullfile( txt_files(n).folder ,txt_files(n).name), 'TreatAsEmpty',{'-'}, 'Format','%{yyyy-MM-dd HH:mm:ss}D %f %f');  
    %time = datetime( temp.Time, 'InputFormat','yyyy-MM-dd HH:mm:ss');
    time = temp.Time;
    time.Format = 'dd.MM.yyyy HH:mm:ss';
    rssi = temp.RxPower;
    volt = temp.Volt;

    ericsson_db_eband.time = [ericsson_db_eband.time ; time]; 
    ericsson_db_eband.rssi = [ericsson_db_eband.rssi ; rssi];
    ericsson_db_eband.volt = [ericsson_db_eband.volt ; volt];
end

end
