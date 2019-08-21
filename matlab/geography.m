%% hop's center and noraml angle:
meta_data.x_center = nan(length(meta_data.hop_name),1);
meta_data.y_center = nan(length(meta_data.hop_name), 1);
meta_data.angle = nan(length(meta_data.hop_name) , 1);

map = distinguishable_colors(length(meta_data.hop_name), {'w','k'});
figure;
hold on;
for i = 1:length(meta_data.hop_name)
    hop = char(meta_data.hop_name(i));
    site1 = char(meta_data.site1(i));
    site2 = char(meta_data.site2(i));
    ind1 = strcmp(geo_location.site_name, site1);
    y1 = geo_location.latitude(ind1);
    x1 = geo_location.longitude(ind1);
    ind2 = strcmp(geo_location.site_name, site2);
    y2 = geo_location.latitude(ind2);
    x2 = geo_location.longitude(ind2);
    meta_data.x_center(hop) = mean([x1 x2]);
    meta_data.y_center(hop) = mean([y1 y2]);
%     meta_data.angle(hop)    = atand((y1 - y2)/ (x1 - x2)); %TOD - check this by plotting it!
%     if (meta_data.angle(hop) <0)
%         meta_data.angle(hop) = 180 + meta_data.angle(hop);
%     end
    plot( [x1 , x2] , [y1 , y2]  , 'DisplayName' , hop , 'color', map(i,:));
    plot( meta_data.x_center(hop) , meta_data.y_center(hop), '*', 'DisplayName' , [hop ' center'] , 'color', map(i,:));
%     text(  meta_data.x_center(hop) , meta_data.y_center(hop), num2str(meta_data.angle(hop)) );
    
end
hold off;
plot_google_map
%clear hop site1 site2 ind1 ind2;

%% plot hops on maps:
figure; 
hold on;
for i = 1:length(meta_data.hop_name)
    plot( geo_location.longitude , geo_location.latitude , '*' );
end
hold off;
plot( geo_location.longitude , geo_location.latitude , '*' );
hold on; plot( geo_location.x_ , geo_location.latitude , '*' );

