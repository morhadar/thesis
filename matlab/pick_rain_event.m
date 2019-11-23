function [ds ,de] = pick_rain_event(your_pick)
%TODO - do some arangment in the dates:


all_dates = ...
[datetime(2018,02,17,01,30,00), datetime(2018,02,17,03,30,00);  %1 
datetime(2018,02,17,04,30,00), datetime(2018,02,17,10,00,00);  %2 
datetime(2018,02,17,11,00,00), datetime(2018,02,17,15,00,00);  %3 %TODO - consider split to 2 events. 
datetime(2018,02,17,18,00,00), datetime(2018,02,18,01,00,00);  %4 %TODO - in other places the event was longer. consider taking shorter duration.
datetime(2018,02,22,00,00,00), datetime(2018,02,22,05,00,00);  %5 %TODO - in other places the event was longer. consider taking shorter duration.
datetime(2018,02,27,02,30,00), datetime(2018,02,27,06,00,00);  %6 
datetime(2018,02,27,06,00,00), datetime(2018,02,27,07,00,00);  %7 
datetime(2018,03,28,04,00,00), datetime(2018,03,28,07,00,00);  %8 too weak
datetime(2018,03,29,22,00,00), datetime(2018,03,29,23,59,59);   %9  strong event in the night we visited rehovot.
datetime(2018,04,10,06,00,00), datetime(2018,04,10,10,30,00);   %10 
datetime(2018,04,10,10,30,00), datetime(2018,04,10,16,00,00);   %11 
datetime(2018,04,22,00,00,00), datetime(2018,04,22,07,00,00);   %12 %very weak!
datetime(2018,04,25,14,00,00), datetime(2018,04,25,17,00,00);  %13   %April, 25 !!! 
datetime(2018,04,26,16,00,00), datetime(2018,04,26,18,00,00);  %14
%datetime(2018,05,07,04,00,00), datetime(2018,05,07,07,00,00);  %May, 7 - no data
%datetime(2018,05,12,00,00,00), datetime(2018,05,12,07,00,00);  %May, 12 - no data
%datetime(2018,05,12,00,00,00), datetime(2018,05,12,14,00,00);  %May, 12 - no data
datetime(2018,06,12,00,00,00), datetime(2018,06,12,23,59,59);   %15  June, 12 -- see nothing!
datetime(2018,06,13,04,30,00), datetime(2018,06,13,05,30,00);  %16 
datetime(2018,09,08,07,30,00), datetime(2018,09,08,09,30,00);  %17  september,8 -- very weak
datetime(2018,09,08,19,00,00), datetime(2018,09,08,21,00,00);  %18  september,8 -- very weak
datetime(2018,10,25,19,30,00), datetime(2018,10,26,03,00,00);  %19
datetime(2018,11,04,23,30,00), datetime(2018,11,05,03,00,00);  %20 -- yes!
datetime(2018,11,05,13,00,00), datetime(2018,11,05,15,00,00);  %21 see nothing
datetime(2018,11,05,16,00,00), datetime(2018,11,06,09,00,00);  %22   consider to split

datetime(2018,11,10,07,00,00), datetime(2018,11,10,11,00,00);   %23  see nothing
datetime(2018,11,12,03,00,00), datetime(2018,11,12,07,00,00);   %24  see movements
datetime(2018,11,14,17,00,00), datetime(2018,11,14,23,00,00);   %25 small efect
datetime(2018,11,16,02,30,00), datetime(2018,11,16,10,00,00);   %26 consider split!! (no data between 16.11 09:30 - 18.11 14:30)
datetime(2018,11,22,11,00,00), datetime(2018,11,22,15,00,00);  %27   see nothing 
datetime(2018,11,23,02,30,00), datetime(2018,11,23,12,00,00);  %28    consider split
datetime(2018,11,23,15,30,00), datetime(2018,11,24,01,40,00);  %29     
datetime(2018,11,24,02,00,00), datetime(2018,11,24,09,00,00);  %30    links crashed after thats
datetime(2018,11,25,21,00,00), datetime(2018,11,26,03,00,00); %31  see nothing
datetime(2018,12,01,06,40,00), datetime(2018,12,01,10,00,00);  %32

datetime(2018,12,06,05,40,00), datetime(2018,12,06,07,00,00);  %33
datetime(2018,12,06,07,50,00), datetime(2018,12,06,09,20,00);  %34   
datetime(2018,12,06,09,10,00), datetime(2018,12,06,12,00,00);  %35 
datetime(2018,12,06,12,00,00), datetime(2018,12,06,15,30,00);  %36
datetime(2018,12,06,15,30,00), datetime(2018,12,06,17,00,00);  %37
datetime(2018,12,06,18,10,00), datetime(2018,12,06,20,20,00);  %38  
datetime(2018,12,06,20,10,00), datetime(2018,12,06,22,00,00);  %39  
datetime(2018,12,06,22,00,00), datetime(2018,12,07,01,00,00);  %40   
datetime(2018,12,07,00,10,00), datetime(2018,12,07,01,20,00);  %41   
datetime(2018,12,07,01,20,00), datetime(2018,12,07,03,30,00);  %42   
datetime(2018,12,07,03,10,00), datetime(2018,12,07,07,00,00);  %43   
datetime(2018,12,07,06,00,00), datetime(2018,12,07,07,50,00);  %44   
datetime(2018,12,07,07,50,00), datetime(2018,12,07,10,40,00);  %45   
datetime(2018,12,07,10,40,00), datetime(2018,12,07,12,00,00);  %46   
datetime(2018,12,07,13,00,00), datetime(2018,12,07,14,30,00);  %47   
datetime(2018,12,07,16,20,00), datetime(2018,12,07,18,40,00);  %48   
datetime(2018,12,07,19,50,00), datetime(2018,12,07,21,00,00);  %49   
datetime(2018,12,08,23,10,00), datetime(2018,12,08,00,40,00);  %50   
datetime(2018,12,08,00,10,00), datetime(2018,12,08,05,40,00);  %51   
datetime(2018,12,08,05,00,00), datetime(2018,12,08,05,40,00);  %52   
datetime(2018,12,08,08,00,00), datetime(2018,12,08,11,00,00);  %53   
datetime(2018,12,08,11,30,00), datetime(2018,12,08,15,10,00);  %54   
datetime(2018,12,08,15,00,00), datetime(2018,12,08,16,00,00);  %55   
datetime(2018,12,08,16,30,00), datetime(2018,12,08,18,00,00);  %56   
datetime(2018,12,08,18,00,00), datetime(2018,12,08,19,30,00);  %57   
datetime(2018,12,08,21,00,00), datetime(2018,12,08,23,30,00);  %58   
%datetime(2018,12,06,00,00,00), datetime(2018,12,06,02,00,00);  %33   3 days of rain in december!
datetime(2018,12,12,17,00,00), datetime(2018,12,12,19,30,00);   %59 
datetime(2018,12,12,21,30,00), datetime(2018,12,12,22,30,00);   %60
datetime(2018,12,17,19,40,00), datetime(2018,12,17,21,50,00); %61 
datetime(2018,12,17,21,00,00), datetime(2018,12,17,22,50,00); %62   
datetime(2018,12,17,22,00,00), datetime(2018,12,18,00,30,00); %63  
datetime(2018,12,19,20,20,00), datetime(2018,12,19,23,00,00); %64    
datetime(2018,12,20,00,20,00), datetime(2018,12,20,02,00,00); %65    
datetime(2018,12,20,02,00,00), datetime(2018,12,20,03,10,00); %66    
datetime(2018,12,20,04,30,00), datetime(2018,12,20,06,10,00); %67   
datetime(2018,12,20,06,30,00), datetime(2018,12,20,07,30,00); %68    
datetime(2018,12,20,07,30,00), datetime(2018,12,20,09,30,00); %69   
datetime(2018,12,20,14,30,00), datetime(2018,12,20,15,50,00); %70   
datetime(2018,12,20,19,00,00), datetime(2018,12,20,20,00,00); %71    
datetime(2018,12,20,20,00,00), datetime(2018,12,21,00,10,00); %72
datetime(2018,12,24,06,30,00), datetime(2018,12,24,09,30,00);   %73 small affect

%TODO continue from here:
%datetime(2018,12,27,04,00,00), datetime(2018,12,28,10,00,00);  %December, 27-28
datetime(2018,12,27,07,00,00), datetime(2018,12,27,08,50,00);  %74 %links are not working befor that.
datetime(2018,12,27,08,40,00), datetime(2018,12,27,09,36,00);  %75
datetime(2018,12,27,09,30,00), datetime(2018,12,27,10,50,00);  %76
datetime(2018,12,27,10,40,00), datetime(2018,12,27,11,45,00);  %77
datetime(2018,12,27,14,50,00), datetime(2018,12,27,15,55,00);  %78
datetime(2018,12,27,15,50,00), datetime(2018,12,27,16,30,00);  %79
datetime(2018,12,27,16,20,00), datetime(2018,12,27,17,20,00);  %80
datetime(2018,12,27,17,35,00), datetime(2018,12,27,18,25,00);  %81
datetime(2018,12,27,18,48,00), datetime(2018,12,27,20,00,00);  %82
datetime(2018,12,27,20,00,00), datetime(2018,12,27,21,00,00);  %83
datetime(2018,12,28,01,00,00), datetime(2018,12,28,02,00,00);  %84
datetime(2018,12,28,03,00,00), datetime(2018,12,28,04,20,00);  %85
datetime(2018,12,28,04,20,00), datetime(2018,12,28,05,00,00);  %86
%datetime(2018,12,28,03,00,00), datetime(2018,12,28,05,00,00); %combination of 85+86
datetime(2018,12,28,05,55,00), datetime(2018,12,28,07,30,00);  %87
datetime(2018,12,29,03,00,00), datetime(2018,12,29,21,00,00);  %88   consider to split
%datetime(2018,12,30,00,00,00), datetime(2018,12,30,23,59,00);  combination of 
datetime(2018,12,30,15,00,00), datetime(2018,12,30,16,30,00);  %89 %links weren't working befor that.
datetime(2018,12,30,16,30,00), datetime(2018,12,30,17,50,00);  %90
datetime(2018,12,30,18,50,00), datetime(2018,12,30,19,50,00);  %91
datetime(2018,12,30,19,50,00), datetime(2018,12,30,22,00,00);  %92
%datetime(2018,12,31,22,00,00), datetime(2019,01,01,04,00,00);  see nothing (but there is an increase in RSL for one of the links)
datetime(2019,01,02,17,30,00), datetime(2019,01,02,18,30,00);   %93
datetime(2019,01,02,23,40,00), datetime(2019,01,03,01,00,00);  %94
%TODO - continue to split from here:
datetime(2019,01,06,14,00,00), datetime(2019,01,07,04,00,00);     %January, 6-7(all stations) -- yes! 
datetime(2019,01,08,10,00,00), datetime(2019,01,10,10,00,00);     %January, 8-10(all stations) -- yes!
datetime(2019,01,13,16,00,00), datetime(2019,01,14,20,00,00);     %January, 13-14(small event) -- yes!
datetime(2019,01,14,10,00,00), datetime(2019,01,14,17,00,00);     %January, 14(all stations) -- yes(small effect)
datetime(2019,01,16,13,00,00), datetime(2019,01,17,07,00,00);     %January, 16-17(all stations) -- yes!
datetime(2019,01,17,21,00,00), datetime(2019,01,17,22,00,00);     %January, 17(kvotzat yavne) -- see nothing
datetime(2019,01,28,08,00,00), datetime(2019,01,29,04,00,00);     %January, 28-29(all stations, many short events) -- no data
datetime(2019,02,06,14,00,00), datetime(2019,02,07,13,00,00);     %February, 6-7(all stations) -- yes!
datetime(2019,02,08,21,00,00), datetime(2019,02,11,12,00,00);     %February, 8-11(all stations) -- yes!
datetime(2019,02,14,04,00,00), datetime(2019,02,14,05,00,00);     %February, 14(kvotzat yavne, small event) -- 
datetime(2019,02,14,19,00,00), datetime(2019,02,15,03,00,00);     %February, 14-15(beit dagan and nahshon) -- see nothing
datetime(2019,02,15,19,00,00), datetime(2019,02,16,11,00,00);     %February, 15-16(all stations) -- yes!
datetime(2019,02,18,01,00,00), datetime(2019,02,20,05,00,00);     %February, 18-20(small events) -- yes!
datetime(2019,02,26,21,00,00), datetime(2019,03,01,09,00,00);     %February, 26 - March, 1(all stations) -- yes!
datetime(2019,03,01,18,00,00), datetime(2019,03,02,14,00,00);     %March, 1-2(all stations) -- yes!
datetime(2019,03,03,02,00,00), datetime(2019,03,03,04,00,00);     %March, 3(nahshon) -- see nothing
datetime(2019,03,03,22,00,00), datetime(2019,03,04,13,00,00);     %March, 3-4(all stations) -- yes!
datetime(2019,03,05,12,00,00), datetime(2019,03,05,18,00,00);     %March, 5(all stations) -- see nothing
datetime(2019,03,07,19,00,00), datetime(2019,03,07,21,00,00);     %March, ??(nahshon, small event) -- see nothing
datetime(2019,03,13,18,00,00), datetime(2019,03,13,22,00,00);     %March, 13(all stations) -- see nothing(?)
datetime(2019,03,14,03,00,00), datetime(2019,03,14,21,00,00);     %March, 14(all stations) -- yrs!
datetime(2019,03,15,00,00,00), datetime(2019,03,15,06,00,00);     %March, 15(small event) -- see nothing
datetime(2019,03,16,07,00,00), datetime(2019,03,17,07,00,00);     %March, 16-17(all stations) -- yes
datetime(2019,03,23,16,00,00), datetime(2019,03,24,10,00,00);     %March, 23-24(all stations, small events) -- see nothing (?)
datetime(2019,03,24,18,00,00), datetime(2019,03,25,18,00,00);     %March, 24-25(all stations) -- yes! 
datetime(2019,03,26,03,00,00), datetime(2019,03,26,08,00,00);     %March, 26(all stations) -- see nothing, but there is somthing weird with 2 of the link 
datetime(2019,03,28,22,00,00), datetime(2019,03,30,02,00,00);     %March, 28-30(all stations, small events) -- see nothing
datetime(2019,03,30,09,00,00), datetime(2019,04,01,12,00,00);     %March, 30 - April 4(all stations) -- yes!
datetime(2019,04,01,22,00,00), datetime(2019,04,02,01,00,00);     %April, 1-2(all stations) -- yes in the longer link
datetime(2019,04,15,14,00,00), datetime(2019,04,16,08,00,00);     %April, 15-16(all stations) -- yes, a little bit
datetime(2019,04,17,08,00,00), datetime(2019,04,18,06,00,00);     %April, 17-18(all stations, small events) -- yes! we can see the storm movments!
datetime(2019,04,19,05,00,00), datetime(2019,04,20,14,00,00);     %April, 19-20(all stations,small events) -- see nothing
datetime(2019,04,21,00,00,00), datetime(2019,04,21,16,00,00);     %April, 21(all stations) -- yes! we can see the storm movments!   
datetime(2019,04,21,04,00,00), datetime(2019,04,21,08,00,00);     %April, 21(all stations) -- yes! we can see the storm movments! 
datetime(2019,04,21,09,00,00), datetime(2019,04,21,11,00,00);   %129  %April, 21(all stations) -- yes! we can see the storm movments!
datetime(2019,04,22,04,00,00), datetime(2019,04,22,10,00,00);    %April, 22(beit dagan) -- see nothing
datetime(2018,03,06,08,00,00), datetime(2018,03,06,11,00,00);   %dry period!
datetime(2018,10,08,02,00,00), datetime(2018,10,08,05,00,00)]; %132 %dry period! %October,18(beit daga)  -- probably no rain in Rehovot


ds = all_dates(your_pick, 1);
de = all_dates(your_pick, 2);
end