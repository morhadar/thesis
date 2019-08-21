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
        %rsl = rsl/meta_data{hop, 'length'}; % normalize dm to dbm.
        t = datetime(db.(hop).(char(direction)).raw(:,1), 'ConvertFrom', 'posixtime') ;
        hold on; plot( t(t > ds & t < de) , rsl(t > ds & t < de), 'DisplayName', [hop ' ' direction] , 'color', map(i,:));
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
        t = datetime(db.(hop).(char(direction)).raw(:,1), 'ConvertFrom', 'posixtime') ;
        hold on; plot( t(t > ds & t < de) , rsl(t > ds & t < de), 'DisplayName', [hop ' ' direction] , 'color', map(i,:));
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
    %TODO - align ims direction to estimated direction!!! 
    subplot(3,3,9); title('wind direction'); xlabel('date and time'); ylabel('|v| m/s'); 
    hold on; plot(ims_db.(s).time(ind_period) ,ims_db.(s).wind_direction(ind_period) ,'DisplayName', s , 'color' , map(k,:));
    %TODO  - how to add errorbar for this the 'std_wind_direction' ;
    hold on; plot(ims_db.(s).time(ind_period) ,ims_db.(s).direction_of_the_upper_wind(ind_period), '--', 'DisplayName', s, 'color' , map(k,:));
end
clear fn k
%% cross correlation
hops = pick_hops(2);
N_links = length(hops);
N_samples = minutes(de-ds) * 2;
X = zeros(N_samples , length(hops));
figure;
for i = 1:N_links
    hop = char(hops(i));
    directions = fieldnames(db.(hop));
    for j = 1%1:length(directions) %{'up' ,'down'} %TODO  take also the second direction!
        direction = char(directions(j));
        rsl = db.(hop).(char(direction)).raw(:,2);
        avg = db.(hop).(direction).mean;
        rsl = rsl - avg; %TODO make sure that I need it.
        t = datetime(db.(hop).(char(direction)).raw(:,1), 'ConvertFrom', 'posixtime') ;
        ind = t > ds & t < de;
        if( sum(ind)==0 ); continue; end
        ts = timeseries( rsl(ind) , datestr( t(ind) ) );
        tmp =  resample(ts , datestr(ds:seconds(30):de));
        X(:,i) = tmp.Data(1:end-1) - mean(tmp.Data(1:end-1), 'omitnan');
        hold on; 
        plot( tmp.Data(1:end-1) , 'DisplayName' , num2str(hop) );
    end
end


%exclude empty links.
valid_hops = any(X); 
new_X = X(:,valid_hops);
new_hops = hops(valid_hops);
new_N_links = length(new_hops);

%exclude NaN samples at the beginig and ending of sequence:
new_X = new_X(85:N_samples-11 , :);

%compute cross-correlation between all links:
[R,lag] = xcorr(new_X);
auto_correlation = R(: , 1:new_N_links:end ); %TODO - check why for some links the autocorrelation is not symetric.
cross_correlation = R;
cross_correlation(: , 1:new_N_links:end ) = [];
[~,I] = max(abs(R));
delay_estimated = lag(I);
tau = reshape(delay_estimated , [new_N_links , new_N_links ])';
any(any(tau' +tau)) %sanity check: 0 is the wanted result.

figure; plot( lag,auto_correlation ); title('auto correaltion');
figure; plot( lag,cross_correlation ); title('cross correaltion');

clear hops N X hop direction tmp ts rsl t

%% MLE using grid search.
%calc geometry:
distance = zeros(size(tau));
phi = zeros(size(tau));
figure;
hold on;
for r = 1:new_N_links
    for c = 1:new_N_links
        tau(r , c);
        link1_name = char(new_hops(r));
        link2_name = char(new_hops(c));
        x1 = meta_data.x_center(link1_name);
        y1 = meta_data.y_center(link1_name);
        x2 = meta_data.x_center(link2_name);
        y2 = meta_data.y_center(link2_name);
        distance(r,c) = sqrt( sum( (x1-x2).^2 + (y1-y2).^2)) ;
        phi(r,c) =  atand( (y2 - y1) / (x2 - x1));
        if (phi(r,c)<0)
            phi(r,c) = 180 + phi(r,c);
        end
        
        plot( [x1 x2] , [y1 y2]  , 'DisplayName' , [link1_name ' -> ' link2_name ]);
        text( mean([x1 x2]) , mean([y1 y2]), num2str(phi(r,c)) );

        %for plotting links as well:
%         site1 = char(meta_data.site1(link1_name));
%         site2 = char(meta_data.site2(link1_name));
%         ind1 = strcmp(geo_location.site_name, site1);
%         y1 = geo_location.latitude(ind1);
%         x1 = geo_location.longitude(ind1);
%         ind2 = strcmp(geo_location.site_name, site2);
%         y2 = geo_location.latitude(ind2);
%         x2 = geo_location.longitude(ind2);
%         plot( [x1 x2] , [y1 y2], 'LineStyle' , '--');
%         
%         site1 = char(meta_data.site1(link2_name));
%         site2 = char(meta_data.site2(link2_name));
%         ind1 = strcmp(geo_location.site_name, site1);
%         y1 = geo_location.latitude(ind1);
%         x1 = geo_location.longitude(ind1);
%         ind2 = strcmp(geo_location.site_name, site2);
%         y2 = geo_location.latitude(ind2);
%         x2 = geo_location.longitude(ind2);
%         plot( [x1 x2] , [y1 y2], 'LineStyle' , '--');
    end
end
hold off;

phi_vec = phi(:);
tau_vec = tau(:);
distance_vec = distance(:);

nan_position = isnan(phi_vec);
phi_vec = phi_vec(~nan_position);
tau_vec = tau_vec(~nan_position);
distance_vec = distance_vec(~nan_position);

residual = @(x) tau_vec - (distance_vec/x(1)) .* sind(phi_vec - x(2));
v0 = 5;
alpha0 = 45;
x = lsqnonlin(residual,[v0 alpha0]);
v = x(1)
alpha = x(2)

clear r c 


