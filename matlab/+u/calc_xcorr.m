function tau = calc_xcorr(rssi)
    [R, lag] = xcorr(rssi);
    [~, I] = max(abs(R));
    delay_estimated = lag(I);
    tau = delay_estimated * 30; %convert sample delay to real time delay
end