function [distance, phi] = calc_phi_and_distance_for_each_pair_of_hops(hops, meta_data)
% inputs:
%   hops(cell array) - each entry is hop's name. 1xN 
% outputs:
%   distance(NxN) - distance(i,j) - is the distance in meters between middle of hop i to the middle of hop j. symetric matrix
%   phi(NxN) - phi(i,j) - is the angle in degrees between the line going from hop i to hop j.
N = length(hops);
distance = zeros(N);
phi = zeros(N);
% u.show_hops_on_map(hops, meta_data , true);
% hold on;
for i = 1:N
    for j = i+1:N
        linki = char(hops(i));
        linkj = char(hops(j));
        xi = meta_data.x_center(linki);
        yi = meta_data.y_center(linki);
        xj = meta_data.x_center(linkj);
        yj = meta_data.y_center(linkj);
        distance(i,j) =  sqrt( (xi - xj).^2 + (yi-yj).^2 );
        distance(j,i) = distance(i,j);
        phi(i,j) =  atan2d( (yj - yi) , (xj - xi));
        phi(j,i) =  atan2d( (yi - yj) , (xi - xj));
        %phi(j,i) = phi(i,j) +180;
        
%         plot( [xi xj] , [yi yj]  , '--k', 'DisplayName' , [linki ' -> ' linkj ]);
        %text( mean([xc1 xc2]) , mean([yc1 yc2]), num2str(phi(r,c)) );
    end
end
% hold off;
end