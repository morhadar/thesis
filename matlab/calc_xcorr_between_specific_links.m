function [rssi, hops_ID, tau, distance, phi] = calc_xcorr_between_specific_links(rssi, hops_ID, meta_data, distanceG, phiG, mode)
    switch(mode)
        case 'all_links'
            tau = calc_xcorr(rssi)';
            distance = distanceG(hops_ID , hops_ID);
            distance = distance(:);
            phi = phiG(hops_ID , hops_ID)';
            phi = phi(:);

        case 'independent_links'
            [hops_ID, ia, ~] = unique(hops_ID);
            rssi = rssi(:,ia);
            hops = u.hop_ID2name(hops_ID);
            M = length(hops);
            [~ , pivot] = max(meta_data.length(hops)); %pick longest hop as the pivot
            tau = calc_xcorr(rssi)';
            tau = reshape(tau, [M M]);
            %TODO - think is pivot should be in the row or colonm!!
%             tau = tau(pivot , :);
%             distance = distanceG(links_ID, pivot);
%             phi = phiG(hops_ID , pivot)';
            tau(pivot) = [];
            distance(pivot) = [];
            phi(pivot) = [];

        case 'all_hops'
            [hops_ID, ia, ~] = unique(hops_ID);
            rssi = rssi(:,ia);
            tau = calc_xcorr(rssi)';
            distance = distanceG(hops_ID , hops_ID);
            distance = distance(:);
            phi = phiG(hops_ID , hops_ID)';
            phi = phi(:);
    end
end

function tau = calc_xcorr(rssi)
    [R,lag] = xcorr(rssi);
    [~,I] = max(abs(R));
    delay_estimated = lag(I);
    tau = delay_estimated * 30; %convert sample delay to real time delay
end