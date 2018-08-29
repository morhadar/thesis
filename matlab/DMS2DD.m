function meta_data = DMS2DD(meta_data)
%convert DMS geographic coordinate to DD geographic coordinate

%transmitter: 
NE = str2num(cell2mat(regexprep(regexprep(meta_data.transmitter_location,'[''"NE]',' '),'°',' ')));
NE = NE.*repmat([1, 1/60, 1/3600], size(NE,1), 2);
links_geo = [sum(NE(:,1:3),2) sum(NE(:,4:6),2)]; %TODO use str2angle function. mapping toolbox.
meta_data.transmitter_latitude = links_geo(:,1);
meta_data.transmitter_longitude = links_geo(:,2);

%receiver
NE = str2num(cell2mat(regexprep(regexprep(meta_data.receiver_location,'[''"NE]',' '),'°',' ')));
NE = NE.*repmat([1, 1/60, 1/3600], size(NE,1), 2);
links_geo = [sum(NE(:,1:3),2) sum(NE(:,4:6),2)]; %TODO use str2angle function. mapping toolbox.
meta_data.receiver_latitude = links_geo(:,1);
meta_data.receiver_longitude = links_geo(:,2);

%length
for i=1:size(meta_data,1)  %TODO - do it without a loop
    tx = txsite('Name','dont_care','Latitude', meta_data.transmitter_latitude(i),'Longitude',meta_data.transmitter_longitude(i));
    rx = rxsite('Name','dont_care2','Latitude', meta_data.receiver_latitude(i),'Longitude',meta_data.receiver_longitude(i));
    meta_data.length_KM(i) = distance(tx,rx, 'geodesic')/1000;
end

meta_data = sortrows(meta_data, 'length_KM', 'descend');

end