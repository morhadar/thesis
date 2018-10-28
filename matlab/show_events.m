
%% choose dates
switch (0)
    case 0;     ds = datetime(2018,01,01,00,00,00); de = datetime();                        %all period
    case 0.1;   ds = datetime(2018,02,15,00,00,00); de = datetime(2018,03,20,00,00,00);     %data1
    case 0.2;   ds = datetime(2018,03,19,11,00,00); de = datetime(2018,05,03,23,59,59);     %data2
    case 0.3;   ds = datetime(2018,09,01,00,00,00); de = datetime(2018,09,30,23,59,59);     %data3 - september
 
    case 1.21;  ds = datetime(2018,02,16,00,00,00); de = datetime(2018,02,17,20,00,00);     %February, 17
    case 1.22;  ds = datetime(2018,02,22,00,00,00); de = datetime(2018,02,22,05,00,00);     %February, 22
    case 1.23;  ds = datetime(2018,02,27,00,06,00); de = datetime(2018,02,27,08,00,00);     %February, 27 
    case 1.31;  ds = datetime(2018,03,28,04,00,00); de = datetime(2018,03,28,07,00,00);     %March, 28 - too weak
    case 1.32;  ds = datetime(2018,03,29,00,00,00); de = datetime(2018,03,30,23,59,59);     %March, 29 - too strong, killed the links
    case 1.41;  ds = datetime(2018,04,10,00,00,00); de = datetime(2018,04,11,23,00,00);     %April, 10-11 
    case 1.42;  ds = datetime(2018,04,22,00,00,00); de = datetime(2018,04,22,07,00,00);     %April, 22
    case 1.43;  ds = datetime(2018,04,25,00,00,00); de = datetime(2018,04,25,23,00,00);     %April, 25 !!! 
    case 1.44;  ds = datetime(2018,04,26,00,00,00); de = datetime(2018,04,26,23,00,00);     %April, 26
    case 1.51;  ds = datetime(2018,05,07,04,00,00); de = datetime(2018,05,07,07,00,00);     %May, 7 - no data
    case 1.52;  ds = datetime(2018,05,12,00,00,00); de = datetime(2018,05,12,07,00,00);     %May, 12 - no data
    case 1.53;  ds = datetime(2018,05,12,00,00,00); de = datetime(2018,05,12,14,00,00);     %May, 12 - no data
    case 1.61;  ds = datetime(2018,06,12,00,00,00); de = datetime(2018,06,12,23,59,59);     %June, 12
    case 1.62;  ds = datetime(2018,06,13,00,00,00); de = datetime(2018,06,13,23,59,59);     %June, 13 
    case 1.9;   ds = datetime(2018,09,08,00,00,00); de = datetime(2018,09,08,23,59,59);     %September, 8
    
    case 2;     ds = datetime(2018,03,03,00,00,00); de = datetime(2018,03,17,00,00,00);     %dry March
    case 2.1;   ds = datetime(2018,04,01,00,00,00); de = datetime(2018,05,05,00,00,00);     %dry April-May   
    case 2.2;   ds = datetime(2018,02,28,00,00,00); de = datetime(2018,03,14,00,00,00);     %dry
    case 2.3;   ds = datetime(2018,09,11,00,00,00); de = datetime(2018,09,25,00,00,00);     %dry september + yum kipur
         
    case 3 ;    ds = datetime(2018,03,05,00,00,00); de = datetime(2018,03,07,23,59,59);     %24h *3 
    case 3.1;   ds = datetime(2018,03,19,00,00,00); de = datetime(2018,03,20,23,59,59);     %weird event - link11    
    case 3.2;   ds = datetime(2018,02,22,00,00,00); de = datetime(2018,02,23,00,00,00);     %weird event 
    case 3.3;   ds = datetime(2018,03,21,00,00,00); de = datetime(2018,03,26,23,59,59);     %periodicity 
    case 3.4;   ds = datetime(2018,03,21,00,00,00); de = datetime(2018,03,24,23,59,59);     %summer clock
        
    case 11;    ds = datetime(2018,01,01,00,00,00); de = datetime(2018,01,31,23,59,59);
    case 22;    ds = datetime(2018,02,01,00,00,00); de = datetime(2018,02,28,23,59,59);
    case 33;    ds = datetime(2018,03,01,00,00,00); de = datetime(2018,03,31,23,59,59);
    case 44;    ds = datetime(2018,04,01,00,00,00); de = datetime(2018,04,30,23,59,59);
    case 55;    ds = datetime(2018,05,01,00,00,00); de = datetime(2018,05,31,23,59,59);
    case 66;    ds = datetime(2018,06,01,00,00,00); de = datetime(2018,06,30,23,59,59);
    case 77;    ds = datetime(2018,07,01,00,00,00); de = datetime(2018,07,31,23,59,59);
    case 88;    ds = datetime(2018,08,01,00,00,00); de = datetime(2018,08,31,23,59,59);
    case 99;    ds = datetime(2018,09,01,00,00,00); de = datetime(2018,09,30,23,59,59);
