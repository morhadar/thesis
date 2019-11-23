function wind_direction = convert_IMS_wind_direction (ims_direction)
%input - IMS wind direction is from where the wind is ooming from. with
%respect to y axis. 
%output - my direction is to where wind is blowing to. with respect to x
%axis.

% wind_direction = 90 - ims_direction;
wind_direction = wrapTo360(90 - ims_direction +180);
end