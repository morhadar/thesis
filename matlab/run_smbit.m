%% In thit notebook:
% 1. load previously parsed data
% 2. Calculates network constraints
%% load data;
% load smbit processed data + metadata table + assign distingush color for each hop for visualizaion purposes + add UTM geodesy data
load('../data/processed_data/db.mat'); 
meta_data = readtable('../data/raw_data/smbit/meta_data.xlsx', 'ReadVariableNames', true , 'ReadRowNames', true );
meta_data.color = u.distinguishable_colors(height(meta_data), {'w','k'});
meta_data = u.expand_metadata_with_UTM_coordinate(meta_data);

if(0)
    figure;
    u.show_hops_on_map(meta_data.hop_name, meta_data, false, true);
    xlim([min([meta_data.x_site1 ; meta_data.x_site2]) max([meta_data.x_site1 ; meta_data.x_site2])]);
    ylim([min([meta_data.y_site1 ; meta_data.y_site2]) max([meta_data.y_site1 ; meta_data.y_site2])]);
    title('Smart-city Rehovot hops');
    xlabel('Eastings UTM');
    ylabel('Northings UTM');
end

% load ims meteorological data + assign distingush color for station for visualizaion purposes
load('../data/processed_data/ims_db.mat');
ims_db.stations = fieldnames(ims_db);
ims_db.beit_dagan.color = [0, 0, 1]; %colors where taken from distinguishable_colors(4)
ims_db.hafetz_haim.color = [1, 0, 0];
ims_db.nahshon.color = [0, 1, 0];
ims_db.kvotzat_yavne.color = [0, 0, 0.1724];
load('../data/processed_data/ims_db_clouds.mat');
load('../data/processed_data/gamliel.mat');
load('../data/processed_data/suntime_db.mat' );
%% miscellaneous

%calc free space path loss 
meta_data.fspl = fspl(meta_data.length* 1000 , wavelength ); %[dB]

%Fersnel zone 
%mid_path_radius = 0.5 * sqrt(1*wavelength*d) ;
mid_path_radius = 8.656* sqrt(meta_data.length ./ frequency_GHz); %[m]

%first and last appearance of hop
meta_data = u.first_and_last_appearance(meta_data, db);

%calc minimal rain rate:
meta_data.minimal_rain_rate = u.minimal_rain_rate(meta_data.length, powerlaw_alpha, powerlaw_beta, power_quantization);

%convert '-128' to nan and back:
db = u.nan_2_minus128(db);
db = u.minus128_to_nan(db);

%% parameters
% Network Properties:
frequency_GHz = 74.875; %[GHz]
frequency = frequency_GHz * 1e9; %[Hz]
wavelength   = ( physconst('LightSpeed')/frequency ); %[m]
polarization = 1; %1-vertical, 0-horizontal.
powerlaw_beta = u.ITU_aRb2_b(polarization,frequency_GHz);
powerlaw_alpha = u.ITU_aRb2_a(polarization,frequency_GHz);
delta = 0.5; %TSL is moving ranging between [const - delta , const + delta]
power_quantization = 1; %[dBm] (but can also reach 20 2dBm under certain conditions)
time_quant = 30; %[sec]

% others
if(0)
freq24hours = 1/(24*60*60); %Hz
harmonics = 1:7;
freq_harmonics = 1./((24./harmonics).*3600);
T = 20; %[celsious]
P = 100 *1000; %[Pa]
W = 7.5; %[g/m^3] water density.
gas_attenuation = gaspl( 170, frequency ,T, P, W );
end

%% system constraints/limitations:
if(0)
% power law
l = 1e-2:1e-2:2;%[km]
r = 0:0.1:100; %[mm/h]. resolution of the imd data is 0.1 therfore it is enought.
[L,R] = meshgrid(l,r);
A = powerlaw_alpha.* (R.^powerlaw_beta) .*L;
figure; mesh(L,R,A); xlabel('Length[km]'); ylabel('rain rate [mm/h]'); title('differences posible between two RSL samples in a system with no attenuation');

