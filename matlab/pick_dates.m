function [ds, de] = pick_dates(your_pick)
switch (your_pick)
%core:
    case 0; ds = datetime(2018,01,01,00,00,00); de = datetime();                        %all period
    case 1; ds = datetime(2018,02,15,00,00,00); de = datetime(2018,03,20,00,00,00);     %data1
    case 2; ds = datetime(2018,03,19,11,00,00); de = datetime(2018,05,03,23,59,59);     %data2
    case 3; ds = datetime(2018,09,01,00,00,00); de = datetime(2018,09,30,23,59,59);     %data3 - september
%others:
    case 4; ds = datetime(2018,03,03,00,00,00); de = datetime(2018,03,17,00,00,00);     %dry March
    case 5; ds = datetime(2018,04,01,00,00,00); de = datetime(2018,05,05,00,00,00);     %dry April-May   
    case 6; ds = datetime(2018,02,28,00,00,00); de = datetime(2018,03,14,00,00,00);     %dry
    case 7; ds = datetime(2018,09,11,00,00,00); de = datetime(2018,09,25,00,00,00);     %dry september + yum kipur
    case 8; ds = datetime(2018,03,05,00,00,00); de = datetime(2018,03,07,23,59,59);     %24h *3 
    case 9; ds = datetime(2018,03,19,00,00,00); de = datetime(2018,03,20,23,59,59);     %weird event - link11    
    case 10; ds = datetime(2018,02,22,00,00,00); de = datetime(2018,02,23,00,00,00);     %weird event 
    case 11; ds = datetime(2018,03,21,00,00,00); de = datetime(2018,03,26,23,59,59);     %periodicity 
    case 12; ds = datetime(2018,03,21,00,00,00); de = datetime(2018,03,24,23,59,59);     %summer clock
    case 13; ds = datetime(2018,05,27,10,20,00); de = datetime(2018,05,27,17,25,00);     %hop7 (and more) break down
%by mounth
    case 201811;  ds = datetime(2018,11,01,00,00,00); de = datetime(2018,11,30,23,59,59);
    case 201812;  ds = datetime(2018,12,01,00,00,00); de = datetime(2018,12,31,23,59,59);
    case 201901;  ds = datetime(2019,01,01,00,00,00); de = datetime(2019,01,31,23,59,59);
    case 201902;  ds = datetime(2019,02,01,00,00,00); de = datetime(2019,02,28,23,59,59);
    case 201903;  ds = datetime(2019,03,01,00,00,00); de = datetime(2019,03,31,23,59,59);
    case 201904;  ds = datetime(2019,04,01,00,00,00); de = datetime(2019,04,30,23,59,59);
    case 201905;  ds = datetime(2019,05,01,00,00,00); de = datetime(2019,05,31,23,59,59);
    case 201906;  ds = datetime(2019,06,01,00,00,00); de = datetime(2019,06,30,23,59,59);
end
end
