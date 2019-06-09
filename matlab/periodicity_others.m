%% Ericsson experimental link - 80GHz
figure;
plot( ericsson_db_eband.time , ericsson_db_eband.rssi) ;
title ( 'Ericsson expiremental link 80GHz' );

figure; 
ds = datetime(2012,08,05,00,00,00); de = datetime(2012,08,20,23,59,59);
ind_period = ericsson_db_eband.time > ds & ericsson_db_eband.time<de;
A = ericsson_db_eband.rssi(ind_period);
plot_fft(A , 67);
title( 'Ericsson expiremental link 80GHz - FFT');
%% Ericsson CML
% need to parse files first! 
load('ericsson_n296.mat')

figure; plot( ericsson_db.GC0001A_GH9007B.time , ericsson_db.GC0001A_GH9007B.rssi);

%% ceragon 
link1 = db_ceragon.l31;
link2 = db_ceragon.l32;

figure;
subplot(2,1,1);
hold on;    plot( link1.Date , link1.MinRSL , 'DisplayName' , 'minRSL'); 
hold on;    plot( link1.Date , link1.MaxRSL , 'DisplayName' , 'maxRSL');
% hold on;    plot( link1.Date , link1.MinTSL , 'DisplayName' , 'minTSL'); % constant
% hold on;    plot( link1.Date , link1.MaxTSL , 'DisplayName' , 'maxTSL'); % constant
subplot(2,1,2);
hold on;    plot( link2.Date , link2.MinRSL , 'DisplayName' , 'minRSL'); 
hold on;    plot( link2.Date , link2.MaxRSL , 'DisplayName' , 'maxRSL');
% hold on;    plot( link2.Date , link2.MinTSL , 'DisplayName' , 'minTSL'); % constant
% hold on;    plot( link2.Date , link2.MaxTSL , 'DisplayName' , 'maxTSL'); % constant

figure; 
title('Single-Sided Amplitude Spectrum of X(t)'); xlabel('f (Hz)'); ylabel('|P1(f)|');

subplot(2,2,1)
plot_fft(link1.MinRSL , 15*60);
title('link1 min RSL') ;

subplot(2,2,2)
plot_fft(link2.MinRSL , 15*60); 
title('link2 min RSL') ;

subplot(2,2,3)
plot_fft(link1.MaxRSL , 15*60);
title('link1 max RSL') ;

subplot(2,2,4)
plot_fft(link2.MaxRSL , 15*60); 
title('link2 max RSL') ;