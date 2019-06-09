clc; clear all;
%% load data;
%load('meta_data.mat');
%load( 'db_old_data_dont_delete.mat'); %db with old names
load( 'db.mat'); %in old data i replaced -128 with nan. 
% db_ceragon = load('ceragon.mat' ); 
% load( 'ericsson_db');
% load( 'db_kfar_saba)';
% load( 'ericsson_januray_horiz_polarization.mat');

load('ims_db.mat');
load('ims_db_clouds.mat');
load('gamliel.mat');
load( 'suntime_db.mat' );

%% parameters
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
freq24hours = 1/(24*60*60); %Hz
harmonics = 1:7;
freq_harmonics = 1./((24./harmonics).*3600);
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
    L = meta_data.length_KM(idx);
    A = alpha .* (r .^ beta).* L;
    hold on; plot(r,A,'DisplayName' , ['hop:' num2str(i) ': ' num2str(L) 'km'] ,'color', map(i,:));
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
for i = 1:24%(unique(meta_data.hop_num, 'stable'))'
    idx = meta_data.hop_num == i;
    L = meta_data.length_KM(idx); L = L(1); % both channels with the same length
    A = alpha .* (r .^ beta).* L;
    ind = find(A > quant, 1);
    meta_data.minimal_rain_rate(idx) = r(ind)*ones( size(meta_data.minimal_rain_rate(idx)) );
end
save('meta_data.mat', 'meta_data');

%% plot links on map
% figure; title('map');
% for i = [1 15, 18] %1:size(meta_data,1)
%    hold on; plot(   [meta_data.transmitter_longitude(i), meta_data.receiver_longitude(i)] ,...
%                     [meta_data.transmitter_latitude(i), meta_data.receiver_latitude(i)], ...
%                     'MarkerSize', 50, 'DisplayName',[num2str(meta_data.length_KM(i)*1000) ' m'] );
%    %legend( [num2str(meta_data.length_KM(i)*1000) ' m']); 
% end
% plot_google_map

 
%% AVG
map = distinguishable_colors(21);
win_size = (2*60*24)*10; %samples in day * num_of_days.
for i = (unique(meta_data.hop_num, 'stable'))'
    idx = meta_data.hop_num == i;
    channel_names = meta_data.link_name(idx);
    for n = 1:size(channel_names,1)
        cn = char(channel_names(n));
        if ( ~isfield(db ,cn) ); continue; end
        %AVG
        db.(cn).rsl_median = movmedian(db.(cn).rssi, win_size,'omitnan');
        db.(cn).rsl_mean = movmean(db.(cn).rssi, win_size,'omitnan');
        db.(cn).avg = db.(cn).rsl_mean;
    end
end

%% STD
for i = (unique(meta_data.hop_num, 'stable'))'
    idx = meta_data.hop_num == i;
    channel_names = meta_data.link_name(idx);
    for n = 1:length(channel_names)
        cn = char(channel_names(n));
        if( ~isfield( db, cn)); continue; end
        %STD
        N = length(db.(cn).rssi);
        diff = (db.(cn).rssi - db.(cn).avg);
        db.(cn).variance =  1/N * sum( diff.^2 , 'omitnan' );
        db.(cn).std = sqrt(db.(cn).variance);
        
        ind_up = diff >= 0;
        db.(cn).variance_up = 1/length(diff(ind_up))* sum(diff(ind_up).^2 , 'omitnan');
        db.(cn).std_up = sqrt(db.(cn).variance_up);
        
        ind_down = diff <= 0;
        db.(cn).variance_down = 1/length(diff(ind_down)) * sum( diff(ind_down).^2 , 'omitnan');
        db.(cn).std_down = sqrt(db.(cn).variance_down);
    end 
end
%save('db.mat', 'db' , '-append');

%% calc free space path loss 
meta_data.fspl = fspl(meta_data.length_KM* 1000 , lambda ); %[db]

%Fersnel zone 
n = 1; 
%mid_path_radius = 0.5 * sqrt(n*lambda*d) ;
mid_path_radius = 8.656* sqrt( meta_data.length_KM ./ frequency); %[m]

%% init structs:
for i = (unique(meta_data.hop_num, 'stable'))'
    idx = meta_data.hop_num == i;
    channel_names = meta_data.link_name(idx);
    for n = 1:length(channel_names)
        cn = char(channel_names(n));
        db.(cn).freq_amp = nan(length(harmonics) , 12);
    end
end




