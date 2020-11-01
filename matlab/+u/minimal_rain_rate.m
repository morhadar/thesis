function minimal_rain_rate = minimal_rain_rate(link_length, alpha, beta, quantization_error)
    r = 0:0.01:100;
    minimal_rain_rate = nan(length(link_length) ,1);
    for i = 1:length(link_length) %TODO - write this matrices way
        if isnan(link_length(i)); continue; end
        A = alpha .* (r .^ beta).* link_length(i);
        ind = find(A > quantization_error, 1);
        if isempty(ind)
            minimal_rain_rate(i) = inf;
        else
            minimal_rain_rate(i) = r(ind);
        end
    end
end