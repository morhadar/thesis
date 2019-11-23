%% correlation between 2 links only
hop1 = 5; %5-18(farest), 2-17(longest and farest)
hop2 = 12;
idx = meta_data.hop_num == hop1; channel_names = meta_data.link_name(idx); cn1 = char(channel_names(1));
idx = meta_data.hop_num == hop2; channel_names = meta_data.link_name(idx); cn2 = char(channel_names(1));

ind_period = db.(cn1).time_rssi > ds & db.(cn1).time_rssi<de;
rsl1 = db.(cn1).rssi(ind_period);
rsl1 = (rsl1 - db.(cn1).avg(ind_period))/db.(cn1).standart_deviation;
rsl1 = (rsl1 - db.(cn1).avg(ind_period))/meta_data{hop1, 'length_KM'};
time1 = db.(cn1).time_rssi(ind_period);
ts1 = timeseries(rsl1 , datestr(time1) );
ts1_r = resample(ts1 , datestr(ds:seconds(30):de));

ind_period = db.(cn2).time_rssi > ds & db.(cn2).time_rssi<de;
rsl2 = db.(cn2).rssi(ind_period);
rsl2 = (rsl2 - db.(cn2).avg(ind_period))/db.(cn2).standart_deviation;
rsl2 = (rsl2 - db.(cn2).avg(ind_period))/meta_data{hop1, 'length_KM'};
time2 = db.(cn2).time_rssi(ind_period);
ts2 = timeseries(rsl2 , datestr(time2) );
ts2_r = resample(ts2 , datestr(ds:seconds(30):de));

figure;
subplot(2,2,1);
hold on; plot( time1 , rsl1 ,'.', 'DisplayName' , 'orig rsl1');
title(['orig ' num2str(hop1)]);
subplot(2,2,2);
hold on; plot( time2 , rsl2 ,'.', 'DisplayName' , 'orig rsl2');
title(['orig ' num2str(hop2)]);

subplot(2,2,3);
hold on; plot(ts1.Time , ts1.Data, '.' , 'DisplayName' , 'ts1');
hold on; plot(ts1_r.Time , ts1_r.Data , '-' , 'DisplayName' , 'ts1_resampled');
subplot(2,2,4);
hold    on; plot(ts2.Time , ts2.Data, '.' , 'DisplayName' , 'ts2');
hold on; plot(ts2_r.Time , ts2_r.Data , '-' , 'DisplayName' , 'ts2_resampled');

figure;
subplot(1,2,1);
hold on; plot(ts1_r.Data, 'DisplayName', num2str(hop1) );
hold on; plot(ts2_r.Data, 'DisplayName', num2str(hop2) );
hold on; plot( [ts2_r.Data(20:end) ; zeros(19, 1)] , 'DisplayName', 'tmp' ); %tmp
tmp = [ts2_r.Data(20:end-1); zeros(20, 1)];
[Rxy,delay] = xcorr( tmp(2:end-1) ,ts2_r.Data(2:end-1),'coeff'); %tmp
figure; crosscorr( tmp(2:end-1), ts2_r.Data(2:end-1)) %TODO - check which one is better!
% [Rxy,delay] = xcorr(ts1_r.Data(2:end-1),ts2_r.Data(2:end-1),'coeff');
subplot(1,2,2);
hold on; plot(delay,Rxy)
[~,I] = max_val(abs(Rxy));
delay_estimated = delay(I);
title( ['Rxx of ' num2str(hop1) ' and ' num2str(hop2) ' , delay estimated:' num2str(delay_estimated) ' , ' char(ds)]);


figure;
r = crosscorr(ts1_r.Data(1:end-1) , ts2_r.Data(1:end-1));
plot(r)
%% investigate crosscorr vs xcorr

%NOTE: 
%corr(s1,s2) - event that occur at t in s2 is occuring at t+lag in s1: 
%s2(t) = s1(t+tau) 
%if tau<0 then s1 occurs before s2!! (if tau>0 then s1 occurs after s2)

s1 = [ 0 0 0 0 0 1 2 5 10 5 2 1];
s2 = [ 0 5 5 5 5 5 0 0 0 0 0 0];
s1 = s1 + randn(size(s1));
s2 = s2 + randn(size(s2));

