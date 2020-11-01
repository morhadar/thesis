function ericsson_db = ericsson_load_raw_data(ericsson_meta , path_raw)
ericsson_db = [];
txt_files = dir(path_raw ); txt_files = txt_files(3:end);

%init links at struct
for i = 1:length(ericsson_meta.LinkID)
    link_name = char(ericsson_meta.LinkID(i));
    ericsson_db.(link_name) = [];
    ericsson_db.(link_name).time = [];
    ericsson_db.(link_name).rssi= [];
end


for n = 1:length(txt_files)
    %TODO - read the zip files instead!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    temp = readtable( fullfile( txt_files(n).folder ,txt_files(n).name), 'TreatAsEmpty',{'-'}  );
    temp.Properties.VariableNames = {'time'  'link' , 'tx' , 'rx'  }; %TODO - verify with Alona if it is indeed Tx and Rx
    
    for i = 1:length(ericsson_meta.LinkID) %TODO run the for loop in the names itselfs
        link_name = ericsson_meta.LinkID(i); link_name = link_name{1};
        link_name_for_file = strrep( link_name , '_', '-');
        idx = strcmp(temp.link ,link_name_for_file);
        
        time = datetime( temp.time(idx), 'InputFormat','dd-MM-yyyy HH:mm:ss');
        time.Format = 'dd.MM.yyyy HH:mm:ss';
        rssi = temp.rssi(idx);
        
        ericsson_db.(link_name).time = [ericsson_db.(link_name).time ; time]; 
        ericsson_db.(link_name).rssi = [ericsson_db.(link_name).rssi ; rssi];
        
    end
end

end
