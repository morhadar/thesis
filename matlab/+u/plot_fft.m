function plot_fft ( signal, period_in_seconds)
    L = length(signal);
    f = (1/period_in_seconds)*(0:(L/2))/L;
    A_fft = fft(signal);
    P2 = abs(A_fft/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    hold on; plot(f(2:end),P1(2:end)); %plots without DC!! 
end