s1 = (s1-mean(s1))/std(s1);
s2 = (s2-mean(s2))/std(s2);

figure; 
subplot(2,1,1); plot(s1); title( 's1');
subplot(2,1,2); plot(s2); title( 's2');

options = {'' , 'biased' , 'unbiased' , 'coeff' };
figure;
for i = 1:length(options)
    opt = char(options{i});
    [acor,lag] = xcorr( s1 , s2, opt);
    [max_val,I] = max(abs(acor));
    timeDiff = lag(I);
    subplot(4,1,i);  
    plot(lag,acor);     
    title(opt); 
    hold on; 
    stem(timeDiff, max_val);
end

%% MLE using grid search.

fo = fitoptions('Method','NonlinearLeastSquares',...
               'Lower',[0,-180],...
               'Upper',[30,180],...
               'StartPoint',[5 45]);
ft = fittype('(d/v) * sind(phi - alpha)', ...
             'coefficients',{'v','alpha'} ...
             ,'dependent' , {'tau'}, ... 
             'independent' , {'d','phi'}, ...
             'options',fo);
% ft = fittype('y = mu(x , v , direction)', 'options',fo);
fitobject = fit([d, phi],tau,ft);

%% pairs = nchoosek(hops,2);
% map = distinguishable_colors(length(hops));
% for i = 1:length(pairs)    
%     x_center1 = meta_data.x_center(pairs(i,1));
%     y_center1 = meta_data.y_center(pairs(i,1));
%     x_center2 = meta_data.x_center(pairs(i,2));
%     y_center2 = meta_data.y_center(pairs(i,2));
% 
%     hold on; plot( [x_center1 x_center2] , [y_center1 y_center2]  , '--', 'DisplayName' , [char(pairs(i,1)) ' -> ' char(pairs(i,2)) ]);
% end

%% 
y = 2;
x = 1;

atand(y/x)
atan2d(y,x)

atand(y/-x)
atan2d(y,-x)

atand(-y/-x)
atan2d(-y,-x)

atand(-y/x)
atan2d(-y,x)

%% 
xi = -2;
yi = -2;
xj = -1;
yj = -1;

xi = -2;
yi = -1;
xj = -1;
yj = -2;

alpha_wind = 20;

