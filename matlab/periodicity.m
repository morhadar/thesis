%% choose hop
hop_num = 4; 
%% plot min/max and time in day
option = 1;
idx = meta_data.hop_num == hop_num;
channel_names = meta_data.link_name(idx);
map = [ [1,0,0] ; [0.8,0,0] ; [0,0,0.5] ; [0,0,1]];

for n = 1:length(channel_names)
    cn = char(channel_names(n));
    ind_period = db.(cn).time_rssi > ds & db.(cn).time_rssi < de;
    time_rssi_period = db.(cn).time_rssi(ind_period);
    rssi_period = db.(cn).rssi(ind_period);
    
    [y,m,d]=ymd(time_rssi_period);
    [~, first_apperance_of_each_day, unique_serial_num] = unique([y,m,d] ,'rows');
    num_of_days = length(first_apperance_of_each_day);
    
    SD = db.(cn).standart_deviation;
    AVG = db.(cn).avg_rsl;
    day = NaT(num_of_days , 1);
    time_in_day_where_max_appears = nan(num_of_days , 1);
    time_in_day_where_min_appears = nan(num_of_days , 1);
    max_rssi = nan(num_of_days , 1);
    min_rssi = nan(num_of_days , 1);
    for i =1:num_of_days
        day(i) = time_rssi_period(first_apperance_of_each_day(i));
        ind_cur_day = unique_serial_num == i;
        time_rssi_cur_day = time_rssi_period(ind_cur_day);
        rssi_cur_day = rssi_period(ind_cur_day);
        [max_rssi(i),index_max] = max(rssi_cur_day);
        [min_rssi(i),index_min] = min(rssi_cur_day);
        if (option ==1)
            if ( abs(max_rssi(i) - AVG ) > SD && abs(max_rssi(i) - AVG ) < 4.5*SD ) 
                time_in_day_where_max_appears(i) = hours(timeofday(time_rssi_cur_day(index_max)));
            else
                max_rssi(i) = nan;
                time_in_day_where_max_appears(i) = nan;
            end

            if( abs(min_rssi(i) - AVG ) > SD && abs(min_rssi(i) - AVG ) < 4.5*SD )
                time_in_day_where_min_appears(i) = hours(timeofday(time_rssi_cur_day(index_min)));
            else
                min_rssi(i) = nan;
                time_in_day_where_min_appears(i) = nan;
            end  
        else(option == 2)
                %TODO - 
        end
    end
    figure;
    plot(day, time_in_day_where_max_appears , '*' , 'DisplayName', 'max' , 'color' , map(n,:)); hold on;
    plot(day, time_in_day_where_min_appears , '*',  'DisplayName', 'min' , 'color' , map(n+2,:));
    xlabel('date'); ylabel('hour in day')';
    title(['hop ' num2str(hop_num) ' -- ' cn]);
    
end


%% plot AVG anf SD 

idx = meta_data.hop_num == hop_num;
channel_names = meta_data.link_name(idx);

map = distinguishable_colors(2);
figure;
for n = 1:length(channel_names)
    cn = char(channel_names(n));
    ind_period = db.(cn).time_rssi > ds & db.(cn).time_rssi < de;
    vector_size = sum(ind_period);
    subplot(2,1,n);
    hold on;
    plot( db.(cn).time_rssi(ind_period) , db.(cn).rssi(ind_period) , 'DisplayName', ['link ' num2str(n)] , 'color' , map(n,:) );
    hold on; plot(  db.(cn).time_rssi(ind_period) , db.(cn).avg_rsl * ones(1,vector_size), 'DisplayName' , 'AVG' , 'color' , 'k' );
    hold on; plot( db.(cn).time_rssi(ind_period) , (db.(cn).avg_rsl + 1*db.(cn).standart_deviation)* ones(1,vector_size)   ,'DisplayName' , 'SD' ,'color' ,'k' ,'LineWidth', 1.5  );
    hold on; plot( db.(cn).time_rssi(ind_period) , (db.(cn).avg_rsl - 1*db.(cn).standart_deviation)* ones(1,vector_size)   ,'DisplayName' , 'SD' ,'color' , 'k' ,'LineWidth', 1.5  );
    hold on; plot( db.(cn).time_rssi(ind_period) , (db.(cn).avg_rsl + 4.5*db.(cn).standart_deviation)* ones(1,vector_size)   ,'DisplayName' , 'SD' ,'color' ,'k' ,'LineWidth', 1.5  );
    hold on; plot( db.(cn).time_rssi(ind_period) , (db.(cn).avg_rsl - 4.5*db.(cn).standart_deviation)* ones(1,vector_size)   ,'DisplayName' , 'SD' ,'color' , 'k' ,'LineWidth', 1.5  );
    title([ 'hop' num2str(hop_num), ', ' num2str(meta_data{(cn),'length_KM'}) 'Km ,' cn  ] , 'FontSize', 20);
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
