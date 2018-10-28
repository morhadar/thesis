function db = load_smbit_rssi_data_type3(meta_data , db, db_path3, months)

for m = 1:length(months)
    mon = months(m); mon=mon{1};
    files = dir([db_path3 mon '\**\*.txt']);
    for i = 1:length(files)
        disp(i);
        fid = fopen(fullfile( files(i).folder , files(i).name));
        raw = fread(fid,inf);
        str = char(raw');
        if ( strcmp(str, 'None') || strcmp(str, '{}') )
            continue;
        end
        str = char(strrep(str ,"'", '"')) ;
        json_str = jsondecode(str);
        for j = 1:length(json_str)
            link_name = json_str(j).name;
            item_id = str2double( json_str(j).siklu_rssavg.itemid);
            
            %check that link_name in json exist also in meta data
            %check that idem_id in json is identical to the one in meta_data.
            if ( meta_data{link_name , 'item_id'} ~= item_id)
                disp('item ID is different from the the existing one');
                disp(link_name); disp(item_id)
            end
            
            epoch_time = str2double(json_str(j).siklu_rssavg.lastclock);
            if(epoch_time ==0)
                continue;
            end
            time = datetime( epoch_time , 'convertfrom','posixtime') + hours(2);
            time.Format = 'dd.MM.yyyy HH:mm:ss';
            rssi = str2double(json_str(j).siklu_rssavg.lastvalue);
            db.(link_name).time_rssi = [db.(link_name).time_rssi ; time];
            db.(link_name).rssi =  [db.(link_name).rssi ; rssi];
        end
        fclose(fid);
    end
end
    
 
