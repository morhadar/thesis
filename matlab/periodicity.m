%% calc statistics
for hop = hops
    idx = meta_data.hop_num == hop;
    channel_names = meta_data.link_name(idx);
    for n = 1:length(channel_names)
        cn = char(channel_names(n));

        time = db.(cn).time_rssi;
        rssi =  db.(cn).rssi;
        if( isempty(rssi))
            continue
        end
        rssi = conv( rssi , ones(1,20)/20 , 'same');  %smoothing 10 minutes %TODO - not accurate in Near disconnections
        avg = db.(cn).avg;

        [y,m,d] = ymd(time);
        [~, first_apperance_of_each_day, unique_serial_num] = unique([y,m,d] ,'rows');
        num_of_days = length(first_apperance_of_each_day);

        db.(cn).t_max_peak = NaT(num_of_days , 1);
        db.(cn).t_min_peak = NaT(num_of_days , 1);
        db.(cn).max_peak = nan(num_of_days , 1);
        db.(cn).min_peak = nan(num_of_days , 1);
        db.(cn).max_fluctuation = nan(num_of_days , 1);
        db.(cn).min_fluctuation = nan(num_of_days , 1);
        
        db.(cn).t1 = NaT(num_of_days , 1);
        db.(cn).t2 = NaT(num_of_days , 1);
        db.(cn).t3 = NaT(num_of_days , 1);
        db.(cn).t4 = NaT(num_of_days , 1);
        db.(cn).ts = NaT(num_of_days , 1);
        db.(cn).te = NaT(num_of_days , 1);
        
        for i = 1:num_of_days
            ind_cur_day = unique_serial_num == i;
            time_cur = time(ind_cur_day);
            rssi_cur = rssi(ind_cur_day);
            avg_cur = avg(ind_cur_day);
            
            %%max
            [max_val,index_max] = max(rssi_cur);
            max_delta = max_val - avg_cur(index_max) ;
            if (    max_delta > db.(cn).std_up   ) 
                db.(cn).t_max_peak(i) = time_cur(index_max);
                %db.(cn).max_peak(i) = max_val; %TODO - I dont think this is interesting
                db.(cn).max_fluctuation(i) = max_delta;
                
                ind_half_peak =  rssi_cur > (max_val - 0.5*max_delta);
                k1 = find( ind_half_peak,1 );
                k2 = find( ind_half_peak,1, 'last' );
                if ( ~isempty(k1) && ~isempty(k2) )
                    db.(cn).t1(i) = time_cur(k1);
                    db.(cn).t2(i) = time_cur(k2);
                   % rssi_cubmr > avg_cur 
                end
            end
            %%end max
            
            %%min
            [min_val,index_min] = min(rssi_cur);
            min_delta =  avg_cur(index_min) - min_val;
            if (    min_delta > db.(cn).std_down   ) 
                db.(cn).t_min_peak(i) = time_cur(index_min);
                db.(cn).min_peak(i) = min_val; %TODO - I dont think this is interesting
                db.(cn).min_fluctuation(i) = min_delta;
                
                ind_half_peak =  rssi_cur < (min_val + 0.5*min_delta);
                k1 = find( ind_half_peak,1 );
                k2 = find( ind_half_peak,1, 'last' );
                if ( ~isempty(k1) && ~isempty(k2) )
                    db.(cn).t3(i) = time_cur(k1);
                    db.(cn).t4(i) = time_cur(k2);
                end
            end
            %%end min       
        end
    end
end

%% plot analysis
      t1 = figure('Name', 't1');
       t2 = figure('Name', 't2');
       t3 = figure('Name', 't3');
       t4 = figure('Name', 't4');
      f11 = figure('Name', 'max peaks fluctuations');
      f22 = figure('Name', 'inx peaks fluctuations');
      f33 = figure('Name' , 'fluctuation amplitude');
     
%      t4t1 = figure('Name', 't4 - t1');
     %f22 = figure('Name', 'inx peaks fluctuations');
     