%phi_ij = atan2d( (yj - yi) , (xj - xi))
phi_ij = atan2d( (yi - yj) , (xi - xj))
cosd(phi_ij - alpha_wind) 
phi_ji = phi_ij +180
cosd(phi_ji - alpha_wind) 
%%
    %present result
    figure('Name' , ['event' num2str(eventID) ':' char(ds) ' - ' char(de)], 'units','normalized','outerposition',[0 0 1 1]);
    subplot(2,1,1); hold on; plot( ds:seconds(30):de, (estimated_parameters(i , 1)  * ones(size(ds:seconds(30):de))) , 'DisplayName', '|v|',  'color' , 'm');
    legend('show');

    subplot(2,1,2); hold on; plot( ds:seconds(30):de, (estimated_parameters(i , 2)  * ones(size(ds:seconds(30):de))) , 'DisplayName', 'alpha',  'color' , 'm'); 
    legend('show');

    stations = fieldnames(ims_db);
    map_stations = distinguishable_colors(length(stations));
    for k=1:numel(stations)
        s = char(stations(k));
        ind_period = ims_db.(s).time > ds & ims_db.(s).time<de;

        subplot(2,1,1); title('|v|'); xlabel('date and time'); ylabel('|v| m/s'); legend('show'); 
        hold on; plot(ims_db.(s).time(ind_period) ,ims_db.(s).wind_speed(ind_period), 'DisplayName', s, 'color' , map_stations(k,:));
        hold on; plot(ims_db.(s).time(ind_period) ,ims_db.(s).speed_of_the_upper_wind(ind_period), '--', 'HandleVisibility','off','color' , map_stations(k,:));
        gt_parameters(i , 1 , k) = mean(ims_db.(s).speed_of_the_upper_wind(ind_period));
        
        subplot(2,1,2); title('wind direction'); xlabel('date and time'); ylabel('|v| m/s'); 
        hold on; plot(ims_db.(s).time(ind_period) ,convert_IMS_wind_direction(ims_db.(s).wind_direction(ind_period)) ,'DisplayName', s , 'color' , map_stations(k,:));
        hold on; plot(ims_db.(s).time(ind_period) ,convert_IMS_wind_direction(ims_db.(s).direction_of_the_upper_wind(ind_period)), '--', 'HandleVisibility','off', 'color' , map(k,:));
        gt_parameters(i , 2 , k) = convert_IMS_wind_direction(mean(ims_db.(s).direction_of_the_upper_wind(ind_period), 'omitnan'));
    end
    %saveas(gcf , [dir_name num2str(eventID) ,'.jpg']);
    clear fn k map s ind_period
    
    show_hops_on_map (valid_hops, meta_data, true);
    saveas(gcf , [ dir_name eventID_s '_hops.jpg']);

    fig_rssi_rain = figure('Name' , [eventID_s ' rssi & rain gauges' ], 'units','normalized','outerposition',[0 0 1 1]);
    subplot(1,2,1);
    map = distinguishable_colors(length(valid_hops), {'w','k'}); %TODO - distinguishable FIX! colors
    [~ , ~, sort_index] = calc_effective_distance_and_sort_hops(valid_hops , meta_data , estimated_parameters(i , 2), true);
    bias = 0;
    for ii = sort_index
        disp(ii);
        hop = char(valid_hops(ii));
        hold on; plot( valid_time_axis , valid_rssi(: , ii) + bias ,'color' , map(ii,: ) , 'DisplayName', hop);
        hold on; text( valid_time_axis(1), valid_rssi(20 , ii) + bias, num2str(ii), 'color' , map(ii,: ));
        bias = bias+1;
    end
    subplot(1,2,2); 
    %yyaxis right
    title('rain gauges'); xlabel('date and time'); ylabel('R mm/h'); legend('show'); 
    stations = fieldnames(ims_db);
    map = distinguishable_colors(length(stations));
    for k=1:numel(stations)
        s = char(stations(k));
        ind_period = ims_db.(s).time > ds & ims_db.(s).time<de;
        hold on; plot(ims_db.(s).time(ind_period) ,ims_db.(s).rain(ind_period), 'DisplayName', s, 'color' , map(k,:));
    end
    
    %%
            % WLS (x - is the input)
    %     x = [distance(:) ,phi(:)];
    %     modelFun = @(b,x) (x(1)./b(1)).*cosd(x(2)-b(2));
    %     nlm = fitnlm(x, tau(:),modelFun,start);
    
    %% 
    %% rain events:
%februry 2018:
storms{1}.dates = [...
    datetime(2018,02,17,02,09,00) , datetime(2018,02,17,03,09,00);
    ];
storms{2}.dates = [...
    datetime(2018,02,17,04,40,00) , datetime(2018,02,17,08,55,00);
    datetime(2018,02,17,04,43,00) , datetime(2018,02,17,06,32,00);
    datetime(2018,02,17,06,32,00) , datetime(2018,02,17,07,14,00);
    datetime(2018,02,17,07,14,00) , datetime(2018,02,17,07,52,00);
    datetime(2018,02,17,07,52,00) , datetime(2018,02,17,08,33,00);
    ];
storms{3}.dates = [...
    datetime(2018,02,17,12,02,00) , datetime(2018,02,17,14,39,00);
    datetime(2018,02,17,12,02,00) , datetime(2018,02,17,12,30,00);
    datetime(2018,02,17,12,30,00) , datetime(2018,02,17,13,02,00);
    datetime(2018,02,17,13,02,00) , datetime(2018,02,17,13,43,00);
    datetime(2018,02,17,13,43,00) , datetime(2018,02,17,14,31,00);
    ];
storms{4}.dates = [...
    datetime(2018,02,18,18,19,00) , datetime(2018,02,18,23,46,00);
    datetime(2018,02,18,18,19,00) , datetime(2018,02,18,18,51,00);
    datetime(2018,02,18,18,51,00) , datetime(2018,02,18,20,35,00);
    datetime(2018,02,18,20,35,00) , datetime(2018,02,18,21,37,00);
    datetime(2018,02,18,21,37,00) , datetime(2018,02,18,22,12,00);
    ];
storms{5}.dates = [...
    datetime(2018,02,27,00,50,00) , datetime(2018,02,27,01,55,00);
    ];
