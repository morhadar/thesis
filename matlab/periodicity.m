%% plot min/max and time in day
option = 1;
map = [ [1,0,0] ; [0.8,0,0] ; [0,0,0.5] ; [0,0,1]];

for hop_num = hops
    if ( hop_num == 14 && true) %exclude junc10_to_junc11 
        continue;
    end
    idx = meta_data.hop_num == hop_num;
    channel_names = meta_data.link_name(idx);
    f1 = figure('Name', 'hour of min/max');
    f2 = figure('Name', 'RSL of min/max');
    f3 = figure('Name', 'variation size of min/max');
    for n = 1:length(channel_names)
        cn = char(channel_names(n));
        ind_period = db.(cn).time_rssi > ds & db.(cn).time_rssi < de;
        time_rssi_period =  db.(cn).time_rssi(ind_period);
        rssi_period =       db.(cn).rssi(ind_period);

        [y,m,d] = ymd(time_rssi_period);
        [~, first_apperance_of_each_day, unique_serial_num] = unique([y,m,d] ,'rows');
        num_of_days = length(first_apperance_of_each_day);

        SD = db.(cn).standart_deviation;
        avg_period = db.(cn).rsl_median(ind_period);
        
        day = NaT(num_of_days , 1);
        time_in_day_where_max_appears = nan(num_of_days , 1);
        time_in_day_where_min_appears = nan(num_of_days , 1);
        max_rssi = nan(num_of_days , 1);
        min_rssi = nan(num_of_days , 1);
        max_variations = nan(num_of_days , 1);
        min_variations = nan(num_of_days , 1);
        
        for i = 1:num_of_days
            day(i) = time_rssi_period(first_apperance_of_each_day(i));
            ind_cur_day = unique_serial_num == i;
            time_rssi_cur_day = time_rssi_period(ind_cur_day);
            rssi_cur_day = rssi_period(ind_cur_day);
            avg_cur_day = avg_period(ind_cur_day);
            
            [max_val,index_max] = max(rssi_cur_day);
            max_delta = max_val - avg_cur_day(index_max) ;
            if (    max_delta > 0.5*SD     &&   max_delta < 5*SD    ) 
                max_rssi(i) = max_val;
                time_in_day_where_max_appears(i) = hours(timeofday(time_rssi_cur_day(index_max)));
                max_variations(i) = max_delta;
            end
            
            [min_val,index_min] = min(rssi_cur_day);
            min_delta = avg_cur_day(index_min) - min_val  ;
            if(     min_delta > 0.5*SD       &&      min_delta < 2.5*SD )
                min_rssi(i) = min_val;
                time_in_day_where_min_appears(i) = hours(timeofday(time_rssi_cur_day(index_min)));
                min_variations(i) = min_delta;
            end  
        end
        
        figure(f1);
        plot(day, time_in_day_where_max_appears , '*' , 'DisplayName', 'max' ); hold on;
        plot(day, time_in_day_where_min_appears , '*',  'DisplayName', 'min' );
        xlabel('date'); ylabel('hour in day');
        title(['hop ' num2str(hop_num) ' -- ' cn]);
        
        figure(f2); 
        plot(day, max_rssi, 'DisplayName', 'max' ); hold on;
        plot(day, min_rssi ,  'DisplayName', 'min');
        xlabel('date'); ylabel('hour in day');
        title(['hop ' num2str(hop_num) ' -- ' cn]);
        
        figure(f3); 
        plot(day, max_variations, 'DisplayName', 'max' ); hold on;
        plot(day, min_variations ,  'DisplayName', 'min');
        xlabel('date'); ylabel('hour in day');
        title(['hop ' num2str(hop_num) ' -- ' cn]);
    end
end


%% plot AVG anf SD 

map = distinguishable_colors(2);
for hop_num = hops
    if ( hop_num == 14 && true) %exclude junc10_to_junc11 
        continue;
    end
    idx = meta_data.hop_num == hop_num;
    channel_names = meta_data.link_name(idx);
    
    figure;
    for n = 1:length(channel_names)
        cn = char(channel_names(n));
        ind_period = db.(cn).time_rssi > ds & db.(cn).time_rssi < de;
        vector_size = sum(ind_period);
        subplot(2,1,n);
        hold on; plot( db.(cn).time_rssi(ind_period) ,  db.(cn).rssi(ind_period) , 'DisplayName', ['link ' num2str(n)] , 'color' , map(n,:) );
        hold on; plot( db.(cn).time_rssi(ind_period) ,  db.(cn).rsl_median(ind_period), 'DisplayName' , 'AVG' , 'color' , 'k' );
        hold on; plot( db.(cn).time_rssi(ind_period) , db.(cn).rsl_median(ind_period) + 1*db.(cn).standart_deviation    ,'DisplayName' , 'SD' ,'color' ,'k' ,'LineWidth', 1.5  );
        hold on; plot( db.(cn).time_rssi(ind_period) , db.(cn).rsl_median(ind_period) - 0.5*db.(cn).standart_deviation    ,'DisplayName' , 'SD' ,'color' , 'k' ,'LineWidth', 1.5  );
        hold on; plot( db.(cn).time_rssi(ind_period) , db.(cn).rsl_median(ind_period) + 5*db.(cn).standart_deviation  ,'DisplayName' , 'SD' ,'color' ,'k' ,'LineWidth', 1.5  );
        hold on; plot( db.(cn).time_rssi(ind_period) , db.(cn).rsl_median(ind_period) - 2.5*db.(cn).standart_deviation  ,'DisplayName' , 'SD' ,'color' , 'k' ,'LineWidth', 1.5  );
        title([ 'hop' num2str(hop_num), ', ' num2str(meta_data{(cn),'length_KM'}) 'Km ,' cn  ] , 'FontSize', 20);
    end
end

%% FFT

figure;
map = distinguishable_colors(21);
for i = order_hop_num
    if ( i == 14 && true) %exclude junc10_to_junc11 
        continue;
    end
    idx = meta_data.hop_num == i;
    channel_names = meta_data.link_name(idx);
figure;
    for n = 1:length(channel_names)
        cn = char(channel_names(n));
        ind_period = db.(cn).time_rssi > ds & db.(cn).time_rssi<de;
        %A = (db.(cn).rssi(ind_period) - db.(cn).avg_rsl);
        A = db.(cn).rssi(ind_period);
        L = length(A);
        f = (1/30)*(0:(L/2))/L;
        A_fft = fft(A);
        P2 = abs(A_fft/L);
        P1 = P2(1:L/2+1);
        P1(2:end-1) = 2*P1(2:end-1);
        hold on; plot(f(2:end),P1(2:end), 'DisplayName', ['hop' num2str(i), ' link' num2str(n)], 'color' , map(i,:) ) ;
        title('Single-Sided Amplitude Spectrum of X(t)'); xlabel('f (Hz)'); ylabel('|P1(f)|');
    end
end

%% FFT ericsson
ds = datetime(2009,08,01,00,00,00); de = datetime(2009,08,30,59,59,59);
ind = ericsson_db_eband.time > ds & ericsson_db_eband.time <de;
A = ericsson_db_eband.rssi(ind);
L = length(A);
f = (1/67)*(0:(L/2))/L;
A_fft = fft(A);
P2 = abs(A_fft/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
figure; plot(f(2:end),P1(2:end));
title('Single-Sided Amplitude Spectrum of X(t)'); xlabel('f (Hz)'); ylabel('|P1(f)|');

clear ds de;