figure;
for i = (unique(meta_data.hop_ID, 'stable'))'
    idx = meta_data.hop_ID == i;
    idx = find(idx,1);
    L = meta_data.length(idx);
    A = powerlaw_alpha .* (r .^ powerlaw_beta).* L;
    hold on; plot(r,A,'DisplayName' , ['hop:' num2str(i) ': ' num2str(L) 'km'] ,'color', meta_data.color(i, :));
end
hold on; plot( r , power_quantization*ones( size(r)  ) , 'color', 'r', 'DisplayName' , '1db');
xlabel('R [mm/h]'); ylabel('attenuation');

%wind velocity
figure;
subplot(3, 1, 1);
wind_velocity = 0:0.1:50; %[m/s]
distance_between_links = wind_velocity.*time_quant;
plot(wind_velocity , distance_between_links); 
title('Minimum Distance Between Hops to Observe Wind Velocity');
xlabel('Wind Velocity [m/s]');
ylabel('Distance Required [m]');
% saveas(gcf, '../materials/thesis_book/min_dist_between_2hops.jpg')

subplot(3, 1, 2);
histogram(d, 0:20:4500, 'facealpha', .5, 'edgecolor', 'none');
title('Distribution of Hops Distances from Each Other');
xlabel('Distnace Between Links [m]');
ylabel('Count');
% saveas(gcf, '../materials/thesis_book/Distribution_of_hops_length_from_each_other.jpg')


[distanceG, ~] = u.calc_phi_and_distance_for_each_pair_of_hops(pick_hops(meta_data , 0.01), meta_data);
d = distanceG(triu(true(size(distanceG)),1));
d(isnan(d)) = [];
v = d/30;
subplot(3, 1, 3);
plot(d, v, '*');
title('Maximum Wind Speed for no Errors in Cross-Correlation'); %TODO - better headline
xlabel('Distnace Between Links [m]');
ylabel('Maximum velocity [m/s]');
% saveas(gcf, '../materials/thesis_book/maximum_velocity_per_distance_for_not_having_errors_in_cross_correlation.jpg')

saveas(gcf, '../materials/thesis_book/measureable_wind_speed_per_system_configuration.png')

end

%% calculate minimal rain rate for each link
if(0)
meta_data.minimal_rain_rate = u.minimal_rain_rate(meta_data.length, powerlaw_alpha, powerlaw_beta, power_quantization);
L = 0.01:0.01:4;
minimal_rain_rate_lowfreq = u.minimal_rain_rate(L, u.ITU_aRb2_a(polarization, 70), u.ITU_aRb2_b(polarization, 70), power_quantization);
minimal_rain_rate_highfreq = u.minimal_rain_rate(L, u.ITU_aRb2_a(polarization, 80), u.ITU_aRb2_b(polarization, 80), power_quantization);

figure;
hold on; plot(L, minimal_rain_rate_lowfreq, 'DisplayName', '70 GHz'); 
hold on; plot(L, minimal_rain_rate_highfreq, 'DisplayName', '80 GHz'); 
hold on; plot(meta_data.length, meta_data.minimal_rain_rate, '*', 'DisplayName', 'Rehovot Networks Hops'); 

xlabel("Link's length[km]"); ylabel('Minimal rain rate [mm/h]'); title({'The minimum rain tate can be observed in link operating in','Eband frequency with 1dBm quantization'}); legend('show');
ylim([0,45])
xlim([0,2.6])
saveas(gcf, '../materials/thesis_book/min_rain_rate_as_function_of_length.png')
end

%% STD
if(0)%TODO - adjust to new meta_data and db structs. 
for i = (unique(meta_data.hop_ID, 'stable'))'
    idx = meta_data.hop_ID == i;
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
