function R = ITU_aRb2(gamma_db,pol,f)
% gamma_db=6;
% pol=0;
% f_vec=19;
% R = zeros(size(f_vec));
% for ii=1:length(f_vec)
%     f = f_vec(ii);
%% data from: ITU_838
itu_mat = [...
1 0.0000259 0.9691 0.0000308 0.8592;...
1.5 0.0000443 1.0185 0.0000574 0.8957;...
2 0.0000847 1.0664 0.0000998 0.9490;...
2.5 0.0001321 1.1209 0.0001464 1.0085;...
3 0.0001390 1.2322 0.0001942 1.0688;...
3.5 0.0001155 1.4189 0.0002346 1.1387;...
4 0.0001071 1.6009 0.0002461 1.2476;...
4.5 0.0001340 1.6948 0.0002347 1.3987;...
5 0.0002162 1.6969 0.0002428 1.5317;...
5.5 0.0003909 1.6499 0.0003115 1.5882;...
6 0.0007056 1.5900 0.0004878 1.5728;...
7 0.001915 1.4810 0.001425 1.4745;...
8 0.004115 1.3905 0.003450 1.3797;...
9 0.007535 1.3155 0.006691 1.2895;...
10 0.01217 1.2571 0.01129 1.2156;...
11 0.01772 1.2140 0.01731 1.1617;...
12 0.02386 1.1825 0.02455 1.1216;...
13 0.03041 1.1586 0.03266 1.0901;...
14 0.03738 1.1396 0.04126 1.0646;...
15 0.04481 1.1233 0.05008 1.0440;...
16 0.05282 1.1086 0.05899 1.0273;...
17 0.06146 1.0949 0.06797 1.0137;...
18 0.07078 1.0818 0.07708 1.0025;...
19 0.08084 1.0691 0.08642 0.9930;...
20 0.09164 1.0568 0.09611 0.9847;...
21 0.1032 1.0447 0.1063 0.9771;...
22 0.1155 1.0329 0.1170 0.9700;...
23 0.1286 1.0214 0.1284 0.9630;...
24 0.1425 1.0101 0.1404 0.9561;...
25 0.1571 0.9991 0.1533 0.9491;...
26 0.1724 0.9884 0.1669 0.9421;...
27 0.1884 0.9780 0.1813 0.9349;...
28 0.2051 0.9679 0.1964 0.9277;...
29 0.2224 0.9580 0.2124 0.9203;...
30 0.2403 0.9485 0.2291 0.9129;...
31 0.2588 0.9392 0.2465 0.9055;...
32 0.2778 0.9302 0.2646 0.8981;...
33 0.2972 0.9214 0.2833 0.8907;...
34 0.3171 0.9129 0.3026 0.8834;...
35 0.3374 0.9047 0.3224 0.8761;...
36 0.3580 0.8967 0.3427 0.8690;...
37 0.3789 0.8890 0.3633 0.8621;...
38 0.4001 0.8816 0.3844 0.8552;...
39 0.4215 0.8743 0.4058 0.8486;...
40 0.4431 0.8673 0.4274 0.8421;...
41 0.4647 0.8605 0.4492 0.8357;...
42 0.4865 0.8539 0.4712 0.8296;...
43 0.5084 0.8476 0.4932 0.8236;...
44 0.5302 0.8414 0.5153 0.8179;...
45 0.5521 0.8355 0.5375 0.8123;...
46 0.5738 0.8297 0.5596 0.8069;...
47 0.5956 0.8241 0.5817 0.8017;...
48 0.6172 0.8187 0.6037 0.7967;...
49 0.6386 0.8134 0.6255 0.7918;...
50 0.6600 0.8084 0.6472 0.7871;...
51 0.6811 0.8034 0.6687 0.7826;...
52 0.7020 0.7987 0.6901 0.7783;...
53 0.7228 0.7941 0.7112 0.7741;...
54 0.7433 0.7896 0.7321 0.7700;...
55 0.7635 0.7853 0.7527 0.7661;...
56 0.7835 0.7811 0.7730 0.7623;...
57 0.8032 0.7771 0.7931 0.7587;...
58 0.8226 0.7731 0.8129 0.7552;...
59 0.8418 0.7693 0.8324 0.7518;...
60 0.8606 0.7656 0.8515 0.7486;...
61 0.8791 0.7621 0.8704 0.7454;...
62 0.8974 0.7586 0.8889 0.7424;...
63 0.9153 0.7552 0.9071 0.7395;...
64 0.9328 0.7520 0.9250 0.7366;...
65 0.9501 0.7488 0.9425 0.7339;...
66 0.9670 0.7458 0.9598 0.7313;...
67 0.9836 0.7428 0.9767 0.7287;...
68 0.9999 0.7400 0.9932 0.7262;...
69 1.0159 0.7372 1.0094 0.7238;...
70 1.0315 0.7345 1.0253 0.7215;...
71 1.0468 0.7318 1.0409 0.7193;...
72 1.0618 0.7293 1.0561 0.7171;...
73 1.0764 0.7268 1.0711 0.7150;...
74 1.0908 0.7244 1.0857 0.7130;...
75 1.1048 0.7221 1.1000 0.7110;...
76 1.1185 0.7199 1.1139 0.7091;...
77 1.1320 0.7177 1.1276 0.7073;...
78 1.1451 0.7156 1.1410 0.7055;...
79 1.1579 0.7135 1.1541 0.7038;...
80 1.1704 0.7115 1.1668 0.7021;...
81 1.1827 0.7096 1.1793 0.7004;...
82 1.1946 0.7077 1.1915 0.6988;...
83 1.2063 0.7058 1.2034 0.6973;...
84 1.2177 0.7040 1.2151 0.6958;...
85 1.2289 0.7023 1.2265 0.6943;...
86 1.2398 0.7006 1.2376 0.6929;...
87 1.2504 0.6990 1.2484 0.6915;...
88 1.2607 0.6974 1.2590 0.6902;...
89 1.2708 0.6959 1.2694 0.6889;...
90 1.2807 0.6944 1.2795 0.6876;...
91 1.2903 0.6929 1.2893 0.6864;...
92 1.2997 0.6915 1.2989 0.6852;...
93 1.3089 0.6901 1.3083 0.6840;...
94 1.3179 0.6888 1.3175 0.6828;...
95 1.3266 0.6875 1.3265 0.6817;...
96 1.3351 0.6862 1.3352 0.6806;...
97 1.3434 0.6850 1.3437 0.6796;...
98 1.3515 0.6838 1.3520 0.6785;...
99 1.3594 0.6826 1.3601 0.6775;...
100 1.3671 0.6815 1.3680 0.6765;...
120 1.4866 0.6640 1.4911 0.6609;...
150 1.5823 0.6494 1.5896 0.6466;...
200 1.6378 0.6382 1.6443 0.6343;...
300 1.6286 0.6296 1.6286 0.6262;...
400 1.5860 0.6262 1.5820 0.6256;...
500 1.5418 0.6253 1.5366 0.6272;...
600 1.5013 0.6262 1.4967 0.6293;...
700 1.4654 0.6284 1.4622 0.6315;...
800 1.4335 0.6315 1.4321 0.6334;...
900 1.4050 0.6353 1.4056 0.6351;...
1000 1.3795 0.6396 1.3822 0.6365];

%% calaculation:
% f(f>6) = round(f(f>6));
% f_mat = repmat(f(:),1,size(itu_mat,1));
% f_itu = repmat(itu_mat(:,1)',length(f(:)),1);
% % ind_mat = repmat(1:length(
% diff_f = abs(f_mat-f_itu);
% [~,J,~] = find(diff_f==repmat(min(diff_f,[],2),1,size(f_mat,2)));
% J
% itu_mat(J,1)
% if pol==0%hh
%     R = (gamma_db(:)./itu_mat(J,2)).^(1./itu_mat(J,3));
% else%vv
%     R = (gamma_db(:)./itu_mat(J,4)).^(1./itu_mat(J,5));
% end
if pol==0%hh
    a = interp1(itu_mat(:,1),itu_mat(:,2),f(:),'linear','extrap');
    b = interp1(itu_mat(:,1),itu_mat(:,3),f(:),'linear','extrap');
    R = (gamma_db(:)./a).^(1./b);
else%vv
    a = interp1(itu_mat(:,1),itu_mat(:,4),f(:),'linear','extrap');
    b = interp1(itu_mat(:,1),itu_mat(:,5),f(:),'linear','extrap');
    R = (gamma_db(:)./a).^(1./b);
end