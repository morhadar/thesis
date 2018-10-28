clc; clear all;
%% load data;
load('meta_data.mat');
load('db.mat' , 'db');
load('ims_db.mat');
load('ims_db_clouds.mat');
load('gamliel.mat');

% System properties:
frequency = 74.875; %[GHz]
f_hertz = frequency * 1e9; %[Hz]
lambda  = ( physconst('LightSpeed')/f_hertz ); %[m]
polarization = 1; %1-vertical, 0-horizontal.
beta = ITU_aRb2_b(polarization,frequency);
alpha = ITU_aRb2_a(polarization,frequency);
delta = 0.5; %TSL is moving ranging between [const - delta , const + delta]
quant = 1; %[db]
time_quant = 30; %[sec]

% others
freq24hours = 1/(24*60*60);
T = 20; %[celsious]
P = 100 *1000; %[Pa]
W = 7.5; %[g/m^3] water density.
gas_attenuation = gaspl( 170, f_hertz ,T, P, W );

%% system constraints/limitations:
%droplet size:
lambda ; %TODO - need to find dormula for this.

%quntization differences:
x = -2:0.001:2;
y = round(x+delta) - round(x-delta); % differences posible between two RSL samples. note: round(0.5)=1, round(-0.5)=-1
% do something generic with linspace and Nearest neighbour interpolation instead of round function.
figure; plot(x,y); xlabel('rsl const'); title('differences posible between two RSL samples in a system with no attenuation');

% power law
l = 1e-2:1e-2:2;%[km]
r = 0:0.1:100; %[mm/h]. resolution of the imd data is 0.1 therfore it is enought.
[L,R] = meshgrid(l,r);
A = alpha.* (R.^beta) .*L;
figure; mesh(L,R,A); 

map = distinguishable_colors(21);
figure;
for i = (unique(meta_data.hop_num, 'stable'))'
    idx = meta_data.hop_num == i;
    idx = find(idx,1);
    length = meta_data.length_KM(idx);
    A = alpha .* (r .^ beta).* length;
    hold on; plot(r,A,'DisplayName' , ['hop:' num2str(i) ': ' num2str(length) 'km'] ,'color', map(i,:));
end
hold on; plot( r , quant*ones( size(r)  ) , 'color', 'r', 'DisplayName' , '1db');
xlabel('R [mm/h]'); ylabel('attenuation');

%wind velocity
wind_velocity = 0:0.1:20; %[m/s]
distance_between_links = wind_velocity.*time_quant;
figure; plot( wind_velocity , distance_between_links); 
title('distance required between 2 hops in order to observe wind velocity given 30 seconds time quantization');
xlabel('wind velocity [m/s]');
ylabel('distance required [m]');


%% calculate minimal rain rate for each link
r = 0:0.1:100; %[mm/h]. resolution of the imd data is 0.1 therfore it is enought.
meta_data.minimal_rain_rate = nan( size(meta_data,1) ,1);
for i = (unique(meta_data.hop_num, 'stable'))'
    idx = meta_data.hop_num == i;
    length = meta_data.length_KM(idx); length = length(1); % both channels with the same length
    A = alpha .* (r .^ beta).* length;
    ind = find(A > quant, 1);
    meta_data.minimal_rain_rate(idx) = r(ind)*ones( size(meta_data.minimal_rain_rate(idx)) );
end
save('meta_data.mat', 'meta_data');

%% plot links on map
figure; title('map');
for i = [1 15, 18] %1:size(meta_data,1)
   hold on; plot(   [meta_data.transmitter_longitude(i), meta_data.receiver_longitude(i)] ,...
                    [meta_data.transmitter_latitude(i), meta_data.receiver_latitude(i)], ...
                    'MarkerSize', 50, 'DisplayName',[num2str(meta_data.length_KM(i)*1000) ' m'] );
   %legend( [num2str(meta_data.length_KM(i)*1000) ' m']); 
end
plot_google_map

%% AVG RSSI - during dry period
% ds = datetime(2018,03,01,00,00,00); de = datetime(2018,03,15,23,00,00);
% for i = 1:length(meta_data.link_name)
%     cn = char(meta_data.link_name(i));
%     ind = db.(cn).time_rssi > ds & db.(cn).time_rssi<de;
%     db.(cn).avg_rsl_during_dry_period = mean(db.(cn).rssi(ind));
% end
%     
%% AVG RSSI - moving mean/median
ds = datetime(2018,01,01,00,00,00); de = datetime();
map = distinguishable_colors(21);
for i = 1:size(meta_data.link_name,1)
    cn = char(meta_data.link_name(i));
    ind = db.(cn).time_rssi > ds & db.(cn).time_rssi<de;
    win_size = (2*60*24)*10; %samples in day * num_of_days.
    db.(cn).rsl_median = zeros(sum(ind) ,1);
    db.(cn).rsl_mean = zeros(sum(ind) ,1);
    db.(cn).rsl_median(ind) = movmedian(db.(cn).rssi(ind), win_size,'omitnan');
    db.(cn).rsl_mean(ind) = (movmean(db.(cn).rssi(ind), win_size,'omitnan'))'; 
    %subplot(2,1,n);
    %hold on; plot( db.(cn).time_rssi(ind) , db.(cn).rssi(ind), 'DisplayName' , 'RSSI' );  
    %hold on; plot(db.(cn).time_rssi(ind) , db.(cn).rsl_median(ind), 'DisplayName', 'median');
    %hold on; plot(db.(cn).time_rssi(ind) , db.(cn).rsl_mean(ind), 'DisplayName', 'mean');
    %title(['hop ' num2str(hop_num) ' -- ' cn ' -- ' num2str(meta_data{(cn),'length_KM'}) 'Km ,']);
end 
save('db.mat', 'db' , '-append');
clear ds de
%% calc standart deviation
for i = 1:size(meta_data.link_name,1)
    cn = char(meta_data.link_name(i));
    N = length(db.(cn).rssi);
    db.(cn).variance =  1/N * sum( (db.(cn).rssi - db.(cn).rsl_median).^2 , 'omitnan' );
    db.(cn).standart_deviation = sqrt(db.(cn).variance);
end
%save('db.mat', 'db' , '-append' );

%% calc free space path loss 
meta_data.fspl = fspl(meta_data.length_KM* 1000 , lambda ); %[db]

%Fersnel zone 
n = 1; 
%mid_path_radius = 0.5 * sqrt(n*lambda*d) ;
mid_path_radius = 8.656* sqrt( meta_data.length_KM ./ frequency); %[m]





