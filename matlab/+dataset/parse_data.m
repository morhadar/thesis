%% convert to new names:
new_db = [];
fn = fieldnames(db);
for k=1:numel(fn)
    disp(k)
    hop_name = hop_link_mapping.hop_name( fn{k} ); 
    hop_name = hop_name{1};
    disp(hop_name)
    link_direction = hop_link_mapping.link_direction( fn{k} ); 
    link_direction = link_direction{1};
    disp(link_direction)
    if( isempty(db.(fn{k}).time_rssi) )
        continue;
    end
    time = posixtime(db.(fn{k}).time_rssi);
    rssi = db.(fn{k}).rssi;
    raw_curr = [ time , rssi];
    if ( ~isfield( new_db , hop_name) )
        new_db.(hop_name) = [];
    end
    if ( isfield( new_db.(hop_name),link_direction) )
        raw_prev = new_db.(hop_name).(link_direction).raw;
        raw = [raw_prev ; raw_curr];
        raw = sortrows(raw);
    else
        raw = raw_curr;
    end
    new_db.(hop_name).(link_direction) = [];
    new_db.(hop_name).(link_direction).raw = raw;
end
db = new_db;
save('db.mat', 'db');
clear fn hop_name k link_direction raw raw_curr raw_prev rssi time
%% create empty array for all links:
for i = 1:size(hop_link_mapping,1)
    hop = char(hop_link_mapping.hop_name(i));
    if (~ isfield( db, hop))
        db.(hop) = [];
        disp( ['missing hop ' hop]);  
    end
    
    direction = char(hop_link_mapping.link_direction(i));
    if( ~isfield(db.(hop) , direction) )
        db.(hop).(direction) = [];
        disp( ['missing direction ' direction]);
    end
    if( ~isfield( db.(hop).(direction) , 'raw'))
        db.(hop).(direction).raw = [];
        disp( ['missing direction raw ' direction]);
    end
end
clear hops i hop direction
%% load more data:
db_path3 = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\smbit\packet3\';

months = {  'smbit_2018_01' %1
            'smbit_2018_02' %2
            'smbit_2018_03' %3
            'smbit_2018_04' %4
            'smbit_2018_05' %5
            'smbit_2018_06' %6
            'smbit_2018_07' %7
            'smbit_2018_08' %8
            'smbit_2018_09' %9
            'smbit_2018_10' %10
            'smbit_2018_11' %11
            'smbit_2018_12' %12
            'smbit_2019_01' %13
            'smbit_2019_02' %14
            'smbit_2019_03' %15
            'smbit_2019_04' %16
            'smbit_2019_05' %17
            'smbit_2019_06' %18
            };
        
db = load_smbit_rssi_data_type4(hop_link_mapping, db, db_path3, months(18)); %change month index!   
%save('db.mat', 'db' , '-append');

clear db_path3 months
%% write HDF5file:
fn = fieldnames(new_db);
for k=1:numel(fn)
    disp(k)
    if( isfield(new_db.(fn{k}), 'l_1to2')) 
        raw = new_db.(fn{k}).l_1to2.raw;
        h5create('db.h5',['/' fn{k} '/l_1to2'], size(raw));
        h5write('db.h5',['/' fn{k} '/l_1to2' ], raw);
    end
    if( isfield(new_db.(fn{k}), 'l_2to1')) 
        raw = new_db.(fn{k}).l_1to2.raw;
        h5create('db.h5',['/' fn{k} '/l_2to1'], size(raw));
        h5write('db.h5',['/' fn{k} '/l_2to1' ], raw);
    end
end
clear fn k raw 
