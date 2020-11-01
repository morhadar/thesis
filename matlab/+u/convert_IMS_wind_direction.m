function wind_direction = convert_IMS_wind_direction (ims_direction)
%input - IMS definition of wind direction is the direction from where the wind is coming from, with respect to y axis (counterclockwise)
%output - this thesis definition of wind is the direction for where wind is blowing to, with respect to x axis (counterclockwise)

wind_direction = wrapTo360(90 - ims_direction + 180);
end