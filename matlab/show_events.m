%% plot attenuation of hops: 
bias = 0;
map = distinguishable_colors(length(hops), {'w','k'});
%nn=1;
figure;
for i = 1:length(hops)
    hop = char(hops(i));
    %subplot(length(hops)+1,1,nn);
    %nn = nn+1;
    directions = fieldnames(db.(hop));
    for j = 1%1:length(directions) %{'up' ,'down'}
        direction = char(directions(j));
        rsl = db.(hop).(char(direction)).raw(:,2);
        mean = db.(hop).(direction).mean;
        %rsl = conv(rsl, ones(1,20)/20 , 'same'); %smoothing 2 min samples
        %rsl = conv( rsl , [0, 1 -1] , 'same');
        %rsl = rsl/meta_data{hop, 'length'}; % normalize dm to dbm.
        t = datetime(db.(hop).(char(direction)).raw(:,1), 'ConvertFrom', 'posixtime') ;
       % hold on; plot( t(t > ds & t < de) , rsl(t > ds & t < de) + bias, 'DisplayName', [hop ' ' direction] , 'color', map(i,:));
        hold on; plot( t(t > ds & t < de) , rsl(t > ds & t < de) + bias - mean(t > ds & t < de) , 'DisplayName', [hop ' ' direction] , 'color', map(i,:));
        bias = bias -2;
        
        title([ char(ds) ' - ' char(de)]);
        %subplot(2,1,1);        
    end    
end

%add ims data in subplot
%******** automatic measurments********** 
%subplot(5,1,5);
% yyaxis right
% ind_period = ims_db.beit_dagan.time > ds & ims_db.beit_dagan.time < de;
% hold on; plot( ims_db.beit_dagan.time(ind_period) ,ims_db.beit_dagan.rh(ind_period) , 'DisplayName' , 'rh' );

%human measurments!!!!
% subplot(2,1,2);
% ind_period = ims_db_clouds.beit_dagan_m.time > ds & ims_db_clouds.beit_dagan_m.time<de;
% hold on; plot( ims_db_clouds.beit_dagan_m.time(ind_period) ,ims_db_clouds.beit_dagan_m.(ind_period), 'DisplayName' , 'atmospheric_pressure');
clear i j bias map nn directions direction A t mean rsl
%% plot rain gaues 
stations = ["beit_dagan" , "hafetz_haim" , "nahshon" , "kvotzat_yavne"];

figure;
title('rainy days');
xlabel('date and time');
ylabel('R mm/h');
for i = 1:4
    s = stations(i);
    ind_period = ims_db.(s).time > ds & ims_db.(s).time<de;
    hold on; plot(ims_db.(s).time(ind_period) ,ims_db.(s).rain(ind_period) * 6, 'DisplayName', s);
end
%ind = gamliel_db.time  > ds & gamliel_db.time <de;
%hold on; plot( gamliel_db.time(ind) , gamliel_db.rain(ind) *6 , 'DisplayName' , 'gamliel', 'LineWidth', 2);

% add constraints:
% hold on; plot( ds:seconds(30):de , 0.4*ones(size(ds:seconds(30):de)) , 'DisplayName' , 'lowerbound', 'color' , 'r', 'LineWidth', 2);
% hold on; plot( ds:seconds(30):de , 40*ones(size(ds:seconds(30):de)) , 'DisplayName' , 'upperbound', 'color' , 'g', 'LineWidth' ,2);
% if(true) % add minimal threshold for specific links
%     for i = hops
%         idx = meta_data.hop_num == i;
%         idx = find(idx,1);
%         hold on; plot( ds:seconds(30):de , meta_data.minimal_rain_rate(idx)*ones(size(ds:seconds(30):de)) , 'DisplayName' , ['hop ' num2str(i) ' boundary'], 'color' , 'k');
%     end
% end

clear i s ind_period stations
