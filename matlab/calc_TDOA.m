function [unique_hops_ID, tau, distance, phi, probes] = calc_TDOA(rssi_orig, hops_ID_orig, distanceG, phiG, mode)
    N = length(hops_ID_orig);
    tau = - u.calc_xcorr(rssi_orig); %the minus is because I want positive delay if s1 is before s2, where xcorr(s1,s2) returns negative.

    tau = reshape(tau, [N, N])';
    distance = distanceG(hops_ID_orig , hops_ID_orig);
    phi = phiG(hops_ID_orig , hops_ID_orig);

    switch(mode)
        case 'one_arbitrary_link_ICASPP2020papaer'
            % WIP - to reproduce papaer result take only one link out of the
            % two. for reference see 'calc_xcorr_between_hops_paper' function
        case 'all_samples'
            tau = tau(:);
            distance = distance(:);
            phi = phi(:);
            unique_hops_ID = unique(hops_ID_orig);
            probes = [];
        case 'average_4' 
            %take only bottom half of the tau matrix. excluding the diagonal
            mask_exclude = triu(true(size(tau)));
            tau(mask_exclude) = nan;
            samples = tau(:); %samples = [tau(2,1), tau(2,1), tau(3,1), tau(4,1) ...tau(N,1), tau(3,2), tau(4,2)...]
            [link1, link2] = ndgrid(hops_ID_orig, hops_ID_orig);
            z = [link1(:), link2(:)];
            exclude_nan = isnan(samples);
            samples(exclude_nan) = [];
            z(exclude_nan, :) = [];
            samples_mat = [z samples];

            %throw away samples of links from the same hop (for example hop1_up and hop1_down)
            similar_links = samples_mat(:,1) == samples_mat(:,2);
            samples_mat(similar_links, :) = [];

            % TODO - consider throwing away hops with big internal error (NOT TESTED)
            % exclude_links = samples_mat(similar_links,3) >= 60;

            % average between samples belonging to the same hops (maximum 4 possible samples to average between them)
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
                avg_samples_mat(i, 7) = distanceG(c(i,1),c(i,2));
                avg_samples_mat(i, 8) = phiG(c(i,1),c(i,2));
            end
            avg_s = mean(avg_samples_mat(:, 3:6), 2, 'omitnan');
            std_s = sqrt(var(avg_samples_mat(:, 3:6), 1, 2, 'omitnan'));
            inv_snr = std_s/avg_s;

            % filter out outliers:
            exclude_big_variance = std_s > 100;
            avg_s(exclude_big_variance) = [];
            std_s(exclude_big_variance) = [];
            inv_snr(exclude_big_variance) = [];
            avg_samples_mat(exclude_big_variance,:) = [];

            tau = avg_s;
            distance = avg_samples_mat(:,7);
            phi = avg_samples_mat(:,8);
            unique_hops_ID = unique([avg_samples_mat(:,1),avg_samples_mat(:,2)]);

            probes.avg_samples_mat = avg_samples_mat;
            probes.std_s = std_s;
            probes.avg_s = avg_s;
            probes.inv_snr = inv_snr;
    end
end