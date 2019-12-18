function [rssi, hops_ID, tau, distance, phi] = calc_xcorr_between_specific_links(rssi, hops_ID, meta_data, distanceG, phiG, mode)
    switch(mode)
        case 'all_links'
            tau = calc_xcorr(rssi)';
            distance = distanceG(hops_ID , hops_ID);
            distance = distance(:);
            phi = phiG(hops_ID , hops_ID)';
            phi = phi(:);
         case 'all_links_avg'
            tau = calc_xcorr(rssi)';
            L = length(hops_ID);
%             tau = reshape(tau, [], L);
            tau = reshape(tau, [], L)';

            unique_hops = unique(hops_ID);
            M = length(unique_hops);
%             tau_new = nan(L,M);
            tau_new = nan(M,L);
            for uu = 1:length(unique_hops)
                f = find(hops_ID == unique_hops(uu));
%                 tau_new(:,uu) = mean( tau(:,f), 2 );
                tau_new(uu,:) = mean( tau(f,:) );
            end
%             tau = tau_new(:);
            tau = tau_new';
            tau = tau(:);
            distance = distanceG(unique_hops , hops_ID);
%             distance = distanceG(hops_ID, unique_hops);
            distance = distance(:);
            phi = phiG(unique_hops , hops_ID)';
%             phi = phiG(hops_ID, unique_hops)';
            phi = phi(:);
            
            hops_ID = unique_hops;
        case 'independent_links'
            [hops_ID, ia, ~] = unique(hops_ID);
            rssi = rssi(:,ia);
            hops = u.hop_ID2name(hops_ID, meta_data);
            M = length(hops);
            [~ , pivot] = max(meta_data.length(hops)); %pick longest hop as the pivot
            tau = calc_xcorr(rssi)';
            tau = reshape(tau, [M M]); %if jau[i,j] <0 then link_i is later in time. (tau(i,j) => 
            
            %Take M sample of pivot with all other hops.
            tau = tau(pivot , :)';
            distance = distanceG(pivot, hops_ID)';
            phi = phiG(pivot , hops_ID)';
            
            %%% remove the pivot with himself sample.
            tau(pivot) = [];
            distance(pivot) = [];
            phi(pivot) = [];
        
        case 'independent_linksM'
            [hops_ID, ia, ~] = unique(hops_ID);
            rssi = rssi(:,ia);
            hops = u.hop_ID2name(hops_ID, meta_data);
            M = length(hops);
            [~ , pivot] = max(meta_data.length(hops)); %pick longest hop as the pivot
            tau = calc_xcorr(rssi)';
            tau = reshape(tau, [M M]); %if jau[i,j] <0 then link_i is later in time. (tau(i,j) => 
            
            %take last
            hops_no_pivot = hops_ID;
            hops_no_pivot(pivot)=[];
            other_pivots = datasample(hops_no_pivot,2);
            ind1 = find(hops_ID ==other_pivots(1));
            ind2 = find(hops_ID ==other_pivots(2));
            tau_last = tau(ind1,ind2);
            distance_last = distanceG(ind1,ind2);
            phi_last = phiG(ind1,ind2);
            
            %Take M sample of pivot with all other hops.
            tau = tau(pivot , :)';
            distance = distanceG(pivot, hops_ID)';
            phi = phiG(pivot , hops_ID)';
            
            %%% remove the pivot with himself sample.
            tau(pivot) = [];
            distance(pivot) = [];
            phi(pivot) = [];

            %add the M sample
            tau = [tau; tau_last];
            distance =[distance; distance_last];
            phi = [phi; phi_last];
        
        case 'all_hops'
            [hops_ID, ia, ~] = unique(hops_ID);
            rssi = rssi(:,ia);
            tau = calc_xcorr(rssi)';
            distance = distanceG(hops_ID , hops_ID);
            distance = distance(:);
            phi = phiG(hops_ID , hops_ID)';
            phi = phi(:);
        case 'super_mode'
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% avg
            tau = calc_xcorr(rssi)';
            L = length(hops_ID);
            tau = reshape(tau, [], L)';

            unique_hops = unique(hops_ID);
            M = length(unique_hops);
            tau_new = nan(M,L);
            for uu = 1:length(unique_hops)
                f = find(hops_ID == unique_hops(uu));
                tau_new(uu,:) = mean( tau(f,:) );
            end
            tau = tau_new';
            tau = tau(:);
%             distance = distanceG(unique_hops , hops_ID);
%             distance = distance(:);
%             phi = phiG(unique_hops , hops_ID)';
%             phi = phi(:);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5take M samples
            hops = u.hop_ID2name(unique_hops, meta_data);
            M = length(hops);
            [~ , pivot] = max(meta_data.length(hops)); %pick longest hop as the pivot
            tau = calc_xcorr(rssi)';
            tau = reshape(tau, [L,M])'; %if jau[i,j] <0 then link_i is later in time. (tau(i,j) => 
            
            %take last
%             hops_no_pivot = unique_hops;
%             hops_no_pivot(pivot)=[];
%             other_pivots = datasample(hops_no_pivot,2);
%             ind1 = find(hops_ID ==other_pivots(1));
%             ind2 = find(hops_ID ==other_pivots(2));
%             tau_last = tau(ind1,ind2);
%             distance_last = distanceG(ind1,ind2);
%             phi_last = phiG(ind1,ind2);
            
            %Take M sample of pivot with all other hops.
            tau = tau(pivot , :)';
%             distance = reshape(distance, [M L])';
            distance = distanceG(pivot, unique_hops)';
%             phi = reshape(phi, [M L])';
            phi = phiG(pivot , unique_hops)';
            
            %%% remove the pivot with himself sample.
            tau(pivot) = [];
            distance(pivot) = [];
            phi(pivot) = [];

            %add the M sample
%             tau = [tau; tau_last];
%             distance =[distance; distance_last];
%             phi = [phi; phi_last];

            
    end
end

function tau = calc_xcorr(rssi)
    [R,lag] = xcorr(rssi);
    [~,I] = max(abs(R));
    delay_estimated = lag(I);
    tau = delay_estimated * 30; %convert sample delay to real time delay
end