storms{6}.dates = [...
    datetime(2018,02,27,02,50,00) , datetime(2018,02,27,04,08,00);
    ];
storms{7}.dates = [...
    datetime(2018,02,27,04,08,00) , datetime(2018,02,27,05,35,00);
    datetime(2018,02,27,04,08,00) , datetime(2018,02,27,04,38,00);
    datetime(2018,02,27,04,38,00) , datetime(2018,02,27,05,12,00);
    datetime(2018,02,27,05,12,00) , datetime(2018,02,27,05,35,00);
    ];
storms{8}.dates = [...
    datetime(2018,02,27,06,19,00) , datetime(2018,02,27,06,56,00);
    ];

%march 2018
storms{9}.dates = [...
    datetime(2018,03,28,03,20,00) , datetime(2018,03,28,08,44,00);
    datetime(2018,03,28,04,28,00) , datetime(2018,03,28,07,11,00);
    datetime(2018,03,28,07,11,00) , datetime(2018,03,28,08,44,00);
    ];
storms{10}.dates = [...
    datetime(2018,03,29,23,00,00) , datetime(2018,03,29,23,20,00);
    ];
%april 2018
storms{11}.dates = [...
    datetime(2018,04,10,06,53,00) , datetime(2018,04,10,09,35,00);
    datetime(2018,04,10,06,53,00) , datetime(2018,04,10,07,54,00);
    datetime(2018,04,10,07,54,00) , datetime(2018,04,10,08,22,00);
    datetime(2018,04,10,08,22,00) , datetime(2018,04,10,08,48,00);
    datetime(2018,04,10,08,48,00) , datetime(2018,04,10,09,35,00);
    ];
storms{12}.dates = [...
    datetime(2018,04,10,11,37,00) , datetime(2018,04,10,13,32,00);
    datetime(2018,04,10,11,37,00) , datetime(2018,04,10,12,13,00);
    datetime(2018,04,10,12,13,00) , datetime(2018,04,10,13,32,00);
    ];
storms{13}.dates = [...
    datetime(2018,04,10,14,00,00) , datetime(2018,04,10,15,35,00);
    ];
storms{14}.dates = [...
    datetime(2018,04,21,10,12,00) , datetime(2018,04,21,11,38,00);
    datetime(2018,04,21,10,12,00) , datetime(2018,04,21,10,55,00);
    datetime(2018,04,21,10,55,00) , datetime(2018,04,21,11,38,00);
    ];
storms{15}.dates = [...
    datetime(2018,04,22,04,30,00) , datetime(2018,04,22,05,30,00);
    ];
storms{16}.dates = [...
    datetime(2018,04,25,14,30,00) , datetime(2018,04,25,16,53,00);
    datetime(2018,04,25,14,30,00) , datetime(2018,04,25,15,00,00);
    datetime(2018,04,25,15,00,00) , datetime(2018,04,25,15,28,00);
    datetime(2018,04,25,15,28,00) , datetime(2018,04,25,16,00,00);
    ];
storms{17}.dates = [...
    datetime(2018,04,26,16,59,00) , datetime(2018,04,26,17,28,00);
    ];
%may 2018
storms{18}.dates = [...
    datetime(2018,05,08,20,40,00) , datetime(2018,05,08,21,50,00);
    ];
%june 2018
storms{19}.dates = [...
    datetime(2018,06,13,04,25,00) , datetime(2018,06,13,17,37,00);
    ];
%september 2018
storms{20}.dates = [...
    datetime(2018,09,08,08,11,00) , datetime(2018,09,08,08,40,00);
    ];
storms{21}.dates = [...
    datetime(2018,09,08,19,30,00) , datetime(2018,09,08,20,20,00);
    ];
