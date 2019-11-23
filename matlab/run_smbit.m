%% load data;
%load( 'db_old_data_dont_delete.mat'); %db with old names
load( 'db.mat'); %in old data i replaced -128 with nan. 
% db_ceragon = load('ceragon.mat' ); 
% load( 'ericsson_db');
% load( 'db_kfar_saba)';
% load( 'ericsson_januray_horiz_polarization.mat');

hop_link_mapping_file = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\smbit\meta_data_1.xlsx';
meta_data_file = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\smbit\meta_data_2.xlsx';

hop_link_mapping = readtable(hop_link_mapping_file, 'ReadVariableNames', true , 'ReadRowNames', true );
meta_data = readtable(meta_data_file, 'ReadVariableNames', true , 'ReadRowNames', true );
map_color_by_hop = distinguishable_colors( height(meta_data), {'w','k'});

load('ims_db.mat');
load('ims_db_clouds.mat');
% load('gamliel.mat');
% load( 'suntime_db.mat' );
map_color_by_station = distinguishable_colors(4);
stations = fieldnames(ims_db);

clear geo_location_file hop_link_mapping_file meta_data_file
%% outsource:
addpath(genpath('C:\Users\mhadar\Documents\personal\matlab_utils'))
%% parameters
% System properties:
frequency = 74.875; %[GHz]
f_hertz = frequency * 1e9; %[Hz]
lambda  = ( physconst('LightSpeed')/f_hertz ); %[m]
polarization = 1; %1-vertical, 0-horizontal.
powerlaw_beta = ITU_aRb2_b(polarization,frequency);
powerlaw_alpha = ITU_aRb2_a(polarization,frequency);
delta = 0.5; %TSL is moving ranging between [const - delta , const + delta]
quantization_error = 1; %[db]
time_quant = 30; %[sec]

% others
if(0)
freq24hours = 1/(24*60*60); %Hz
harmonics = 1:7;
freq_harmonics = 1./((24./harmonics).*3600);
T = 20; %[celsious]
P = 100 *1000; %[Pa]
W = 7.5; %[g/m^3] water density.
gas_attenuation = gaspl( 170, f_hertz ,T, P, W );
end
%% system constraints/limitations:
if(0)
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
A = powerlaw_alpha.* (R.^powerlaw_beta) .*L;
figure; mesh(L,R,A); 

map = distinguishable_colors(21);
figure;
for i = (unique(meta_data.hop_num, 'stable'))'
    idx = meta_data.hop_num == i;
    idx = find(idx,1);
    L = meta_data.length_KM(idx);
    A = powerlaw_alpha .* (r .^ powerlaw_beta).* L;
    hold on; plot(r,A,'DisplayName' , ['hop:' num2str(i) ': ' num2str(L) 'km'] ,'color', map(i,:));
end
hold on; plot( r , quantization_error*ones( size(r)  ) , 'color', 'r', 'DisplayName' , '1db');
xlabel('R [mm/h]'); ylabel('attenuation');

%wind velocity
wind_velocity = 0:0.1:20; %[m/s]
distance_between_links = wind_velocity.*time_quant;
figure; plot( wind_velocity , distance_between_links); 
title('distance required between 2 hops in order to observe wind velocity given 30 seconds time quantization');
xlabel('wind velocity [m/s]');
ylabel('distance required [m]');
end

%% calculate minimal rain rate for each link
r = 0:0.1:100; %[mm/h]. resolution of the ims data is 0.1 therfore it is enought.
meta_data.minimal_rain_rate = nan( size(meta_data,1) ,1);
for i = 1:length(meta_data.hop_name)
    if isnan(meta_data.length(i)); continue; end
    A = powerlaw_alpha .* (r .^ powerlaw_beta).* meta_data.length(i);
    ind = find(A > quantization_error, 1);
    meta_data.minimal_rain_rate(i) = r(ind);
end
clear r i A ind 
%% convert '-128' to 'nan':
if(0)
fn = fieldnames(db);
for k=1:numel(fn)
    hop = char(fn(k));
    disp(hop)
    if( isfield(db.(hop) , 'up') )
        db.(hop).up.raw ( db.(hop).up.raw(:,2) == -128) = nan;
    end
    if( isfield(db.(hop) , 'down') )
        db.(hop).down.raw ( db.(hop).down.raw(:,2) == -128) = nan;
    end
end
clear fn k link
end
%% convert 'nan' to -128;
if(0)
fn = fieldnames(db);
for k=1:numel(fn)
    hop = char(fn(k));
    disp(hop)
    if( isfield(db.(hop) , 'up') )
        db.(hop).up.raw ( isnan(db.(hop).up.raw(:,2)) ) = -128;
    end
    if( isfield(db.(hop) , 'down') )
        db.(hop).down.raw ( isnan(db.(hop).down.raw(:,2) )) = -128;
    end
end
clear fn k link
end
%% MEAN
fn = fieldnames(db);
win_size = (2*60*24)*10; % num_of_samples_in_a_day * num_of_days.
for k=1:numel(fn)
    hop = char(fn(k));
    directions = fieldnames(db.(hop));
    for j = 1:length(directions)
        direction = char(directions(j));
        db.(hop).(direction).mean = movmean( db.(hop).(direction).raw(:,2),win_size,'omitnan');
    end
end
clear fn map win_size hop directions avg j k
%% STD
if(0)%TODO - adjust to new meta_data and db structs. 
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
end
%% geodisy - 
lat = [meta_data.site1_latitude ; meta_data.site2_latitude]; 
lat(lat==0) = []; %TODO - should not be here once I have the location of all sites.
lon = [meta_data.site1_longitude ; meta_data.site2_longitude]; 
lon(lon==0) = []; %TODO - should not be here once I have the location of all sites.
dczone = utmzone(mean(lat,'omitnan'), mean(lon,'omitnan')); %36R
utmstruct = defaultm('utm'); 
utmstruct.zone = dczone;  
utmstruct.geoid = wgs84Ellipsoid;
utmstruct = defaultm(utmstruct);

%add containers to UTM coordinates:
meta_data.x_site1  = nan(length(meta_data.hop_name),1);
meta_data.x_site2  = nan(length(meta_data.hop_name),1);
meta_data.y_site1  = nan(length(meta_data.hop_name),1);
meta_data.y_site2  = nan(length(meta_data.hop_name),1);
meta_data.x_center = nan(length(meta_data.hop_name),1);
meta_data.y_center = nan(length(meta_data.hop_name), 1);

for i = 1:length(meta_data.hop_name)
    hop = char(meta_data.hop_name(i));
    lon1 = meta_data.site1_longitude(hop);
    lon2 = meta_data.site2_longitude(hop);
    lat1 = meta_data.site1_latitude(hop) ;
    lat2 =  meta_data.site2_latitude(hop);
    if( lon1 ==0 || lon2==0 || lat1==0 || lat2 ==0); continue; end %TODO - should not be here once I have the location of all sites.
    
    %check that all points are in the same UTM zone
%     dczone = utmzone(mean(lat1,'omitnan'), mean(lon1,'omitnan'));
%     if (~strcmp(dczone , '36R'))
%         disp('UTM zone is different');
%     end
%     dczone = utmzone(mean(lat2,'omitnan'), mean(lon2,'omitnan'));
%     if (~strcmp(dczone , '36R'))
%         disp('UTM zone is different');
%     end

    [meta_data.x_site1(hop),meta_data.y_site1(hop)] = mfwdtran(utmstruct,lat1,lon1);
    [meta_data.x_site2(hop),meta_data.y_site2(hop)] = mfwdtran(utmstruct,lat2,lon2);

    meta_data.x_center(hop) = mean([meta_data.x_site1(hop) meta_data.x_site2(hop)]);
    meta_data.y_center(hop) = mean([meta_data.y_site1(hop) meta_data.y_site2(hop)]); 
end
figure;
show_hops_on_map(meta_data.hop_name, meta_data,map_color_by_hop, false, true); %TODO - add color_map
x_min = min([meta_data.x_site1 ; meta_data.x_site2]);
x_max = max([meta_data.x_site1 ; meta_data.x_site2]);
y_min = min([meta_data.y_site1 ; meta_data.y_site2]);
y_max = max([meta_data.y_site1 ; meta_data.y_site2]);
xlim([x_min x_max]);
ylim([y_min y_max]);
%plot_google_map() %TODO - it doesn't work
title('Smart-city Rehovot hops');
xlabel('Eastings UTM');
ylabel('Northings UTM');
%get_google_map()
clear map hop x1 x2 y1 y2 i dczone lat1 lat2 lon1 lon2 lat lon utmstruct

%% calc free space path loss 
if(0)
meta_data.fspl = fspl(meta_data.length* 1000 , lambda ); %[db]
end
%% Fersnel zone 
if(0)
n = 1; 
%mid_path_radius = 0.5 * sqrt(n*lambda*d) ;
mid_path_radius = 8.656* sqrt( meta_data.length ./ frequency); %[m]
end


%%
storms_in_rehovot_path = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\storms_in_rehovot.txt';
storms_in_rehovot = readtable(storms_in_rehovot_path,'ReadVariableNames',false, 'delimiter' , '\t', 'Format','%u%q%q%q%q', 'HeaderLines', 0);

storms_in_rehovot.Properties.VariableNames = { 'eventID' 'ds' 'de' 'exclude_hops' 'comments' };
storms_in_rehovot.exclude_hops = regexp(storms_in_rehovot.exclude_hops, ',', 'split');
storms_in_rehovot.ds = datetime(storms_in_rehovot.ds, 'InputFormat', 'dd/MM/yyyy HH:mm');
storms_in_rehovot.de = datetime(storms_in_rehovot.de, 'InputFormat', 'dd/MM/yyyy HH:mm');
storms_in_rehovot.ds.Format = 'dd.MM.yyyy HH:mm:ss';
storms_in_rehovot.de.Format = 'dd.MM.yyyy HH:mm:ss';

clear storms_in_rehovot_path
%% first appearance of hop
meta_data.first_appearance = NaT( size(meta_data,1) ,1);
for i = 1:length(meta_data.hop_name)
    hop = char(meta_data.hop_name(i));
    directions = fieldnames(db.(hop));
    meta_data.first_appearance(i) = NaT;
    for j = 1:length(directions) %{'up' ,'down'}
        direction = char(directions(j));
        meta_data.first_appearance(i) = min( datetime(db.(hop).(direction).raw(1,1),'ConvertFrom', 'posixtime') , meta_data.first_appearance(i));
    end  
end
clear i hop directions j direction  