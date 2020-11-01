function EN = geo2utm(lat,lon,varargin)
% function EN = geo2utm(lat,lon,zone)
% Results in km
% simplified formulas taken from Wikipedia
% https://en.wikipedia.org/wiki/Universal_Transverse_Mercator_coordinate_system
a = 6378.137;
f = 1/298.257223563;
%lon0 = zone;%32->9?-sweden, 36->33-israel
%lon0 = zone;%33->15?-sweden?
% lon0 = 33*pi/180;
if nargin>2
    lon0 = varargin{1}*pi/180;
else
    lon0 = 9*pi/180;
end
N0 = 0;
k0 = 0.9996;
E0 = 500;

n = f/(2-f);
A = a/( 1 + n )*(1 + (1/4)*n^2 + (1/64)*n^4 + (1/256)*n^6 + (25/16384)*n^8 + (49/65536)*n^10);
alpha = [n/2-(n^2)*2/3+(n^3)*5/16 (n^2)*13/48-(n^3)*3/5 (n^3)*61/240];
% beta = [n/2-(n^2)*2/3+(n^3)*37/96 (n^2)*1/48+(n^3)*1/15 (n^3)*17/480];
% delta = [n*2-(n^2)*2/3+(n^3)*2 (n^2)*7/3-(n^3)*8/5 (n^3)*56/15];

% lat/lon->(E,N)
t = sinh(atanh(sin(lat)) - (2*sqrt(n)/(1+n))*atanh((2*sqrt(n)/(1+n))*sin(lat)));
xsi = atan(t./cos(lon-lon0));
etta = atanh(sin(lon-lon0)./sqrt(1 + t.^2));
ind = 1:3;
% sigma = 1 + sum(2.*ind.*alpha.*cos(2.*ind.*xsi).*cosh(2.*ind.*etta));
% tao = sum(2.*ind.*alpha.*sin(2.*ind.*xsi).*sinh(2.*ind.*etta));

% E = E0 + k0*A*(etta + sum(alpha.*cos(2.*ind.*xsi).*sinh(2.*ind.*etta)));
E = E0 + k0*A*(etta + (alpha(1).*cos(2.*ind(1).*xsi).*sinh(2.*ind(1).*etta))...
    + (alpha(2).*cos(2.*ind(2).*xsi).*sinh(2.*ind(2).*etta))...
    + (alpha(3).*cos(2.*ind(3).*xsi).*sinh(2.*ind(3).*etta)));
% N = N0 + k0*A*(xsi + sum(alpha.*sin(2.*ind.*xsi).*cosh(2.*ind.*etta)));
N = N0 + k0*A*(xsi + (alpha(1).*sin(2.*ind(1).*xsi).*cosh(2.*ind(1).*etta))...
    + (alpha(2).*sin(2.*ind(2).*xsi).*cosh(2.*ind(2).*etta))...
    + (alpha(3).*sin(2.*ind(3).*xsi).*cosh(2.*ind(3).*etta)));

EN = [E N];