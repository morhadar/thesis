function [ds ,de] = pick_rain_event(your_pick)
%% choose hops
switch (your_pick)
    case 0 %April, 25 !!! 
        ds = datetime(2018,04,25,14,00,00); de = datetime(2018,04,25,17,00,00);     
    case 1 %April, 21(all stations) -- yes! we can see the storm movments!
        ds = datetime(2019,04,21,00,00,00); de = datetime(2019,04,21,16,00,00);     
    case 2   %April, 21(all stations) -- yes! we can see the storm movments!
        ds = datetime(2019,04,21,04,00,00); de = datetime(2019,04,21,08,00,00);   
    case 3     %April, 21(all stations) -- yes! we can see the storm movments!
        ds = datetime(2019,04,21,09,00,00); de = datetime(2019,04,21,11,00,00); 
end
end