map = distinguishable_colors(24);
for hop = hops
    idx = meta_data.hop_num == hop;
    channel_names = meta_data.link_name(idx);
    for n = 1%1:length(channel_names)
        cn = char(channel_names(n));
        
        figure(t1);
        hold on; plot( db.(cn).t1  , timeofday(db.(cn).t1)  , '*',  'DisplayName', ['hop' num2str(hop) '-' num2str(n) '  t1']);
        hold on; plot( suntime_db.date , suntime_db.sunrise , 'DisplayName' , 'sunrise')
        hold on; plot( suntime_db.date , suntime_db.sunset , 'DisplayName' , 'sunset')
        xlabel('date'); ylabel('half time of max peak');
        title('t1');
        
        figure(t2);
        hold on; plot( db.(cn).t2  , timeofday(db.(cn).t2)  , '*',  'DisplayName', ['hop' num2str(hop) '-' num2str(n) '  t2']);
        hold on; plot( suntime_db.date , suntime_db.sunrise)
        hold on; plot( suntime_db.date , suntime_db.sunset)
        xlabel('date'); ylabel('2');
        title('t2');
        
        figure(t3);
        hold on; plot( suntime_db.date , suntime_db.sunrise)
        hold on; plot( suntime_db.date , suntime_db.sunset)
        hold on; plot( db.(cn).t3  , timeofday(db.(cn).t3)  , '*',  'DisplayName', ['hop' num2str(hop) '-' num2str(n) '  t3']);
        xlabel('date'); ylabel('t3');
        title('t3');
        
        figure(t4);
        hold on; plot( db.(cn).t4  , timeofday(db.(cn).t4)  , '*',  'DisplayName', ['hop' num2str(hop) '-' num2str(n) '  t4']);
        hold on; plot( suntime_db.date , suntime_db.sunrise)
        hold on; plot( suntime_db.date , suntime_db.sunset)
        xlabel('date'); ylabel('t4');
        title('t4');
%         
        figure(f11);
        hold on; plot( db.(cn).t4  , db.(cn).max_fluctuation , '*',  'DisplayName', ['hop' num2str(hop) '-' num2str(n) '  max_fluctuation']);
%         hold on; plot( suntime_db.date , suntime_db.sunrise)
%         hold on; plot( suntime_db.date , suntime_db.sunset)
        xlabel('date'); ylabel('max fluctuation');
        title('max fluctuation');
        
        figure(f22);
%         hold on; plot( suntime_db.date , suntime_db.sunrise);
%         hold on; plot( suntime_db.date , suntime_db.sunset)
        hold on; plot( db.(cn).t4  , db.(cn).min_fluctuation  , '*',  'DisplayName', ['hop' num2str(hop) '-' num2str(n) '  min_fluctuation']);
        xlabel('date'); ylabel('min fluctuation');
        title('min fluctuation');
        
        figure(f33);
        yyaxis right
        hold on; plot( suntime_db.date , suntime_db.sunset - suntime_db.sunrise );
%         hold on; plot( suntime_db.date , suntime_db.sunset);
        yyaxis left
        hold on; plot( db.(cn).t4  ,db.(cn).max_fluctuation  - db.(cn).min_fluctuation  , '*',  'DisplayName', ['hop' num2str(hop) '-' num2str(n) '  min_fluctuation']);


        
        
%         figure(t4t1);
%         hold on; plot( db.(cn).t4  , hours(db.(cn).t4 - db.(cn).t1)  ,   'DisplayName', ['hop' num2str(hop) '-' num2str(n) '  t4-t1']);
%         %hold on; plot( suntime_db.time , hours(suntime_db.sunset - suntime_db.sunrize))
%         xlabel('date'); ylabel('t4-t1');
%         title('t4-t1');

    end
end

%% plot AVG anf SD 
map = distinguishable_colors(3); %differiating for channel. need 3 for hop1 
for hop = hops
    idx = meta_data.hop_num == hop;
    channel_names = meta_data.link_name(idx);
    
    figure;
    for n =1:length(channel_names)
        cn = char(channel_names(n));
        ind_period = db.(cn).time_rssi > ds & db.(cn).time_rssi < de;
        rssi_period = conv(  db.(cn).rssi(ind_period) , ones(1,1)/1 , 'same'); %smoothing - 10 min
        
        
        subplot(2,1,n);
        hold on; plot( db.(cn).time_rssi(ind_period) , rssi_period  , 'DisplayName', ['link ' num2str(n)] , 'color' , [0.5, 0.5, 0.5] );
        %avg:
        hold on; plot( db.(cn).time_rssi(ind_period) ,  db.(cn).rsl_mean(ind_period),   'g'   ,'LineWidth',1,'DisplayName','moving mean');
        hold on; plot( db.(cn).time_rssi(ind_period) ,  db.(cn).rsl_median(ind_period), '-.g' ,'LineWidth',1,'DisplayName','moving median'  );
        hold on; plot( db.(cn).time_rssi(ind_period) ,  db.(cn).avg(ind_period),        'k'   ,'LineWidth',1,'DisplayName','avg');
        %std:
        hold on; plot( db.(cn).time_rssi(ind_period) , db.(cn).avg(ind_period) + 1*db.(cn).std_up   ,'--k','LineWidth',1,'DisplayName','SD');
        hold on; plot( db.(cn).time_rssi(ind_period) , db.(cn).avg(ind_period) + 10*db.(cn).std_up   ,'--k','LineWidth',1,'DisplayName','SD');
        hold on; plot( db.(cn).time_rssi(ind_period) , db.(cn).avg(ind_period) - 1*db.(cn).std_down ,'--k','LineWidth',1,'DisplayName','SD');
        hold on; plot( db.(cn).time_rssi(ind_period) , db.(cn).avg(ind_period) - 10*db.(cn).std_down ,'--k','LineWidth',1,'DisplayName','SD');
      
        title([ 'hop' num2str(hop), ', ' num2str(meta_data{(cn),'length_KM'}) 'Km ,' cn  ] , 'FontSize', 20);
    end
