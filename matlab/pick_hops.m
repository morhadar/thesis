function hops = pick_hops(your_pick)
%% choose hops
switch (your_pick)
    %TODO - automate arranging linking in geographical order. 
    case 0 %all links (except the one with the tree).
        tmp = sortrows(meta_data, 'length'); hops = tmp.hop_name;      hops( strcmp(hops , 'junc11_junc10')) = []; clear tmp
    case 1 %South to north.     
        hops = {'junc16_junc17' , 'moria_junc16' , 'moria_junc12' , 'moria_metamiteiman' , 'muni_moria' , 'muni_teller' , 'police_beitlarom' , 'junc7_police' , 'junc5_junc6' , 'junc4_junc5' , 'junc34_junc4' , 'junc3_junc34' , 'leonardo_junc3', 'muni_leonardo' , 'leonardo_junc2', 'leonardo_junc1' , 'junc1_agafhatnua'};
    case 2 %west to east   
        hops = {'hitechhi_herzog' , 'hitechhi_logistics' , 'muni_hitechhi' , 'muni_leonardo' , 'muni_revaha' , 'muni_schoolbenzvi' , 'muni_junc11' , 'muni_beithaam' , 'junc11_junc10' , 'junc11_juncbneimoshe' , 'beithaam_smelansky' , 'beithaam_sarid' , 'beithaam_deshalit' , 'deshalit_tachkimoni'};
    
    case 3;     hops = [17 7 22 8 10 5 15 16 3 19 11 9];           %periodicity  - length ascending
    case 3.1;   hops = [1 13 23 12 18 24 2 20 4 6 21 ];            %periodicity (weak) - length ascending
    case 3.2;   hops = [7 5 15 16];            %periodicity (very visible!!!) - length ascending
    case 3.3;   hops = [5 7];            %periodicity (very visible!!!) - length ascending
    case 4;     hops = [1, 2, 3, 4,5 ,6 ,7 ,12 ,16  ];            %links cant see first peak of februar rain.   
end
end