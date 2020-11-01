function meta_data = expand_metadata_with_UTM_coordinate(meta_data)
    %expand meta_data to columns for UTM coordinates:
    
    utmstruct = defaultm('utm');
    mean_lat = mean([meta_data.site1_latitude; meta_data.site2_latitude], 'omitnan');
    mean_lon = mean([meta_data.site1_longitude ; meta_data.site2_longitude], 'omitnan');
    utmstruct.zone = utmzone(mean_lat, mean_lon); %TODO - make sure all lat/lon belongs to the same UTM zone
    utmstruct.geoid = wgs84Ellipsoid;
    utmstruct = defaultm(utmstruct);
    
    meta_data.x_site1  = nan(length(meta_data.hop_name),1);
    meta_data.x_site2  = nan(length(meta_data.hop_name),1);
    meta_data.y_site1  = nan(length(meta_data.hop_name),1);
    meta_data.y_site2  = nan(length(meta_data.hop_name),1);
    meta_data.x_center = nan(length(meta_data.hop_name),1);
    meta_data.y_center = nan(length(meta_data.hop_name), 1);

    for i = 1:length(meta_data.hop_name)
        hop = char(meta_data.hop_name(i));
        lon1 = meta_data.site1_longitude(hop);
        lon2 = meta_data.site2_longitude(hop);
        lat1 = meta_data.site1_latitude(hop) ;
        lat2 =  meta_data.site2_latitude(hop);

        [meta_data.x_site1(hop),meta_data.y_site1(hop)] = mfwdtran(utmstruct,lat1,lon1);
        [meta_data.x_site2(hop),meta_data.y_site2(hop)] = mfwdtran(utmstruct,lat2,lon2);

        meta_data.x_center(hop) = mean([meta_data.x_site1(hop) meta_data.x_site2(hop)]);
        meta_data.y_center(hop) = mean([meta_data.y_site1(hop) meta_data.y_site2(hop)]); 
    end
end