end

%% choose hops
switch (3.3)
    case 0;     hops = (unique(meta_data.hop_num, 'stable'))';     %by length ascending    
    case 1;     hops = [5 2 4 7 8 9 10 11 19 21 6  15 20 17 18];   %partial north to south   
    case 2;     hops = [2 1 20 17 18];                             %partial west to east
    case 3;     hops = [17 7 22 8 10 5 15 16 3 19 11 9];           %periodicity  - length ascending
    case 3.1;   hops = [1 13 23 12 18 24 2 20 4 6 21 ];            %periodicity (weak) - length ascending
    case 3.2;   hops = [7 5 15 16];            %periodicity (very visible!!!) - length ascending
    case 3.3;   hops = [7 5];            %periodicity (very visible!!!) - length ascending
    case 4;     hops = [ 1, 2, 3, 4,5 ,6 ,7 ,12 ,16  ];            %links cant see first peak of februar rain.   
    case 5;     hops = [5];                                           
end

%% plot attenuation of hops: 

figure;
bias = 0;
map = distinguishable_colors(24);
for i = hops
    if ( i == 14 && true) %exclude junc10_to_junc11 
        continue;
    end
    idx = meta_data.hop_num == i;
    channel_names = meta_data.link_name(idx);
    for n = 1:size(channel_names,1)
        cn = char(channel_names(n));
        ind_period = db.(cn).time_rssi > ds & db.(cn).time_rssi<de;
        hold on;
        A = (db.(cn).rssi(ind_period) - db.(cn).rsl_median(ind_period));
        A = conv(A, ones(1,20)/20 , 'same');
        %A = conv( A , [0, 1 -1] , 'same');
        %A = A/meta_data{cn, 'length_KM'}; % normalize dm to dbm.
        bias = bias +5;
        subplot(2,1,1);
        hold on; plot( db.(cn).time_rssi(ind_period) , A - bias, 'DisplayName', ['hop' num2str(i), ' link' num2str(n)] , 'color', map(i,:)) ;
        title([ char(ds) ' - ' char(de)]);
    end
end

%add ims data in subplot
% % subplot(2,1,2);
% % hold on; plot( ims_db_clouds.beit_dagan_m.time(ind_period) , ims_db_clouds.beit_dagan_m.height_lower_clouds(ind_period) ,'*', 'DisplayName' , 'height lower clouds' );
% % hold on; plot( ims_db_clouds.beit_dagan_m.time(ind_period) , ims_db_clouds.beit_dagan_m.type_lower_clouds(ind_period) ,'*', 'DisplayName' , 'type lower clouds' );
% % hold on; plot( ims_db.beit_dagan.time(ind_period) , ims_db.beit_dagan.wind_speed(ind_period), 'DisplayName' , 'wind speed' );
subplot(2,1,2);
ind_period = ims_db.beit_dagan.time > ds & ims_db.beit_dagan.time < de;
hold on; plot( ims_db.beit_dagan.time(ind_period) ,ims_db.beit_dagan.temperature(ind_period) , 'DisplayName' , 'temparature' );
hold on; plot( ims_db.beit_dagan.time(ind_period) ,ims_db.beit_dagan.temperature_near_ground(ind_period) , 'DisplayName' , 'temperature near ground' );
hold on; plot( ims_db.beit_dagan.time(ind_period) , ims_db.beit_dagan.wind_speed(ind_period) ,'*', 'DisplayName' , 'wind speed' );
hold on; plot( ims_db.beit_dagan.time(ind_period) ,ims_db.beit_dagan.temperature_near_ground(ind_period) - ims_db.beit_dagan.temperature(ind_period) , 'DisplayName' , 'diff' );

%hold on; plot( ims_db.beit_dagan.time(ind_period) , ims_db.beit_dagan.wind_direction(ind_period) ,'*', 'DisplayName' , 'wind direction' );
hold on; plot( ims_db.beit_dagan.time(ind_period) , ims_db.beit_dagan.rh(ind_period) ,'*', 'DisplayName' , 'rh' );


ind_period = ims_db_clouds.beit_dagan_m.time > ds & ims_db_clouds.beit_dagan_m.time<de;
hold on; plot( ims_db_clouds.beit_dagan_m.time(ind_period) , ims_db_clouds.beit_dagan_m.total_clouds(ind_period) ,'*', 'DisplayName' , 'Total clouds' );
hold on; plot( ims_db_clouds.beit_dagan_m.time(ind_period) , ims_db_clouds.beit_dagan_m.total_lower_clouds(ind_period) ,'*',  'DisplayName' , 'Total lower clouds' );


