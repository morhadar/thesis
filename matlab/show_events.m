
%% choose dates
switch (1)
    case 0 %all period
        ds = datetime(2018,01,01,00,00,00); de = datetime();
    case 0.1 %data1
        ds = datetime(2018,02,15,00,00,00); de = datetime(2018,03,20,00,00,00);
    case 0.2 %data2
        %ds = datetime(2018,03,19,11,00,00); de = datetime(2018,05,03,23,59,59);
        ds = datetime(2018,03,19,00,00,00); de = datetime(2018,05,03,23,59,59);
 
    case 1 %February rain
        ds = datetime(2018,02,17,00,00,00); de = datetime(2018,02,17,12,00,00);
    case 1.2 %rain march night
        ds = datetime(2018,03,29,00,00,00); de = datetime(2018,03,30,23,59,59);
    case 1.3 %April rain
        ds = datetime(2018,04,25,00,00,00); de = datetime(2018,04,25,23,00,00);

    case 2 %dry March
        ds = datetime(2018,03,03,00,00,00); de = datetime(2018,03,20,00,00,00); 
    case 2.1 %dry April-May
        ds = datetime(2018,04,01,00,00,00); de = datetime(2018,05,05,00,00,00); 
    case 2.2 %dry
        ds = datetime(2018,02,28,00,00,00); de = datetime(2018,03,14,00,00,00); 
    
    case 3 %24h *3
        ds = datetime(2018,03,05,00,00,00); de = datetime(2018,03,07,23,59,59);
    case 3.1 %weird event - link11 
        ds = datetime(2018,03,19,00,00,00); de = datetime(2018,03,20,23,59,59);
    case 3.2 %weird event
        ds = datetime(2018,02,22,00,00,00); de = datetime(2018,02,23,00,00,00);
    case 3.3 %periodicity
        ds = datetime(2018,03,21,00,00,00); de = datetime(2018,03,26,23,59,59);
        
    case 11; ds = datetime(2018,01,01,00,00,00); de = datetime(2018,01,31,23,59,59);
    case 22; ds = datetime(2018,02,01,00,00,00); de = datetime(2018,02,28,23,59,59);
    case 33; ds = datetime(2018,03,01,00,00,00); de = datetime(2018,03,31,23,59,59);
    case 44; ds = datetime(2018,04,01,00,00,00); de = datetime(2018,04,30,23,59,59);
    case 55; ds = datetime(2018,05,01,00,00,00); de = datetime(2018,05,31,23,59,59);
end

%% choose hops
switch (2) %how to present links in graph.
    case 0 %by length decending 
        order_hop_num = (unique(meta_data.hop_num, 'stable'))';
    case 1 %partial north to south
        order_hop_num = [5 2 4 7 8 9 10 11 19 21 6  15 20 17 18];
    case 2 %partial west to east
        order_hop_num = [2 1 20 17 18];
    case 3 %periodicity
        order_hop_num = [ 18 , 7 ,10 ,5  ,16];
    case 4 %link specific
        order_hop_num = [ 5 ];
    case 5 %links cant see first peak of februar rain.
        order_hop_num = [1];
end

%% plot attenuation of hops: 

figure;
bias = 0;
map = distinguishable_colors(21);
for i = order_hop_num
    if ( i == 14 && true) %exclude junc10_to_junc11 
        continue;
    end
    idx = meta_data.hop_num == i;
    channel_names = meta_data.link_name(idx);
    for n = 1:length(channel_names)
        cn = char(channel_names(n));
        %subplot(length(meta_data.link_name),1,i);
        ind_period = db.(cn).time_rssi > ds & db.(cn).time_rssi<de;
        hold on;
        A = (db.(cn).rssi(ind_period) - db.(cn).rsl_median(ind_period));
        A = A/meta_data{cn, 'length_KM'}; % normalize dm to dbm.
        bias = bias +20;
        plot( db.(cn).time_rssi(ind_period) , A - bias, 'DisplayName', ['hop' num2str(i), ' link' num2str(n)], 'color' , map(i,:) );
        title([ char(ds) ' - ' char(de)]);
    end
end


%% plot rain gaues 
stations = ["beit_dagan" , "hafetz_haim" , "nahshon" , "kvotzat_yavne"];

figure;
title('rainy days');
xlabel('date and time');
ylabel('R mm/h');
for i = 1:4
    s = stations(i);
    ind_period = ims_db.(s).time > ds & ims_db.(s).time<de;
    hold on; plot(ims_db.(s).time(ind_period) ,ims_db.(s).precipitation(ind_period) * 6, 'DisplayName', s);
end
ind = gamliel_db.time  > ds & gamliel_db.time <de;
hold on; plot( gamliel_db.time(ind) , gamliel_db.rain(ind) *6 , 'DisplayName' , 'gamliel', 'LineWidth', 2);

% add constraints:
hold on; plot( ds:seconds(30):de , 0.4*ones(size(ds:seconds(30):de)) , 'DisplayName' , 'lowerbound', 'color' , 'r', 'LineWidth', 2);
hold on; plot( ds:seconds(30):de , 40*ones(size(ds:seconds(30):de)) , 'DisplayName' , 'upperbound', 'color' , 'g', 'LineWidth' ,2);
if(true) % add minimal threshold for specific links
    for i = order_hop_num
        idx = meta_data.hop_num == i;
        idx = find(idx,1);
        hold on; plot( ds:seconds(30):de , meta_data.minimal_rain_rate(idx)*ones(size(ds:seconds(30):de)) , 'DisplayName' , ['hop ' num2str(i) ' boundary'], 'color' , 'k');
    end
