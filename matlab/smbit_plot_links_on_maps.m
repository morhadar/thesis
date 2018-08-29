function [lat lon] = smbit_plot_links_on_maps(meta_data)
%convert DMS geographic coordinate to DD geographic coordinate
NE = str2num(cell2mat(regexprep(coor.location,'[''"NE]',' ')));
NE = NE.*repmat([1, 1/60, 1/3600], size(NE,1), 2);
links_geo = [sum(NE(:,1:3),2) sum(NE(:,4:6),2)];
lat = links_geo(:,1);
lon = links_geo(:,2);


end