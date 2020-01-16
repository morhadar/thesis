function [hops_ID, tau, distance, phi] = calc_xcorr_between_specific_links(rssi_orig, hops_ID_orig, meta_data, distanceG, phiG, mode)
N = length(hops_ID_orig);
tau = u.calc_xcorr(rssi_orig)';

tau = reshape(tau, [N, N]);
distance = distanceG(hops_ID_orig , hops_ID_orig);
phi = phiG(hops_ID_orig , hops_ID_orig)';

switch(mode)
    case 'all_samples_article' %takes all matrix values
        tau = tau(:);
        distance = distance(:);
        phi = phi(:);
    case 'all_samples' %take only upper half of the matrix with no '0' or '~0' cells.
    case 'average_4' 
        mask_exclude = triu(true(size(tau)));
        tau(mask_exclude) = nan;
        samples = tau(:);
        [link2, link1] = ndgrid(hops_ID_orig, hops_ID_orig);
        z = [link1(:), link2(:)];
        exclude_nan = isnan(samples);
        samples(exclude_nan) = []; %first column is the column of original tau matrix.
        z(exclude_nan, :) = [];
        samples_mat = [z samples];
        
        %throw away samples of links from the same hop:
        similar_links = samples_mat(:,1) == samples_mat(:,2);
        % TODO - consider throwing away hops with big internal error.
%         exclude_links = samples_mat(similar_links,3) >= 60;
        samples_mat(similar_links, :) = [];
        
        % merge 
        [c, ~, ic] = unique(samples_mat(:, 1:2), 'rows');
        N_samples = size(c,1);
        avg_samples_mat = nan(N_samples, 8); %link1|link2|sample1|sample2|sample3|sample4|distance|phi
        avg_samples_mat(:,1:2) = c;
        for i = 1:N_samples
            ind = samples_mat(:, 1:2) == c(i,:);
            ind = ind(:,1)==1 & ind(:,2)==1;
            s = samples_mat(ind, 3);
            s(end+1:4) = nan; %fill with nan missing samples
            avg_samples_mat(i, 3:6) = s';
            avg_samples_mat(i, 7) = distanceG(c(i,1),c(i,2)); %TODO - maybe the opposite
            avg_samples_mat(i, 8) = phiG(c(i,1),c(i,2));
            
%             avg_samples_mat(i, 7) = distanceG(c(i,2),c(i,1)); %TODO - maybe the opposite
%             avg_samples_mat(i, 8) = phiG(c(i,2),c(i,1));
        end
        avg_s = mean(avg_samples_mat(:, 3:6), 2, 'omitnan');
        std_s = sqrt(var(avg_samples_mat(:, 3:6), 1, 2, 'omitnan'));
        exclude_big_variance = std_s > 100;
        avg_s(exclude_big_variance) = [];
        avg_samples_mat(exclude_big_variance,:) = [];
        
        tau = avg_s;
        distance = avg_samples_mat(:,7);
        phi = avg_samples_mat(:,8);
        hops_ID = unique(avg_samples_mat(:,1));
end

end