%october 2018
storms{22}.dates = [...
    datetime(2018,10,25,20,00,00) , datetime(2018,10,26,02,26,00);
    datetime(2018,10,25,20,00,00) , datetime(2018,10,25,20,58,00);
    datetime(2018,10,25,20,00,00) , datetime(2018,10,25,21,36,00);
    datetime(2018,10,25,21,36,00) , datetime(2018,10,25,21,57,00);
    datetime(2018,10,25,21,36,00) , datetime(2018,10,25,22,24,00);
    datetime(2018,10,25,21,57,00) , datetime(2018,10,25,22,24,00);
    datetime(2018,10,25,22,24,00) , datetime(2018,10,25,23,21,00);
    datetime(2018,10,25,23,38,00) , datetime(2018,10,26,00,19,00);
    datetime(2018,10,26,00,19,00) , datetime(2018,10,26,01,05,00);
    datetime(2018,10,26,01,05,00) , datetime(2018,10,26,02,01,00);
    datetime(2018,10,26,01,05,00) , datetime(2018,10,26,01,19,00);
    datetime(2018,10,26,01,19,00) , datetime(2018,10,26,02,00,00);
    ];
%november 2018
storms{23}.dates = [...
    datetime(2018,11,05,00,10,00) , datetime(2018,11,05,02,00,00);
    datetime(2018,11,05,00,10,00) , datetime(2018,11,05,01,00,00);
    datetime(2018,11,05,01,00,00) , datetime(2018,11,05,02,00,00);
    ];
storms{24}.dates = [...
    datetime(2018,11,05,17,17,00) , datetime(2018,11,05,17,50,00);
    ];
storms{25}.dates = [...
    datetime(2018,11,05,19,15,00) , datetime(2018,11,05,20,35,00); %TODO make sure time are ok
    ];
storms{26}.dates = [...
    datetime(2018,11,05,21,42,00) , datetime(2018,11,05,22,32,00);
    ];
storms{27}.dates = [...
    datetime(2018,11,05,23,50,00) , datetime(2018,11,06,00,48,00);
    ];
storms{28}.dates = [...
    datetime(2018,11,06,01,48,00) , datetime(2018,11,06,02,45,00);
    datetime(2018,11,06,01,48,00) , datetime(2018,11,06,02,16,00);
    datetime(2018,11,06,02,16,00) , datetime(2018,11,06,02,48,00);
    ];
storms{29}.dates = [...
    datetime(2018,11,06,04,07,00) , datetime(2018,11,06,04,51,00);
    ];
storms{30}.dates = [...
    datetime(2018,11,12,04,58,00) , datetime(2018,11,12,06,43,00);
    ];
storms{31}.dates = [...
    datetime(2018,11,14,15,00,00) , datetime(2018,11,14,15,31,00);
    ];
storms{32}.dates = [...
    datetime(2018,11,16,03,09,00) , datetime(2018,11,16,09,35,00);
    datetime(2018,11,16,03,09,00) , datetime(2018,11,16,03,50,00);
    datetime(2018,11,16,04,28,00) , datetime(2018,11,16,05,20,00);
    datetime(2018,11,16,05,20,00) , datetime(2018,11,16,06,10,00);
    datetime(2018,11,16,06,10,00) , datetime(2018,11,16,06,37,00);
    datetime(2018,11,16,06,37,00) , datetime(2018,11,16,07,08,00);
    datetime(2018,11,16,06,10,00) , datetime(2018,11,16,07,08,00);
    datetime(2018,11,16,08,47,00) , datetime(2018,11,16,09,12,00);
    datetime(2018,11,16,09,12,00) , datetime(2018,11,16,09,34,00);
    datetime(2018,11,16,08,47,00) , datetime(2018,11,16,09,34,00);
    ];
storms{33}.dates = [...
    datetime(2018,11,23,04,19,00) , datetime(2018,11,23,06,24,00);
    datetime(2018,11,23,04,19,00) , datetime(2018,11,23,05,21,00);
    datetime(2018,11,23,05,21,00) , datetime(2018,11,23,06,24,00);
    ];
storms{34}.dates = [...
    datetime(2018,11,23,08,30,00) , datetime(2018,11,23,10,23,00);
    ];
storms{35}.dates = [...
    datetime(2018,11,23,17,00,00) , datetime(2018,11,23,21,07,00);
    datetime(2018,11,23,17,00,00) , datetime(2018,11,23,17,56,00);
    datetime(2018,11,23,17,56,00) , datetime(2018,11,23,19,18,00);
    datetime(2018,11,23,19,18,00) , datetime(2018,11,23,20,53,00);
    ];
storms{36}.dates = [...
    datetime(2018,11,23,04,14,00) , datetime(2018,11,23,07,55,00);
    ];