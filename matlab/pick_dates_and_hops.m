%% core:
ds = datetime(2018,01,01,00,00,00); de = datetime();                        %all period
ds = datetime(2018,02,15,00,00,00); de = datetime(2018,03,20,00,00,00);     %data1
ds = datetime(2018,03,19,11,00,00); de = datetime(2018,05,03,23,59,59);     %data2
ds = datetime(2018,09,01,00,00,00); de = datetime(2018,09,30,23,59,59);     %data3 - september
%% rain events:
ds = datetime(2018,02,16,00,00,00); de = datetime(2018,02,17,20,00,00);     %February, 17
ds = datetime(2018,02,22,00,00,00); de = datetime(2018,02,22,05,00,00);     %February, 22
ds = datetime(2018,02,27,00,06,00); de = datetime(2018,02,27,08,00,00);     %February, 27 
ds = datetime(2018,03,28,04,00,00); de = datetime(2018,03,28,07,00,00);     %March, 28 - too weak
ds = datetime(2018,03,29,00,00,00); de = datetime(2018,03,30,23,59,59);     %March, 29 - too strong, killed the links
ds = datetime(2018,04,10,00,00,00); de = datetime(2018,04,11,23,00,00);     %April, 10-11 
ds = datetime(2018,04,22,00,00,00); de = datetime(2018,04,22,07,00,00);     %April, 22
ds = datetime(2018,04,25,00,00,00); de = datetime(2018,04,25,23,00,00);     %April, 25 !!! 
ds = datetime(2018,04,26,00,00,00); de = datetime(2018,04,26,23,00,00);     %April, 26
ds = datetime(2018,05,07,04,00,00); de = datetime(2018,05,07,07,00,00);     %May, 7 - no data
ds = datetime(2018,05,12,00,00,00); de = datetime(2018,05,12,07,00,00);     %May, 12 - no data
ds = datetime(2018,05,12,00,00,00); de = datetime(2018,05,12,14,00,00);     %May, 12 - no data
ds = datetime(2018,06,12,00,00,00); de = datetime(2018,06,12,23,59,59);     %June, 12
ds = datetime(2018,06,13,00,00,00); de = datetime(2018,06,13,23,59,59);     %June, 13 
ds = datetime(2018,09,08,00,00,00); de = datetime(2018,09,08,23,59,59);     %September, 8
ds = datetime(2018,10,08,02,00,00); de = datetime(2018,10,08,05,00,00);     %October,18(beit daga)  -- probably no rain in Rehovot
ds = datetime(2018,10,25,17,00,00); de = datetime(2018,10,26,07,00,00);     %October, 25(all stations) -- yes!
ds = datetime(2018,11,04,22,00,00); de = datetime(2018,11,05,07,00,00);     %November, 4-5(all stations) -- yes!
ds = datetime(2018,11,05,13,00,00); de = datetime(2018,11,05,15,00,00);     %November, 5(kvotzat yavne) -- small effect
ds = datetime(2018,11,05,17,00,00); de = datetime(2018,11,06,11,00,00);     %November, 5-6(all stations) --yes!
ds = datetime(2018,11,10,07,00,00); de = datetime(2018,11,10,11,00,00);     %November, 10(nahshon) -- yes! might be longer event in rehovot
ds = datetime(2018,11,12,03,00,00); de = datetime(2018,11,12,11,00,00);     %November, 12(all stations) -- yes
ds = datetime(2018,11,14,17,00,00); de = datetime(2018,11,14,23,00,00);     %November, 14(all stations) -- small efect
ds = datetime(2018,11,16,02,00,00); de = datetime(2018,11,16,21,00,00);     %November, 16(all stations) -- yes!
ds = datetime(2018,11,22,11,00,00); de = datetime(2018,11,22,15,00,00);     %November, 22(all stations) -- smal effect maybe
ds = datetime(2018,11,23,02,00,00); de = datetime(2018,11,24,23,59,59);     %November, 23-24(all stations) -- yes! 
ds = datetime(2018,11,25,21,00,00); de = datetime(2018,11,26,03,00,00);     %November, 25-26(small event) -- see nothing
ds = datetime(2018,12,01,00,00,00); de = datetime(2018,12,01,23,00,00);     %December, 1(all stations) -- yes!!!
ds = datetime(2018,12,06,00,00,00); de = datetime(2018,12,09,02,00,00);     %December, 6-9(all stations) -- yes!
ds = datetime(2018,12,12,16,00,00); de = datetime(2018,12,12,23,00,00);     %December, 12(all stations) -- yes!
ds = datetime(2018,12,17,18,00,00); de = datetime(2018,12,18,05,00,00);     %December, 17-18(all stations) -- yes! 
ds = datetime(2018,12,19,19,00,00); de = datetime(2018,12,21,10,00,00);     %December, 19-21(all stations) -- yes!
ds = datetime(2018,12,22,00,00,00); de = datetime(2018,12,24,23,00,00);     %December, 22-24(small events) -- yes!
ds = datetime(2018,12,27,04,00,00); de = datetime(2018,12,28,10,00,00);     %December, 27-28(all stations) -- yes!
ds = datetime(2018,12,29,03,00,00); de = datetime(2018,12,29,21,00,00);     %December, 29(all stations) -- yes
ds = datetime(2018,12,30,00,00,00); de = datetime(2018,12,30,23,59,00);     %December, 30(all stations) -- yes
ds = datetime(2018,12,31,22,00,00); de = datetime(2019,01,01,04,00,00);     %December, 31 - January,1(small event) -- see nothing
ds = datetime(2019,01,02,16,00,00); de = datetime(2019,01,03,04,00,00);     %January, 2-3(all stations) -- yes!
ds = datetime(2019,01,06,14,00,00); de = datetime(2019,01,07,04,00,00);     %January, 6-7(all stations) -- yes! 
ds = datetime(2019,01,08,10,00,00); de = datetime(2019,01,10,10,00,00);     %January, 8-10(all stations) -- yes!
ds = datetime(2019,01,13,16,00,00); de = datetime(2019,01,14,20,00,00);     %January, 13-14(small event) -- yes!
ds = datetime(2019,01,14,10,00,00); de = datetime(2019,01,14,17,00,00);     %January, 14(all stations) -- yes(small effect)
ds = datetime(2019,01,16,13,00,00); de = datetime(2019,01,17,07,00,00);     %January, 16-17(all stations) -- yes!
ds = datetime(2019,01,17,21,00,00); de = datetime(2019,01,17,22,00,00);     %January, 17(kvotzat yavne) -- see nothing
ds = datetime(2019,01,28,08,00,00); de = datetime(2019,01,29,04,00,00);     %January, 28-29(all stations, many short events) -- no data
ds = datetime(2019,02,06,14,00,00); de = datetime(2019,02,07,13,00,00);     %February, 6-7(all stations) -- yes!
ds = datetime(2019,02,08,21,00,00); de = datetime(2019,02,11,12,00,00);     %February, 8-11(all stations) -- yes!
ds = datetime(2019,02,14,04,00,00); de = datetime(2019,02,14,05,00,00);     %February, 14(kvotzat yavne, small event) -- 
ds = datetime(2019,02,14,19,00,00); de = datetime(2019,02,15,03,00,00);     %February, 14-15(beit dagan and nahshon) -- see nothing
ds = datetime(2019,02,15,19,00,00); de = datetime(2019,02,16,11,00,00);     %February, 15-16(all stations) -- yes!
ds = datetime(2019,02,18,01,00,00); de = datetime(2019,02,20,05,00,00);     %February, 18-20(small events) -- yes!
ds = datetime(2019,02,26,21,00,00); de = datetime(2019,03,01,09,00,00);     %February, 26 - March, 1(all stations) -- yes!
ds = datetime(2019,03,01,18,00,00); de = datetime(2019,03,02,14,00,00);     %March, 1-2(all stations) -- yes!
ds = datetime(2019,03,03,02,00,00); de = datetime(2019,03,03,04,00,00);     %March, 3(nahshon) -- see nothing
ds = datetime(2019,03,03,22,00,00); de = datetime(2019,03,04,13,00,00);     %March, 3-4(all stations) -- yes!
ds = datetime(2019,03,05,12,00,00); de = datetime(2019,03,05,18,00,00);     %March, 5(all stations) -- see nothing
ds = datetime(2019,03,07,19,00,00); de = datetime(2019,03,07,21,00,00);     %March, ??(nahshon, small event) -- see nothing
ds = datetime(2019,03,13,18,00,00); de = datetime(2019,03,13,22,00,00);     %March, 13(all stations) -- see nothing(?)
ds = datetime(2019,03,14,03,00,00); de = datetime(2019,03,14,21,00,00);     %March, 14(all stations) -- yrs!
ds = datetime(2019,03,15,00,00,00); de = datetime(2019,03,15,06,00,00);     %March, 15(small event) -- see nothing
ds = datetime(2019,03,16,07,00,00); de = datetime(2019,03,17,07,00,00);     %March, 16-17(all stations) -- yes
ds = datetime(2019,03,23,16,00,00); de = datetime(2019,03,24,10,00,00);     %March, 23-24(all stations, small events) -- see nothing (?)
ds = datetime(2019,03,24,18,00,00); de = datetime(2019,03,25,18,00,00);     %March, 24-25(all stations) -- yes! 
ds = datetime(2019,03,26,03,00,00); de = datetime(2019,03,26,08,00,00);     %March, 26(all stations) -- see nothing, but there is somthing weird with 2 of the link 
ds = datetime(2019,03,28,22,00,00); de = datetime(2019,03,30,02,00,00);     %March, 28-30(all stations, small events) -- see nothing
ds = datetime(2019,03,30,09,00,00); de = datetime(2019,04,01,12,00,00);     %March, 30 - April 4(all stations) -- yes!
ds = datetime(2019,04,01,22,00,00); de = datetime(2019,04,02,01,00,00);     %April, 1-2(all stations) -- yes in the longer link
ds = datetime(2019,04,15,14,00,00); de = datetime(2019,04,16,08,00,00);     %April, 15-16(all stations) -- yes, a little bit
ds = datetime(2019,04,17,08,00,00); de = datetime(2019,04,18,06,00,00);     %April, 17-18(all stations, small events) -- yes! we can see the storm movments!
ds = datetime(2019,04,19,05,00,00); de = datetime(2019,04,20,14,00,00);     %April, 19-20(all stations,small events) -- see nothing
ds = datetime(2019,04,21,00,00,00); de = datetime(2019,04,21,16,00,00);     %April, 21(all stations) -- yes! we can see the storm movments!
ds = datetime(2019,04,22,04,00,00); de = datetime(2019,04,22,10,00,00);     %April, 22(beit dagan) -- see nothing

