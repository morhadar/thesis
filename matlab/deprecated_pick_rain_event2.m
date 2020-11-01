function [ds ,de] = pick_rain_event2(your_pick)
all_dates = [ ...
datetime(2018,06,13,04,30,00), datetime(2018,06,13,05,30,00);  %1 

datetime(2019,04,21,05,30,00), datetime(2019,04,21,07,00,00);   %2  %April, 21(all stations) -- yes! we can see the storm movments!   
datetime(2019,04,21,05,30,00), datetime(2019,04,21,06,30,00);   %3  %April, 21(all stations) -- yes! we can see the storm movments!   
datetime(2019,04,21,06,00,00), datetime(2019,04,21,07,00,00);   %4  %April, 21(all stations) -- yes! we can see the storm movments!   

datetime(2019,04,21,09,50,00), datetime(2019,04,21,11,00,00); % 5   %April, 21(all stations) -- yes! we can see the storm movments!   

datetime(2018,12,30,18,50,00), datetime(2018,12,30,19,50,00); %6 
datetime(2018,12,30,19,50,00), datetime(2018,12,30,20,50,00);  %7
datetime(2018,12,30,20,50,00), datetime(2018,12,30,21,50,00); %8
datetime(2018,12,30,21,50,00), datetime(2018,12,30,22,50,00); %9

datetime(2018,04,25,14,00,00), datetime(2018,04,25,17,00,00);  %13   %April, 25 !!! 
datetime(2018,04,25,14,00,00), datetime(2018,04,25,17,00,00);  %13   %April, 25 !!! 
datetime(2018,04,25,14,00,00), datetime(2018,04,25,17,00,00);  %13   %April, 25 !!! 

datetime(2018,04,25,14,00,00), datetime(2018,04,25,17,00,00);  %13   %April, 25 !!! 

];
ds = all_dates(your_pick, 1);
de = all_dates(your_pick, 2);
end