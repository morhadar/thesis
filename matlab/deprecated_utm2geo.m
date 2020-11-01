function latlon = utm2geo(E,N,varargin)
% function latlon = utm2geo(E,N,lon0)
% Results in km
% simplified formulas taken from Wikipedia
% https://en.wikipedia.org/wiki/Universal_Transverse_Mercator_coordinate_system
%lon0 = zone;%32->9?-sweden, 36->33-israel
%lon0 = zone;%33->15?-sweden?

% hami = 1;% hemisphere; for southern -1
if nargin>2
    lon0 = varargin{1}*pi/180;
else
    lon0 = 9*pi/180;
end
% lon0 = 9*pi/180;
a = 6378.137;
f = 1/298.257223563;
% lon0 = zone;%32->9?-sweden, 36->33-israel
N0 = 0;
k0 = 0.9996;
E0 = 500;

n = f/(2-f);
A = a/( 1 + n )*(1 + (1/4)*n^2 + (1/64)*n^4 + (1/256)*n^6 + (25/16384)*n^8 + (49/65536)*n^10);
beta = [n/2-(n^2)*2/3+(n^3)*37/96 (n^2)*1/48+(n^3)*1/15 (n^3)*17/480];
delta = [n*2-(n^2)*2/3+(n^3)*2 (n^2)*7/3-(n^3)*8/5 (n^3)*56/15];

xi = (N-N0)./(k0*A);
eta = (E-E0)./(k0*A);

xi_tag = xi - beta(1).*sin(2.*1.*xi).*cosh(2.*1.*eta)...
    - beta(2).*sin(2.*2.*xi).*cosh(2.*2.*eta)...
    - beta(3).*sin(2.*3.*xi).*cosh(2.*3.*eta);

eta_tag = eta - beta(1).*cos(2.*1.*xi).*sinh(2.*1.*eta)...
    - beta(2).*cos(2.*2.*xi).*sinh(2.*2.*eta)...
    - beta(3).*cos(2.*3.*xi).*sinh(2.*3.*eta);

sigma_tag = 1 - 2*beta(1).*cos(2.*1.*xi).*cosh(2.*1.*eta)...
    - 2*beta(2).*cos(2.*2.*xi).*cosh(2.*2.*eta)...
    - 2*beta(3).*cos(2.*3.*xi).*cosh(2.*3.*eta);

tau_tag = 2*beta(1).*sin(2.*1.*xi).*sinh(2.*1.*eta)...
    + 2*beta(2).*sin(2.*2.*xi).*sinh(2.*2.*eta)...
    + 2*beta(3).*sin(2.*3.*xi).*sinh(2.*3.*eta);

chi = asin(sin(xi_tag)./cosh(eta_tag));

lat = chi + delta(1).*sin(2.*1.*chi)...
    + delta(2).*sin(2.*2.*chi)...
    + delta(3).*sin(2.*3.*chi);

lon = lon0 + atan(sinh(eta_tag)./cos(xi_tag));

%latlon = [lat lon];
latlon.lat = lat;
latlon.lon = lon;