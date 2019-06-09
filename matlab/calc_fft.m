function [P1 , f] = calc_fft ( x, period_in_seconds)
    L = length(x);
    f = (1/period_in_seconds)*(0:(L/2))/L; %why divide in 2 and L??
    x_fft = fft(x); %TODO - why it sometime retuen NAN????
    P2 = abs(x_fft/L); %why devide in L? 
    P1 = P2(1:L/2+1);
    P1 = 2*P1;
end