end

%% FFT
map = distinguishable_colors(35);
nn=0;
%freq_low_th = freq_harmonics-0.02e-5;
%freq_high_th = freq_harmonics+0.02e-5;
figure;
for i = hops
    idx = meta_data.hop_num == i;
    channel_names = meta_data.link_name(idx);
% %     figure;
    for n = 1%1:size(channel_names,1)
        cn = char(channel_names(n));
        ind_period = db.(cn).time_rssi > ds & db.(cn).time_rssi<de;
        if( sum(ind_period) == 0 )
            continue
        end
        A = db.(cn).rssi(ind_period);
        %x = max(A , db.(cn).avg(ind_period) ); % take only max/min peaks
        x=A-db.(cn).avg(ind_period);
        %x = conv(x, ones(1,20)/20 , 'same');
        [P1 , f ] = calc_fft(x , 30);
        
% %         hold on; subplot(1,2, 2)
        %hold on; subplot(length(hops),2, 2*nn +2) %for plotting all hops in the same figure;
         hold on; plot(f(1:end),P1(1:end) , 'DisplayName', ['hop' num2str(i)] ); 
         title([ 'hop ' num2str(i) ' - FFT']);
        
        L = length(x);

        freq_low_th = freq_harmonics-2/(L*30);
        freq_high_th = freq_harmonics+2/(L*30);
        %%%%%%calc harmonics ratios
        amp = zeros(length(freq_harmonics), 1);
        for j =1 :length(freq_harmonics)
            %[min_val , min_ind] = min(abs(f - freq_harmonics(j)));
            %amp(j) = P1(min_ind);
            ind = f> freq_low_th(j) & f< freq_high_th(j);
           % hold on; plot( f(ind) , P1(ind), 'r');
            amp(j) = max(P1(ind));
        end
        db.(cn).freq_amp(:,12) = amp;
% %         hold on; stem( freq_harmonics , amp, 'k' );
        %%%%%plots:
        if n==1
% %             hold on; subplot(1,2,1)
            %hold on; subplot(length(hops),2, 2*nn +1) %for plotting all hops in the same figure; 
% %             hold on; plot(db.(cn).time_rssi(ind_period) , A);
% %             hold on; plot(db.(cn).time_rssi(ind_period) , x);
% %             title([ 'hop ' num2str(i) ' - attenuation']);
        end
    
    end
    nn = nn+1;
end

%% harmonics ratios:
% figure;
% plot( hops , nan)
% nn = 1;
% for i = hops
%     idx = meta_data.hop_num == i;
%     channel_names = meta_data.link_name(idx);
%     for n = 1%1:size(channel_names,1)
%         cn = char(channel_names(n));
%         if( isfield( db.(cn) , 'freq_amp'))
%             harmonics_ratio = db.(cn).freq_amp_1(2)/db.(cn).freq_amp_1(1);
%             hold on; stem( nn, harmonics_ratio, 'DisplayName' , ['hop: ' num2str(i)], 'color', map(i,:) );
%         end
%     end
%     nn = nn+1;
% end
% title(' harmonic1/harmonic2 as a function of length'); 


figure;
plot(12,nan);
for i = hops
    idx = meta_data.hop_num == i;
    channel_names = meta_data.link_name(idx);
    for n = 1%1:size(channel_names,1)
        cn = char(channel_names(n));
        if( isfield( db.(cn) , 'freq_amp'))
           harmonics_ratio = db.(cn).freq_amp(1,:) ./   db.(cn).freq_amp(2,:);
           hold on; plot( 1:12, harmonics_ratio, 'DisplayName' , ['hop: ' num2str(i)], 'color', map(i,:) );
        end
    end
