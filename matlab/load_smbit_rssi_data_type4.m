function db = load_smbit_rssi_data_type4(meta_data , hop_link_mapping , db, db_path3, months)

for m = 1:length(months)
    mon = months(m); mon=mon{1};
    files = dir([db_path3 mon '\**\*.txt']);
    for i = 1:length(files)
        disp(i);
        fid = fopen(fullfile( files(i).folder , files(i).name));
        raw = fread(fid,inf);
        str = char(raw');
        if ( strcmp(str, 'None') || strcmp(str, '{}') )
            disp(['empty file - ' fullfile( files(i).folder , files(i).name)]);
            continue;
        end
        str = char(strrep(str ,"'", '"')) ;
        json_str = jsondecode(str);
        for j = 1:length(json_str)
            link_name_in_file = json_str(j).name;
            item_id = str2double( json_str(j).siklu_rssavg.itemid);
            
            %check that link_name in json exist also in meta data
            %check that idem_id in json is identical to the one in meta_data.
            ind_link = strcmp(link_name_in_file, hop_link_mapping.link_name);
            ind_id = item_id == hop_link_mapping.item_id;
            if( sum(ind_link) ~=1 | sum(ind_id) ~=1 |  ~isequal(ind_link,ind_id) )
                disp(['new link or item_id - ' link_name_in_file ', Item ID: ' num2str(item_id)  ]);
                disp(fullfile( files(i).folder , files(i).name));
                %TODO - keep parsing instead of return
                return
            end
            hop_name = char(hop_link_mapping.hop_name(link_name_in_file));
            link_direction = char(hop_link_mapping.link_direction(link_name_in_file));
            
            epoch_time = str2double(json_str(j).siklu_rssavg.lastclock);
            if(epoch_time ==0)
                continue;
            end
            rssi = str2double(json_str(j).siklu_rssavg.lastvalue);
            db.(hop_name).(link_direction).raw = [db.(hop_name).(link_direction).raw ; epoch_time rssi];
        end
        fclose(fid);
    end
end
    
 
