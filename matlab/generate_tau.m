%% 
hops = pick_hops(0);
hops(strcmp(hops , 'muni_katzirnew')) = [];
hops(strcmp(hops , 'katzirnew_katzirtichon')) = [];
%% generate tau

%given velocity and direction:
v_wind = 7.54;
alpha_wind = 147;
%required time differences are:
[effective_distance , hops_arranged] = calc_effective_distance_and_sort_hops(hops , meta_data , alpha_wind, false);
tau1 = effective_distance./v_wind;
%calculated time differences:
[distance, phi] = calc_phi_and_distance_for_each_pair_of_hops( hops, meta_data);
tau = (distance/v_wind) .* cosd(phi - alpha_wind);

%% represent cost function
% [effective_distance , ~] = calc_effective_distance_and_sort_hops(hops , meta_data , alpha_wind, true);
% tau1 = effective_distance./v_wind;
% noisy_tau = tau1 + randn
v_range     = 0.1:0.1:10;  %velocity [m/s]
alpha_range =   0:1:360; %direction;
[v_grid , alpha_grid] =  meshgrid( v_range , alpha_range);
mini_f = zeros( [size(v_grid) , numel(tau1) ]);
for n = 1:numel(tau)
    mini_f(:,:,n) =  (tau1(n) - (distance(n)./v_grid) .* cosd(phi(n) - alpha_grid)   ).^2;
end
f = sum(mini_f, 3, 'omitnan');
figure; 
mesh(v_grid  , alpha_grid, f);
xlabel('|v|'); 
ylabel('alpha');
figure;
surf(f)
plotfunc3d( sin(x - a)*sin(y - a), x = -PI .. PI, y = -PI .. PI, a = -PI .. PI)

[min_val,idx]=min(f(:));
[row,col]=ind2sub(size(f),idx);
v_range(col)
alpha_range(row)
hold on; stem3(row, col , 10^11)