function add_wind_to_plot ( x_min , x_max , y_min , y_max, alpha_wind , v_wind)
    xlim([x_min x_max]);
    ylim([y_min y_max]);
    if(alpha_wind >= 0 && alpha_wind < 90) %first quarter
        x_start = x_min;
        y_start = y_min;
    elseif(alpha_wind >= 90 && alpha_wind < 180) %2
        x_start = x_max;
        y_start = y_min;
    elseif (alpha_wind >= 180 && alpha_wind < 270)%
        x_start = x_max;
        y_start = y_max;
    else
        x_start = x_min;
        y_start = y_max;
    end
    %TODO - adjust the scale according to the plot dimensions.
    %TODO - remmber that the plot is a rectangle and not a square.
    scale = 1000;
    delta_x = v_wind * cosd(alpha_wind);
    delta_y = v_wind * sind(alpha_wind);
    vx = x_start +delta_x ;
    vy = y_start + delta_y;
    hold on;  plot( [x_start , vx] ,[y_start , vy], 'color' , 'k' )
    hold on;  text(vx , vy , [num2str(v_wind) 'm/s']);
end