%% plot rain gaues 
stations = ["beit_dagan" , "hafetz_haim" , "nahshon" , "kvotzat_yavne"];

figure;
title('rainy days');
xlabel('date and time');
ylabel('R mm/h');
for i = 1:4
    s = stations(i);
    ind_period = ims_db.(s).time > ds & ims_db.(s).time<de;
    hold on; plot(ims_db.(s).time(ind_period) ,ims_db.(s).rain(ind_period) * 6, 'DisplayName', s);
end
%ind = gamliel_db.time  > ds & gamliel_db.time <de;
%hold on; plot( gamliel_db.time(ind) , gamliel_db.rain(ind) *6 , 'DisplayName' , 'gamliel', 'LineWidth', 2);

% add constraints:
hold on; plot( ds:seconds(30):de , 0.4*ones(size(ds:seconds(30):de)) , 'DisplayName' , 'lowerbound', 'color' , 'r', 'LineWidth', 2);
hold on; plot( ds:seconds(30):de , 40*ones(size(ds:seconds(30):de)) , 'DisplayName' , 'upperbound', 'color' , 'g', 'LineWidth' ,2);
if(true) % add minimal threshold for specific links
    for i = hops
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

map = distinguishable_colors(3); %max 2 links for hop. but for hop1 there are 3 links.
for i = hops
    if ( i == 14 && true) %exclude junc10_to_junc11 
        continue;
    end
    idx = meta_data.hop_num == i;
    channel_names = meta_data.link_name(idx);
    figure('DefaultAxesFontSize',10);
    for n = 1:size(channel_names,1)
        cn = char(channel_names(n));
        ind_period = db.(cn).time_rssi > ds & db.(cn).time_rssi < de;
     %   subplot(2,1,1);
        %yyaxis left;
        hold on; plot( db.(cn).time_rssi(ind_period) , db.(cn).rssi(ind_period) , 'DisplayName', ['link ' num2str(n)] , 'color' , map(n,:) );
        title([ num2str(i) ' -- ' cn  ' , ' num2str(meta_data{(cn) ,'length_KM'}) 'Km' ] , 'FontSize', 20 , 'Interpreter', 'none'); 
    end
    fig_name = [ 'RSSI__' cn  '__' num2str(meta_data{(cn) ,'length_KM'}) 'Km' '.jpg' ];
    %saveas(gcf , ['../../thesis_materials/crops2/' fig_name]); 
    
    %subplot(2,1,2);
    ind_period = ims_db_clouds.beit_dagan_m.time > ds & ims_db_clouds.beit_dagan_m.time < de;
    %yyaxis right;
    %hold on; plot( ims_db_clouds.beit_dagan_m.time(ind_period) , ims_db_clouds.beit_dagan_m.total_clouds(ind_period)/8);
    %hold on; plot( ims_db_clouds.beit_dagan_m.time(ind_period) , ims_db_clouds.beit_dagan_m.total_lower_clouds(ind_period)/8 );
    
    
    
    %subplot(2,1,2);
%   ind_period = ims_db.beit_dagan.time > ds & ims_db.beit_dagan.time <de;
%     hold on; plot( ims_db.beit_dagan.time(ind_period) , ims_db.beit_dagan.temperature(ind_period), 'k' , 'DisplayName', 'temperature'); 
%     hold on; plot( ims_db.beit_dagan.time(ind_period) , ims_db.beit_dagan.temperature_near_ground(ind_period) ,'--', 'DisplayName', 'temperature_near_ground');
%     hold on; plot ( ims_db.beit_dagan.time(ind_period) , ims_db.beit_dagan.temperature_near_ground(ind_period) - ims_db.beit_dagan.temperature(ind_period), 'DisplayName', 'diff');
%     
%     subplot(5,1,3);
%     hold on; plot( ims_db.beit_dagan.time(ind_period) , ims_db.beit_dagan.rh(ind_period) ,'--', 'DisplayName', 'rh');
%     
%      subplot(3,1,3);
%      hold on; plot( ims_db.beit_dagan.time(ind_period) , ims_db.beit_dagan.wind_speed(ind_period) ,'--', 'DisplayName', 'wind_speed', );
%      hold on; plot( ims_db.beit_dagan.time(ind_period) , ims_db.beit_dagan.speed_of_the_upper_wind(ind_period) ,'--', 'DisplayName', 'speed_of_the_upper_wind');
%      

%      subplot(4,1,4);
%      ind_period = gamliel_db.time >ds & gamliel_db.time <de;
%      hold on; plot( gamliel_db.time(ind_period) , gamliel_db.rain(ind_period) ,'--', 'DisplayName', 'rain');
  
end

%% plot all signals of hops: 

bias = 0;
map = distinguishable_colors(24);
for i = hops
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


