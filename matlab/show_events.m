%% pick hops and dates
hops = pick_hops(meta_data, 0);
[ds ,de] = pick_rain_event(93);
%% plot attenuation of hops: 
bias = 0;
active_links_during_the_event = false( length(hops),1);
%nn=1;

figure; title([ char(ds) ' - ' char(de)]);
subplot(1,3,[1 2]); 
hold on; 
time_axis = ds:seconds(30):de;
for i = 1:length(hops)
    hop = char(hops(i));
    hop_ID = meta_data.hop_ID(hop);
    %subplot(length(hops)+1,1,nn);
    %nn = nn+1;
    directions = fieldnames(db.(hop));
    for j = 1:length(directions) %{'up' ,'down'}
        direction = char(directions(j));
        rsl = db.(hop).(char(direction)).raw(:,2);
        %rsl = conv(rsl, ones(1,20)/20 , 'same'); %smoothing 2 min samples
        %rsl = conv( rsl , [0, 1 -1] , 'same');
        %rsl = rsl/meta_data{hop, 'length'}; % normalization
        mean_rsl = db.(hop).(direction).mean;
        yy = rsl - mean_rsl;
        tt = datetime(db.(hop).(char(direction)).raw(:,1), 'ConvertFrom', 'posixtime') ;
        ind_period = tt > ds & tt < de;
        yy = yy(ind_period);
        tt = tt(ind_period);
        if( ~any(ind_period)); continue; end
        active_links_during_the_event(i) = true;
%         ts  = timeseries( yy , datestr( tt ) );
%         ts_new = ts.resample(datestr(time_axis),'zoh' );
% 
%         plot( time_axis    , ts_new.Data - bias   , 'DisplayName', [num2str(hop_ID) '-' hop ' ' direction] , 'color', map_color_by_hop(hop_ID,:));
%         text( time_axis(1) , ts_new.Data(1) - bias, num2str(hop_ID),'color', map_color_by_hop(hop_ID,:));
        plot( tt    , yy - bias , 'DisplayName', [num2str(hop_ID) '-' hop ' ' direction] , 'color', map_color_by_hop(hop_ID,:), 'LineWidth' , 0.1);
        text( tt(1) , yy(1) - bias, num2str(hop_ID),'color', map_color_by_hop(hop_ID,:));
        
        bias = bias +2;        
        xlim([ds de]);            
    end    
end
hold off;

fn = fieldnames(ims_db);
for k=1:numel(fn)
    s = char(fn(k));
    ind_period = ims_db.(s).time > ds & ims_db.(s).time<de;

    subplot(1,3,3); title('rain gauges'); ylabel('R mm/h');
    legend('show');  
    hold on; plot(ims_db.(s).time(ind_period) ,ims_db.(s).rain(ind_period) * 6, 'DisplayName', s, 'color' , map_color_by_station(k,:));
