% log normal distributaion:

pd = makedist('Lognormal','mu',log(20000),'sigma',1);

sigma = 0.5;
mu = 0;
r = 0:0.1:1000000;
pdf_r = @(r) ( 1 ./ ( r .* sigma .* sqrt(2*pi)) ) .* ...
              exp( - (( log2(r) -mu ).^2) ./ (2*sigma^2) );
figure; plot(r,pdf_r(r));
integral(pdf_r , 0, Inf) %TODO - why not 1?????

alpha = 1.09;
beta = 0.7;
a = 0.0001:0.1:10;
rr = (a./alpha).^(1/beta);
pdf_a_rr    = ( 1 ./ abs( alpha *(beta-1) .* rr ) ) .*  ...
              ( 1 ./ ( rr .* sigma .* sqrt(2*pi)) ) .* ...
              exp( - ( log2(rr) -mu ).^2 ./ (2*sigma^2) );

pdf_a       = ( 1 ./ abs( alpha *(beta-1) .* (a./alpha).^(1/beta) ) ) .*  ...
              ( 1 ./ ( (a./alpha).^(1/beta) .* sigma .* sqrt(2*pi)) ) .* ...
              exp( - ( log2((a./alpha).^(1/beta)) -mu ).^2 ./ (2*sigma^2) );
CF_u = fft(pdf_a , 
fun = @(rr) (( 1 ./ abs( alpha *(beta-1) .* rr ) ) .* ...
             ( 1 ./ ( rr .* sigma .* sqrt(2*pi)) ) .* ...
             exp( - ( log2(rr) -mu ).^2 ./ (2*sigma^2) ) );
q = integral(fun,0,Inf); %TODO somthing is wrong because I get that the integral is equal to 2.25 instead of smaller than 1 (smaller than 1 and not 1 since a is finite)
figure; plot(a , pdf_a_rr);