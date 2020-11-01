function db = load_smbit_rssi_data_type4( hop_link_mapping , db, db_path3, months)

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
            ind_id = (item_id == hop_link_mapping.item_id);
            if( item_id~=30980 && item_id~=30993) %force 1-1 match between link nameand iteam-id. but it doesn't happend in reality for muni_leonardo link
                %TODO - fix that. because now if the a new link that is not
                %muni_leonardo will get this item id I will never know.
                if( (sum(ind_link) ~=1 || sum(ind_id) ~=1 || ~isequal(ind_link,ind_id)) ) 
                %if( sum(ind_link) ~=1 || sum(ind_id) ~=1 )
                    disp(['new link or item_id - ' link_name_in_file ', Item ID: ' num2str(item_id)  ]);
                    disp(fullfile( files(i).folder , files(i).name));
                    %TODO - keep parsing instead of return
                    %waitforbuttonpress;
                    return
                    %continue; %TEMP!!!!!!!!!!!!!!!!!!!!!!!
                end
            end
            hop_name = char(hop_link_mapping.hop_name(link_name_in_file));
            link_direction = char(hop_link_mapping.link_direction(link_name_in_file));
            
            epoch_time = str2double(json_str(j).siklu_rssavg.lastclock);
            if(epoch_time ==0)
                continue;
            end
            rssi = str2double(json_str(j).siklu_rssavg.lastvalue);
            db = check_if_hop_exist(db , hop_name, link_direction);
            db.(hop_name).(link_direction).raw = [db.(hop_name).(link_direction).raw ; epoch_time rssi];
        end
        fclose(fid);
    end
end
end

function db = check_if_hop_exist(db , hop, direction)
    if (~ isfield( db, hop))
        db.(hop) = [];
        disp( ['missing hop ' hop]);  
    end
    if( ~isfield(db.(hop) , direction) )
        db.(hop).(direction) = [];
        disp( ['missing direction ' direction]);
    end
    if( ~isfield( db.(hop).(direction) , 'raw'))
        db.(hop).(direction).raw = [];
        disp( ['missing direction raw ' direction]);
    end  
end