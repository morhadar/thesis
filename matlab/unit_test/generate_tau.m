%% 
hops = pick_hops(0);
hops(strcmp(hops , 'muni_katzirnew')) = [];
hops(strcmp(hops , 'katzirnew_katzirtichon')) = [];
%% generate tau

%given velocity and direction:
v_wind = 7.54;
alpha_wind = 147;
%required time differences are:
[effective_distance, hops_arranged] = calc_effective_distance_and_sort_hops(hops , meta_data , alpha_wind, false);
tau1 = effective_distance./v_wind;
%calculated time differences:
[distance, phi] = u.calc_phi_and_distance_for_each_pair_of_hops(hops, meta_data);
tau = (distance/v_wind) .* cosd(phi - alpha_wind);

function [effective_distance, hops_arranged , sort_index] = calc_effective_distance_and_sort_hops(hops, meta_data, alpha_wind, sort_flag)
    %inputs:    hops - cell array of size N.
    %           alpha is the angle from x axis counterclockwise. %
    %outputs:   hops_arranged - sorted hops closest to farest.
    %           effective distance - matrix of size NXN where the entry [i,j] is the
    %           effective distance between hop_arranged(i) to hop_arrange(j).
    %           entry [i,j]>0 means keep walking in the alpha_wind direction
    %           from hop_arranged(i) to get to hop_arranged(j). if sort_flag is
    %           on then this matrix is also sorted.

    %u.show_hops_on_map(hops, meta_data, true);
    orig_coordinates = [meta_data.x_center(hops), meta_data.y_center(hops)]';
    R = [cosd(alpha_wind), sind(alpha_wind) ; -sind(alpha_wind) cosd(alpha_wind)]; %rotate clockwize in order to get points coordinate in the rotated coortinade system (rather than the coordinates of the rotates points).

    new_coordinates = R*orig_coordinates;
    if(sort_flag)
        [B, sort_index] = sort(new_coordinates(1,:));
        hops_arranged = hops(sort_index);
    else
        B = new_coordinates(1,:);
        hops_arranged = nan(length(hops));
    end
    [t1, t2] =  meshgrid(B);
    effective_distance = t2 - t1;
end