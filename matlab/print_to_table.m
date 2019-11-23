function T = print_to_table(storms_info, events_to_print , storms_in_rehovot)
T = table(0, datetime, datetime, 0, 0, 0, 0, 0) ;
T.Properties.VariableNames = {'eventID', 'ds', 'de', 'duration', 'active_links', 'v', 'direction', 'storm_strength'};
ii = 0;
for eventID = events_to_print
    disp(eventID);
    
    rows_event = storms_in_rehovot.eventID == eventID;
    length_of_sequence = sum(rows_event);
    dates = [ storms_in_rehovot.ds(rows_event) , storms_in_rehovot.de(rows_event)];
    
    for seq = 1:length_of_sequence
        ii = ii+1;
        ds = dates(seq,1); de = dates(seq,2);
        T{ii, 'eventID'}        =  eventID;
        T{ii, 'ds'}             = ds;
        T{ii, 'de'}             = de;
        T{ii, 'duration'}       = hours(de-ds);
        T{ii, 'active_links'}    = storms_info{eventID}.active_links{seq};
        T{ii, 'v'}              = storms_info{eventID}.v_wind{seq};
        T{ii, 'direction'}      = storms_info{eventID}.alpha_wind{seq};
        T{ii, 'storm_strength'} = storms_info{eventID}.storm_strength{seq};
    end
end