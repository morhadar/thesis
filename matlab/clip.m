function y = clip( x , lower_th, upper_th)
y = max( min(x,upper_th) , lower_th);
end