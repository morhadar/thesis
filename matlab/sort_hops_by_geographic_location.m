function [hops_sorted, sort_index] = sort_hops_by_geographic_location(hops_ID, meta_data, alpha_wind)
%inputs:    hops - cell array of size N.
%           alpha is the angle from x axis counterclockwise. %
%outputs:   hops_arranged - sorted hops closest to farest.
%           effective distance - matrix of size NXN where the entry [i,j] is the
%           effective distance between hop_arranged(i) to hop_arrange(j).
%           entry [i,j]>0 means keep walking in the alpha_wind direction
%           from hop_arranged(i) to get to hop_arranged(j). if sort_flag is
%           on then this matrix is also sorted.

hops = u.hop_ID2name(hops_ID, meta_data);
orig_coordinates = [meta_data.x_center(hops), meta_data.y_center(hops)]';
R = [cosd(alpha_wind) , sind(alpha_wind) ; -sind(alpha_wind) cosd(alpha_wind)]; %rotate clockwize in order to get points coordinate in the rotated coortinade system (rather than the coordinates of the rotates points).

new_coordinates = R*orig_coordinates;

[~ , sort_index] = sort(new_coordinates(1,:));
hops_sorted = hops(sort_index);

end