end
if any(active_links_during_the_event)
    subplot(1,3,3); hold on; plot( ds:seconds(30):de , (meta_data.minimal_rain_rate(active_links_during_the_event) * ones(size(ds:seconds(30):de)))' , 'HandleVisibility','off', 'color' , 'k'); %TODO give it the same color as the hop
end

%clear i j bias map nn directions direction A t mean rsl active_links_during_the_event fn k map s ind_period ts ts_new

%% plot measurments of IMS per station:
fn = fieldnames(ims_db);
map = distinguishable_colors(length(fn));
for k=1%1:numel(fn)
    figure;
    s = char(fn(k));
    ind_period = ims_db.(s).time > ds & ims_db.(s).time<de;

    legend('show'); 
    subplot(2,1,1);
    hold on; plot(ims_db.(s).time(ind_period) ,ims_db.beit_dagan.wind_speed(ind_period), 'r' , 'DisplayName', 'wind speed');
    hold on; plot(ims_db.(s).time(ind_period) ,ims_db.beit_dagan.speed_of_the_upper_wind(ind_period),'g',  'DisplayName', 'upper wind speed');
    %TODO - maybe time axis should be 
    hold on; plot(ims_db.(s).time(ind_period) ,ims_db.beit_dagan.max_wind_speed_1min(ind_period), 'b', 'DisplayName', 'max 1 min');
    hold on; plot(ims_db.(s).time(ind_period) ,ims_db.beit_dagan.max_wind_speed_10min(ind_period), 'k', 'DisplayName', 'max 10 min');

    subplot(2,1,2);
    
    hold on; plot(ims_db.(s).time(ind_period) ,ims_db.beit_dagan.wind_direction(ind_period),'r', 'DisplayName', 'wind direction' );
    hold on; plot(ims_db.(s).time(ind_period) ,ims_db.beit_dagan.wind_direction(ind_period) + ims_db.beit_dagan.std_wind_direction(ind_period),'--r', 'DisplayName', 'direction + std' );
    hold on; plot(ims_db.(s).time(ind_period) ,ims_db.beit_dagan.wind_direction(ind_period) - ims_db.beit_dagan.std_wind_direction(ind_period),'--r', 'DisplayName', 'direction - std' );

    hold on; plot(ims_db.(s).time(ind_period) ,ims_db.beit_dagan.direction_of_the_upper_wind(ind_period),'g', 'DisplayName', 'upper wind direction' );
end

clear fn map k s ind_period 
%% plot rain gaues 
stations = ["beit_dagan" , "hafetz_haim" , "nahshon" , "kvotzat_yavne"];

figure;
title('rainy days');
xlabel('date and time');
ylabel('R mm/h');
for i = 1%1:4
    s = stations(i);
    ind_period = ims_db.(s).time > ds & ims_db.(s).time<de;
    hold on; plot(ims_db.(s).time(ind_period) ,ims_db.(s).rain(ind_period) * 6, 'DisplayName', s);
end
%ind = gamliel_db.time  > ds & gamliel_db.time <de;
%hold on; plot( gamliel_db.time(ind) , gamliel_db.rain(ind) *6 , 'DisplayName' , 'gamliel', 'LineWidth', 2);

% add constraints:
% hold on; plot( ds:seconds(30):de , 0.4*ones(size(ds:seconds(30):de)) , 'DisplayName' , 'lowerbound', 'color' , 'r', 'LineWidth', 2);
% hold on; plot( ds:seconds(30):de , 40*ones(size(ds:seconds(30):de)) , 'DisplayName' , 'upperbound', 'color' , 'g', 'LineWidth' ,2);
% if(true) % add minimal threshold for specific links
%     for i = hops
%         idx = meta_data.hop_num == i;
%         idx = find(idx,1);
%         hold on; plot( ds:seconds(30):de , meta_data.minimal_rain_rate(idx)*ones(size(ds:seconds(30):de)) , 'DisplayName' , ['hop ' num2str(i) ' boundary'], 'color' , 'k');
%     end
% end

clear i s ind_period stations

%% plot north-south or east-west besides rain gauges:
figure;

hops = pick_hops(1);
map = distinguishable_colors(length(hops));
bias = 0;
subplot(3,3,[1 4 7]);
title('south to north');
for i = 1:length(hops)
    hop = char(hops(i));
    directions = fieldnames(db.(hop));
    for j = 1%1:length(directions) %{'up' ,'down'}
        direction = char(directions(j));
        rsl = db.(hop).(char(direction)).raw(:,2);
        avg = db.(hop).(direction).mean;
        rsl = rsl - avg - bias;
        %rsl = conv(rsl, ones(1,20)/20 , 'same'); %smoothing 2 min samples
        %rsl = conv( rsl , [0, 1 -1] , 'same');
        %rsl = rsl/meta_data{hop, 'length'};
        tt = datetime(db.(hop).(char(direction)).raw(:,1), 'ConvertFrom', 'posixtime') ;
        hold on; plot( tt(tt > ds & tt < de) , rsl(tt > ds & tt < de), 'DisplayName', [hop ' ' direction] , 'color', map(i,:));
        bias = bias +2;  
    end  
end

hops = pick_hops(2);
map = distinguishable_colors(length(hops));
bias = 0;
subplot(3,3,[2 5 8]);
title('west to east');
for i = 1:length(hops)
    hop = char(hops(i));
    directions = fieldnames(db.(hop));
    for j = 1%1:length(directions) %{'up' ,'down'}
        direction = char(directions(j));
        rsl = db.(hop).(char(direction)).raw(:,2);
        avg = db.(hop).(direction).mean;
        rsl = rsl - avg - bias;
        %rsl = conv(rsl, ones(1,20)/20 , 'same'); %smoothing 2 min samples
        %rsl = conv( rsl , [0, 1 -1] , 'same');
        %rsl = rsl/meta_data{hop, 'length'}; % normalize dm to dbm.
        tt = datetime(db.(hop).(char(direction)).raw(:,1), 'ConvertFrom', 'posixtime') ;
        hold on; plot( tt(tt > ds & tt < de) , rsl(tt > ds & tt < de), 'DisplayName', [hop ' ' direction] , 'color', map(i,:));
        bias = bias +2;  
    end  
end

fn = fieldnames(ims_db);
map = distinguishable_colors(length(fn));
for k=1:numel(fn)
    s = char(fn(k));
    ind_period = ims_db.(s).time > ds & ims_db.(s).time<de;

    subplot(3,3,3); title('rainy days'); xlabel('date and time'); ylabel('R mm/h');
    legend('show');  
    hold on; plot(ims_db.(s).time(ind_period) ,ims_db.(s).rain(ind_period) * 6, 'DisplayName', s, 'color' , map(k,:));
    hold on; plot( (meta_data.minimal_rain_rate * ones(size(ds:seconds(30):de)))' , 'HandleVisibility','off', 'color' , map(k,:)); 
    
    subplot(3,3,6); title('wind velocity'); xlabel('date and time'); ylabel('|v| m/s'); 
    hold on; plot(ims_db.(s).time(ind_period) ,ims_db.(s).wind_speed(ind_period), 'DisplayName', s, 'color' , map(k,:));
    hold on; plot(ims_db.(s).time(ind_period) ,ims_db.(s).speed_of_the_upper_wind(ind_period), '--', 'DisplayName', s,'color' , map(k,:));

    subplot(3,3,9); title('wind direction'); xlabel('date and time'); ylabel('|v| m/s'); 
    %minus 180 degrees in order to align with alpha. the original ims eind
    %directon is the angle from y axis from the the wind is comming from
    hold on; plot(ims_db.(s).time(ind_period) ,ims_db.(s).wind_direction(ind_period) - 180 ,'DisplayName', s , 'color' , map(k,:));
    hold on; plot(ims_db.(s).time(ind_period) ,ims_db.(s).direction_of_the_upper_wind(ind_period) -180, '--', 'DisplayName', s, 'color' , map(k,:));
end
clear fn k map s ind_period
