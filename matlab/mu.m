function y = mu(x , v , alpha)
    y = (x(:,1)/v) * sind(x(:,2) - alpha);
end