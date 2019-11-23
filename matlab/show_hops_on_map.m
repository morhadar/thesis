function show_hops_on_map (hops, meta_data, map_color_by_hop , name_tag_by_order_of_arrival , name_tag_by_hopID )
%open figure from outside the function
%figure('visible','off');
hold on;
for i = 1:length(hops)
    hop = char(hops(i));
    hop_ID = meta_data.hop_ID(hop);
    x1 = meta_data.x_site1(hop);
    x2 = meta_data.x_site2(hop);
    y1 = meta_data.y_site1(hop) ;
    y2 =  meta_data.y_site2(hop);
    if( x1 ==0 || x2==0 || y1==0 || y2 ==0); continue; end %TODO - should not be here once I have the location of all sites.
    plot( [x1 ,x2 ] , [y1, y2], 'color' ,map_color_by_hop(hop_ID , :), 'DisplayName', [num2str(hop_ID) '-' hop], 'HandleVisibility','off');
    plot( meta_data.x_center(hop) , meta_data.y_center(hop) , '*', 'color', map_color_by_hop(hop_ID , :), 'DisplayName', [num2str(hop_ID) '-' hop]);
    if(name_tag_by_order_of_arrival)
        text( meta_data.x_center(hop) , meta_data.y_center(hop) , num2str(i), 'color' ,map_color_by_hop(hop_ID , :));
    end
    if(name_tag_by_hopID)
        text( meta_data.x_center(hop) , meta_data.y_center(hop) , num2str(hop_ID), 'color' ,map_color_by_hop(hop_ID , :));
    end
end
hold off;
end