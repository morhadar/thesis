function hops = pick_hops(meta_data , your_pick)
% returns cell array of picked hops' names

switch (your_pick)
    case 0
        disp('all links arranged by increasing length. exclude "junc11_junc10" that was disturbed by a tree');
        meta_data = sortrows(meta_data, 'length'); 
        hops = meta_data.hop_name';      
        hops(strcmp(hops, 'junc11_junc10')) = [];
    case 0.01
        disp('all links arranged by increasing hops_ID')
        hops = meta_data.hop_name;
    case 0.2
        disp('only onld links');
        hops = meta_data.hop_name(meta_data.first_appearance < datetime(2018,05,01,00,00,00));
        hops(strcmp(hops , 'junc11_junc10')) = [];


    case 0.1
        disp('make sure that no aditional links were added to meta_data recenlty');
        disp('all short links');
        hops = {'junc4_junc5','muni_teller','jun24_junc23','junc6_junc7','junc7_police','hitechhi_herzog','beithaam_smelansky','ramatalon_habadbanot','leonardo_junc2','junc14_junc13','junc1_agafhatnua','junc11_juncbneimoshe','junc5_junc6','beithaam_sarid','junc34_junc4','junc3_junc34','hitechhi_logistics','muni_revaha','deshalit_tachkimoni','police_beitlarom','muni_ganmeyasdim','beithaam_deshalit','muni_junc11','muni_junc24','leonardo_junc1','leonardo_junc3','moria_metamiteiman','moria_junc12','moria_ramatalon','muni_tarbut','junc16_junc17','muni_yadlebanim','moria_junc14','muni_schoolbenzvi','muni_beithaam'};
    case 1
        disp('make sure that no aditional links were added to meta_data recenlty');
        disp('South to north');
        hops = {'junc16_junc17' , 'moria_junc16' , 'moria_junc12' , 'moria_metamiteiman' , 'muni_moria' , 'muni_teller' , 'police_beitlarom' , 'junc7_police' , 'junc5_junc6' , 'junc4_junc5' , 'junc34_junc4' , 'junc3_junc34' , 'leonardo_junc3', 'muni_leonardo' , 'leonardo_junc2', 'leonardo_junc1' , 'junc1_agafhatnua'};
    case 2
        disp('make sure that no aditional links were added to meta_data recenlty');
        disp('west to east')
        hops = {'hitechhi_herzog' , 'hitechhi_logistics' , 'muni_hitechhi' , 'muni_leonardo' , 'muni_revaha' , 'muni_schoolbenzvi' , 'muni_junc11' , 'muni_beithaam' , 'junc11_junc10' , 'junc11_juncbneimoshe' , 'beithaam_smelansky' , 'beithaam_sarid' , 'beithaam_deshalit' , 'deshalit_tachkimoni'};  
    case 3
        disp('make sure that no aditional links were added to meta_data recenlty');
        disp('for debug 3 links only');
        hops = {'junc34_junc4' , 'junc16_junc17', 'muni_hitechhi'};
    case 3.1
        disp('make sure that no aditional links were added to meta_data recenlty');
        disp('for debug 4 short and far from each other links');
        hops = { 'muni_hitechhi' , 'moria_junc15' , 'junc1_agafhatnua' , 'muni_junc24' , 'muni_moria'};
    case 3.2
        disp('make sure that no aditional links were added to meta_data recenlty');
        disp('farest hops');
        hops = {'hitechhi_herzog' , 'junc16_junc17' , 'deshalit_tachkimoni' , 'junc1_agafhatnua'};
    case 4.1
        disp('make sure that no aditional links were added to meta_data recenlty');
        disp('herztel street (except the one with the tree)');
        hops = {'junc1_agafhatnua' , 'leonardo_junc1','leonardo_junc2' , 'leonardo_junc3' ,'junc3_junc34', 'junc34_junc4', 'junc4_junc5', 'junc5_junc6',  'junc6_junc7' , 'junc7_police', 'junc11_juncbneimoshe', 'junc14_junc13'};
    case 4.2
        disp('make sure that no aditional links were added to meta_data recenlty');
        disp('high hops');
        hops = {'muni_leonardo' ,'muni_hitechhi',  'moria_junc12', 'moria_ramatalon' ,'moria_junc14' , 'moria_junc15', 'moria_junc16'};

end
