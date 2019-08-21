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
[~,I] = max(abs(Rxy));
delay_estimated = delay(I);
title( ['Rxx of ' num2str(hop1) ' and ' num2str(hop2) ' , delay estimated:' num2str(delay_estimated) ' , ' char(ds)]);


figure;
r = crosscorr(ts1_r.Data(1:end-1) , ts2_r.Data(1:end-1));
plot(r)
%% investigate crosscorr vs xcorr
    %NOTE: corr(s1,s2) - event that occur at t in s2 is occuring at t+lag 
    %in s1. When lag is negative then s1 is pre s2 and when lag is positive 
    %then s1 is post s2.
s1 = ts1_r.Data(2:end-10);
s2 = ts2_r.Data(2:end-10);
% s1 = [zeros(1,10) , ones(1,10) ,zeros(1,10)];
% s2 = [zeros(1,5) , 10 9 8 7 6 5 4 3 2 1 ,zeros(1,15)];
% n = 0:15;
% s1 = 0.84.^n;
% s2 = circshift(s1,5);
s1_norm = (s1-avg(s1))/std(s1);
s2_norm = (s2-avg(s2))/std(s2);
% s1_norm = (s1-mean(s1));
% s2_norm = (s2-mean(s2));
figure; 
subplot(2,1,1); plot(s1); hold on; plot(s2);
subplot(2,1,2); plot(s1_norm); hold on; plot(s2_norm);

  
[acor1,lag1] = xcorr(s1,s2);
[acor2,lag2] = xcorr( s1_norm , s2_norm);
[acor3,lag3] = xcorr( s1 , s2, 'biased');
[acor4,lag4] = xcorr( s1 , s2, 'unbiased');
[acor5,lag5] = xcorr( s1 , s2, 'coeff');
[acor6,lag6] = xcorr( s1_norm , s2_norm, 'unbiased');

[max1,I1] = max(abs(acor1));
[max2,I2] = max(abs(acor2));
[max3,I3] = max(abs(acor3));
[max4,I4] = max(abs(acor4));
[max5,I5] = max(abs(acor5));
[max6,I6] = max(abs(acor6));

timeDiff1 = lag1(I1);
timeDiff2 = lag2(I2);
timeDiff3 = lag2(I3);
timeDiff4 = lag2(I4);
timeDiff5 = lag2(I5);
timeDiff6 = lag2(I6);


figure;  
subplot(8,2,1); plot(s1); title( 's1');
subplot(8,2,2); plot(s2); title( 's2');
subplot(8,2,3); plot(s1_norm); title( 's1 norm');
subplot(8,2,4); plot(s2_norm); title( 's1 norm');
subplot(8,2,[5 6]); plot(lag1,acor1);     title('xcorr of s1 and s2');           hold on; stem(timeDiff1, max1);
subplot(8,2,[7 8]); plot(lag2,acor2);     title('xcorr of s1 norm and s2 norm'); hold on; stem(timeDiff2, max2);
subplot(8,2,[9 10]); plot(lag3,acor3);     title('xcorr biased'); hold on; stem(timeDiff3, max3);
subplot(8,2,[11 12]); plot(lag4,acor4);     title('xcorr unbiased'); hold on; stem(timeDiff4, max4);
subplot(8,2,[13 14]); plot(lag5,acor5);     title('xcorr coeff'); hold on; stem(timeDiff5, max5);
subplot(8,2,[15 16]); plot(lag6,acor6);     title('xcorr norm unbiased'); hold on; stem(timeDiff6, max6);

%% MLE using grid search.

beta1 = 0:0.1:10; %velocity [m/s]
beta2 = 0:0.1:360; %direction;
[beta1_grid , beta2_grid] =  meshgrid( beta1 , beta2);
mini_f = zeros( [size(beta1_grid) , numel(tau) ]);
for n = numel(tau)
    if isnan(phi(n))
        continue;
    end
    mini_f(:,:,n) =  (tau(n) - (distance(n)./beta1_grid) .* sind(phi(n) - beta2_grid)   ).^2; %TODO  - something is wrong with the dimentions!
end
f = sum(mini_f, 3);
figure; 
mesh(f)

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


