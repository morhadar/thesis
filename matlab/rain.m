%% init precipitation vector
for hop_num = order_hop_num
    idx = meta_data.hop_num == hop_num;
    channel_names = meta_data.link_name(idx);
    for n = 1:length(channel_names)
        cn = char(channel_names(n));
        N = length(db.(cn).rssi);
        db.(cn).precipitation = zeros( N,1);
        db.(cn).p_accum = zeros(N,1);
    end
end 

%% estimate percipitation
map = distinguishable_colors(21);

f1 = figure('Name', 'Accumulated Rain');
f2 = figure('Name', 'Rain Rate');

for hop_num = order_hop_num
    if ( hop_num == 14 && true) %exclude junc10_to_junc11 
        continue;
    end
    idx = meta_data.hop_num == hop_num;
    channel_names = meta_data.link_name(idx);
    L = meta_data.length_KM(idx); L = L(1);
    min_rain_rate = meta_data.minimal_rain_rate(idx); min_rain_rate = min_rain_rate(1);
    
    for n = 1:length(channel_names)
        cn = char(channel_names(n));
        ind = db.(cn).time_rssi > ds & db.(cn).time_rssi<de;
        if (sum(ind) ==0 )
            disp( ['hop ' num2str(hop_num) ' link' num2str(n) ' is not available']);
        end
        a = db.(cn).rssi(ind);
        a_norm = ( db.(cn).rsl_median(ind) - a )./L;
        a_norm( a_norm<0 ) = nan;
        db.(cn).rain(ind) = nthroot(a_norm./alpha,beta )./120 ;
        db.(cn).p_accum(ind) = cumsum(db.(cn).rain(ind) );
        figure(f1);
        hold on; plot( db.(cn).time_rssi(ind) , db.(cn).p_accum(ind), 'DisplayName' , [ 'hop ' num2str(hop_num) ' - ' num2str(meta_data{(cn),'length_KM'}) 'Km ,'] , 'color' , map(hop_num,:));  
        %title(['hop ' num2str(hop_num) ' -- ' cn ' -- ' num2str(meta_data{(cn),'length_KM'}) 'Km ,']);
        
        figure(f2); hold on; plot( db.(cn).time_rssi(ind) , db.(cn).rain(ind), 'DisplayName' , [ 'hop ' num2str(hop_num) ' - ' num2str(meta_data{(cn),'length_KM'}) 'Km ,'] , 'color' , map(hop_num,:));  
        figure(f2); hold on; plot( ds:seconds(30):de , min_rain_rate*ones(size(ds:seconds(30):de)) , 'DisplayName' , ['hop ' num2str(hop_num) ' boundary'], 'color' , map(hop_num,:), 'LineWidth', 2);
        % add rain gauges:
        %ind = ims_db.beit_dagan.time > ds & ims_db.beit_dagan.time<de;
        %accum = cumsum(ims_db.beit_dagan.precipitation(ind) * 6);
        %hold on; plot(ims_db.beit_dagan.time(ind) ,accum , 'DisplayName', 'BeitDagan');
        %hold on; plot(ims_db.beit_dagan.time(ind) ,ims_db.beit_dagan.precipitation(ind) * 6, 'DisplayName', 'BeitDagan');
    end
end 

%add rain gauges
ind = gamliel_db.time > ds & gamliel_db.time <de;
figure(f2); hold on; plot( gamliel_db.time(ind), gamliel_db.rain(ind) * 6 , '--', 'LineWidth', 1, 'DisplayName', 'gamliel');
figure(f1); hold on; plot( gamliel_db.time(ind), cumsum(gamliel_db.rain(ind)) , '--', 'LineWidth', 1, 'DisplayName', 'gamliel');
stations = ["beit_dagan" , "hafetz_haim" , "nahshon" , "kvotzat_yavne"];
for i = 1:4
    s = stations(i);
    ind_period = ims_db.(s).time > ds & ims_db.(s).time<de;
    figure(f2); hold on; plot(ims_db.(s).time(ind_period) ,ims_db.(s).rain(ind_period) * 6, '--', 'LineWidth', 1, 'DisplayName', s);
    figure(f1); hold on; plot(ims_db.(s).time(ind_period) , cumsum(ims_db.(s).rain(ind_period)) , '--', 'LineWidth', 1, 'DisplayName', s);
end

%% plot rain estimation with rain gauges and minimal rain constraint
map = distinguishable_colors(21);
figure;
for hop_num = order_hop_num
    if ( hop_num == 14 && true) %exclude junc10_to_junc11 
        continue;
    end
    idx = meta_data.hop_num == hop_num;
    channel_names = meta_data.link_name(idx);
    L = meta_data.length_KM(idx); L = L(1);
    min_rain_rate = meta_data.minimal_rain_rate(idx); min_rain_rate = min_rain_rate(1);
    
    for n = 1:length(channel_names)
        cn = char(channel_names(n));
        ind = db.(cn).time_rssi > ds & db.(cn).time_rssi<de;
        if (sum(ind) ==0 )
            disp( ['hop ' num2str(hop_num) ' is not available']);
        end
        
        hold on; plot( db.(cn).time_rssi(ind) , db.(cn).p_accum(ind), 'DisplayName' , [ 'hop ' num2str(hop_num) ' - ' num2str(meta_data{(cn),'length_KM'}) 'Km ,'] , 'color' , map(hop_num,:));  
        %title(['hop ' num2str(hop_num) ' -- ' cn ' -- ' num2str(meta_data{(cn),'length_KM'}) 'Km ,']);
        
        figure(f2); hold on; plot( db.(cn).time_rssi(ind) , db.(cn).precipitation(ind), 'DisplayName' , [ 'hop ' num2str(hop_num) ' - ' num2str(meta_data{(cn),'length_KM'}) 'Km ,'] , 'color' , map(hop_num,:));  
        % add rain gauges:
        %ind = ims_db.beit_dagan.time > ds & ims_db.beit_dagan.time<de;
        %accum = cumsum(ims_db.beit_dagan.precipitation(ind) * 6);
        %hold on; plot(ims_db.beit_dagan.time(ind) ,accum , 'DisplayName', 'BeitDagan');
        %hold on; plot(ims_db.beit_dagan.time(ind) ,ims_db.beit_dagan.precipitation(ind) * 6, 'DisplayName', 'BeitDagan');
    end
end 