end

%% plot temperture 
stations = ["beit_dagan" , "hafetz_haim" , "nahshon" , "kvotzat_yavne"];
figure;
map = distinguishable_colors(4);
for i = 1:4
    s = stations(i);
    ind_period = ims_db_temperature.(s).time > ds & ims_db_temperature.(s).time<de;
    %hold on; plot(ims_db_temperature.(s).time(ind_period) ,ims_db_temperature.(s).temperature(ind_period), 'DisplayName', '[temperature - ' char(s)], 'color', map(i,:) );
    %hold on; plot(ims_db_temperature.(s).time(ind_period) ,ims_db_temperature.(s).temperature_max(ind_period), '--', 'DisplayName', ['max - ' char(s)], 'color', map(i,:) );
    %hold on; plot(ims_db_temperature.(s).time(ind_period) ,ims_db_temperature.(s).temperature_min(ind_period), ':', 'DisplayName', ['min - ' char(s)], 'color', map(i,:) );
    hold on; plot(ims_db_temperature.(s).time(ind_period) ,ims_db_temperature.(s).temperature_near_ground(ind_period), '-.', 'DisplayName', ['near ground - ' char(s)] , 'color', map(i,:) );
end
title('temperture'); xlabel('date and time'); ylabel('Celsius');

%% plot 2 channels of the same link + ims data

map = distinguishable_colors(21);
for i = order_hop_num
    if ( i == 14 && true) %exclude junc10_to_junc11 
        continue;
    end
    idx = meta_data.hop_num == i;
    channel_names = meta_data.link_name(idx);
    figure('DefaultAxesFontSize',10);
    for n = 1:length(channel_names)
        cn = char(channel_names(n));
        ind_period = db.(cn).time_rssi > ds & db.(cn).time_rssi < de;
        subplot(2,1,1);
        hold on; plot( db.(cn).time_rssi(ind_period) , db.(cn).rssi(ind_period) , 'DisplayName', ['link ' num2str(n)] , 'color' , map(n,:) );
        title([ 'hop' num2str(i), ', ' num2str(meta_data{(cn),'length_KM'}) 'Km' ] , 'FontSize', 20); 
    end
    
    subplot(2,1,2);
    ind_period = ims_db.beit_dagan.time > ds & ims_db.beit_dagan.time <de;
    hold on; plot( ims_db.beit_dagan.time(ind_period) , ims_db.beit_dagan.temperature(ind_period), 'k' , 'DisplayName', 'temperature'); 
    hold on; plot( ims_db.beit_dagan.time(ind_period) , ims_db.beit_dagan.temperature_near_ground(ind_period) ,'--', 'DisplayName', 'temperature_near_ground');
    hold on; plot ( ims_db.beit_dagan.time(ind_period) , ims_db.beit_dagan.temperature_near_ground(ind_period) - ims_db.beit_dagan.temperature(ind_period), 'DisplayName', 'diff');
    
%     subplot(5,1,3);
%     hold on; plot( ims_db.beit_dagan.time(ind_period) , ims_db.beit_dagan.rh(ind_period) ,'--', 'DisplayName', 'rh');
%     
%     subplot(5,1,4);
%     hold on; plot( ims_db.beit_dagan.time(ind_period) , ims_db.beit_dagan.wind_speed(ind_period) ,'--', 'DisplayName', 'wind_speed');
%     hold on; plot( ims_db.beit_dagan.time(ind_period) , ims_db.beit_dagan.speed_of_the_upper_wind(ind_period) ,'--', 'DisplayName', 'speed_of_the_upper_wind');
%     
%     subplot(5,1,5);
%     ind_period = gamliel_db.time >ds & gamliel_db.time <de;
%     hold on; plot( gamliel_db.time(ind_period) , gamliel_db.rain(ind_period) ,'--', 'DisplayName', 'rain');
  
end

%% plot all signals of hops: 

bias = 0;
map = distinguishable_colors(21);
for i = order_hop_num
    if ( i == 14 && false) %exclude junc10_to_junc11 
        continue;
    end
    idx = meta_data.hop_num == i;
    channel_names = meta_data.link_name(idx);
    for n = 1:length(channel_names)
        figure('name',[ 'hop' num2str(i), ' link' num2str(n), ' - ' num2str(meta_data{(cn),'length_KM'}*1000) ' m']);
        cn = char(channel_names(n));
        subplot(4,1,1);
        ind_period = db.(cn).time_rssi > ds & db.(cn).time_rssi<de;
        %A = (db.(cn).rssi(ind_period) - db.(cn).avg_rsl);
        %A = A/meta_data{cn, 'length_KM'}; % normalize dm to dbm.
        plot( db.(cn).time_rssi(ind_period) , db.(cn).rssi(ind_period),  'DisplayName', 'rssi');
        
        subplot(4,1,2);
        ind_period = db.(cn).time_cinr > ds & db.(cn).time_cinr<de;
        plot( db.(cn).time_cinr(ind_period) , db.(cn).cinrAVG(ind_period) ,'DisplayName', 'cinrAVG' );
        
        subplot(4,1,3);
        ind_period = db.(cn).time_mod > ds & db.(cn).time_mod<de;
        plot( db.(cn).time_mod(ind_period) , db.(cn).modulation(ind_period),'DisplayName', 'modulation');
        
        subplot(4,1,4);
        ind_period = db.(cn).time_radio > ds & db.(cn).time_radio<de;
        plot( db.(cn).time_radio(ind_period) , db.(cn).radio_throughput(ind_period), 'DisplayName', 'radio_throughput');
    end
end


