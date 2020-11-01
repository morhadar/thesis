function tau = calc_xcorr(rssi)
%%% returns the delay in seconds between each pair of singals in the
%%% colonms of rssi. 
% inputs:
%   rssi(N_samples x N) - N number of _links.each colomn is signal in time.
% outputs:
%   tau(1 x N*N). arranged as first N entries are the the cross correlation
%   fetween first signal with all others (include itselfs). if xcorr(s1,s2)
%   is negative than s1 happend before s2. meaning that s1(t+tau)=s2.
    [R, lag] = xcorr(rssi);
    [~, I] = max(abs(R));
    delay_estimated = lag(I);
    tau = delay_estimated * 30; %convert sample delay to real time delay
end