end
        


%% plot derivatives: 

figure;
bias = 0;
map = distinguishable_colors(24);
for i = hops
    idx = meta_data.hop_num == i;
    channel_names = meta_data.link_name(idx);
    for n = 1:size(channel_names,1)
        cn = char(channel_names(n));
        ind_period = db.(cn).time_rssi > ds & db.(cn).time_rssi<de;
        hold on;
        A = (db.(cn).rssi(ind_period) - db.(cn).rsl_median(ind_period));
        ts = timeseries(A,char(db.(cn).time_rssi(ind_period)));
        A = conv(A, ones(1,30)/30 , 'same');
        A = conv( A , [0, 1 -1] , 'same');
        A(A > -0.06 & A < 0.06) = 0;
        %A = A/meta_data{cn, 'length_KM'}; % normalize dm to dbm.
        hold on; plot( db.(cn).time_rssi(ind_period) , A - bias, 'DisplayName', ['hop' num2str(i), ' link' num2str(n)] , 'color', map(i,:)) ;
        title([ char(ds) ' - ' char(de)]);
        bias = bias +0;
    end
end

%% 
figure;
yyaxis left
hold on; plot( suntime_db.time , suntime_db.sunrize, 'DisplayName' , 'sunrise');
hold on; plot( suntime_db.time , suntime_db.sunset, 'DisplayName' , 'sunset');
yyaxis right
hold on; plot( suntime_db.time , hours(suntime_db.sunset - suntime_db.sunrize), 'DisplayName' , 'sunset');

%% plot attenuation of hops vs humidity
% f11 = figure('Name', 'max peaks fluctuations');
% f22 = figure('Name', 'inx peaks fluctuations');
% f33 = figure('Name' , 'delta between max and min');     
map = distinguishable_colors(24);

for hop = hops
    idx = meta_data.hop_num == hop;
    channel_names = meta_data.link_name(idx);
    for n = 1%1:length(channel_names)
        cn = char(channel_names(n));
        
        period = db.(cn).time_rssi >ds & db.(cn).time_rssi <de;
        time = db.(cn).time_rssi( period );
        rssi = db.(cn).rssi (period);
        day = hour(time)>4 & hour(time)<20 ;
        [max_val , max_th_time] = extract_max_daily( time , rssi , day);
        db.(cn).max_fluc = max_val;
        db.(cn).max_fluc_timestamp = max_th_time;
%         figure(f11);
%         ind = db.(cn).t4 > ds & db.(cn).t4 < de;
%         hold on; plot( db.(cn).t4(ind)  , db.(cn).max_fluctuation(ind) , '*',  'DisplayName', ['hop' num2str(hop) '-' num2str(n) '  max_fluctuation']);
%         xlabel('date'); ylabel('max fluctuation');
%         title('max fluctuation');
%         
%         figure(f22);
%         hold on; plot( db.(cn).t4(ind)  , db.(cn).min_fluctuation(ind)  , '*',  'DisplayName', ['hop' num2str(hop) '-' num2str(n) '  min_fluctuation']);
%         xlabel('date'); ylabel('min fluctuation');
%         title('min fluctuation');
%         
%         figure(f33);
%         hold on; plot( db.(cn).t4(ind)  , db.(cn).max_fluctuation(ind) - db.(cn).min_fluctuation(ind)  , '*',  'DisplayName', ['hop' num2str(hop) '-' num2str(n) '  min_fluctuation']);
%         xlabel('date'); ylabel('min fluctuation');
%         title('min fluctuation');
        
    end
end

%add ims data in subplot
%******** automatic measurments**********
period = ims_db.beit_dagan.time >ds & ims_db.beit_dagan.time <de;
time = ims_db.beit_dagan.time( period );
rh = ims_db.beit_dagan.rh (period);
night =  (hour(time)>=22 | hour(time)<=8);
[max_rh , max_th_time] = extract_max_daily( time , rh , night);

%figure(f11); yyaxis right; hold on; plot( max_th_time ,max_rh ,'*', 'DisplayName' , 'rh' );
%figure(f22); hold on; plot( max_th_time ,max_rh ,'*', 'DisplayName' , 'rh' );
%figure(f33); hold on; plot( max_th_time ,max_rh ,'*', 'DisplayName' , 'rh' );
% figure; plot( time(night) , rh(night), '*r'); hold on; plot( time(~night) , rh(~night), '*b');

figure; 
plot( max_rh(2:end) , db.siklu_junc1_to_agafhatnua.max_fluc, '*')