%% others:
ds = datetime(2018,03,03,00,00,00); de = datetime(2018,03,17,00,00,00);     %dry March
ds = datetime(2018,04,01,00,00,00); de = datetime(2018,05,05,00,00,00);     %dry April-May   
ds = datetime(2018,02,28,00,00,00); de = datetime(2018,03,14,00,00,00);     %dry
ds = datetime(2018,09,11,00,00,00); de = datetime(2018,09,25,00,00,00);     %dry september + yum kipur

ds = datetime(2018,03,05,00,00,00); de = datetime(2018,03,07,23,59,59);     %24h *3 
ds = datetime(2018,03,19,00,00,00); de = datetime(2018,03,20,23,59,59);     %weird event - link11    
ds = datetime(2018,02,22,00,00,00); de = datetime(2018,02,23,00,00,00);     %weird event 
ds = datetime(2018,03,21,00,00,00); de = datetime(2018,03,26,23,59,59);     %periodicity 
ds = datetime(2018,03,21,00,00,00); de = datetime(2018,03,24,23,59,59);     %summer clock
ds = datetime(2018,05,27,10,20,00); de = datetime(2018,05,27,17,25,00);     %hop7 (and more) break down

%% by mounth
switch(201901)
    case 201811;  ds = datetime(2018,11,01,00,00,00); de = datetime(2018,11,30,23,59,59);
    case 201812;  ds = datetime(2018,12,01,00,00,00); de = datetime(2018,12,31,23,59,59);
    case 201901;  ds = datetime(2019,01,01,00,00,00); de = datetime(2019,01,31,23,59,59);
    case 201902;  ds = datetime(2019,02,01,00,00,00); de = datetime(2019,02,28,23,59,59);
    case 201903;  ds = datetime(2019,03,01,00,00,00); de = datetime(2019,03,31,23,59,59);
    case 201904;  ds = datetime(2019,04,01,00,00,00); de = datetime(2019,04,30,23,59,59);
    case 201905;  ds = datetime(2019,05,01,00,00,00); de = datetime(2019,05,31,23,59,59);
    case 201906;  ds = datetime(2019,06,01,00,00,00); de = datetime(2019,06,30,23,59,59);
end

