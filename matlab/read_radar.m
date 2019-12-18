path_radar_2018 = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\ims\rainmaps_10min_2018\2018\11\06\PA201811060000 - Copy.asc';

path_nov06 = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\ims\rainmaps_10min_2018\2018\11\06\*.asc';
path_dec06 = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\ims\rainmaps_10min_2018\2018\12\06\*.asc';


out_dir_nov06 = 'C:\Users\mhadar\Documents\personal\thesis_materials\graphs_and_figures\radar\2018_11_06\';
out_dir_dec06 = 'C:\Users\mhadar\Documents\personal\thesis_materials\graphs_and_figures\radar\2018_12_06\';

background_path = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\ims\radar_background.png';
background = imresize(imread(background_path), [561 561]);

%%
path = path_dec06;
out_dir = out_dir_dec06;


files = dir(path);
N = length(files);
images   = cell(N,1);
clims =[0 7];
for i=4%1:length(images)
    fid = fopen(fullfile(files(i).folder , files(i).name), 'rt');
    C = textscan(fid, '%f', 'Delimiter',' ', 'HeaderLines', 0);
    fclose(fid);
    t = cell2mat(C);
    images{i} = reshape(t, [561 561] );
    figure; 
    imagesc( images{i} , clims); 
 %  t = imfuse(background , images{i});
    out_name = files(i).name(1:end-4);
    saveas( gcf , [out_dir out_name '.jpg']);
    %close all;
end

%% check max:
max_val = -1;
for i=1:length(images)
    curr_max = max(max(  images{i}));
    if curr_max > max_val
        max_val = curr_max;
    end
end

%%
 % create the video writer with 30 fps
 writerObj = VideoWriter('radar_nov06.avi');
 writerObj.FrameRate = 30;
   % open the video writer
   open(writerObj);
   % write the frames to the video
    for u=1:N    
       % convert the image to a frame
       frame = im2frame(images{u}/max_val);
           writeVideo(writerObj, frame);
   end
   % close the writer object
   close(writerObj);
   implay('Velocity.avi');
   
%% read gif:
path = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\ims\weather2day\';
nov06 = '2018-11-06.gif';
nov06_frames = 12:17;
dec06 = '2018-12-06.gif';

[imgs,map] = imread(fullfile(path , nov06),'frames','all');
% opticFlow = opticalFlowLK('NoiseThreshold',0.009);
% opticFlow = opticalFlowFarneback('NumPyramidLevels', 1);
opticFlow = opticalFlowHS;


h = figure;
movegui(h);
hViewPanel = uipanel(h,'Position',[0 0 1 1],'Title','Plot of Optical Flow Vectors');
hPlot = axes(hViewPanel);

% figure;
for i = 1:2%length(nov06_frames)
%     figure;
%     %subplot(2,3,i); 
%     imshow(imgs(:,:,1,nov06_frames(i))); 
%     title(num2str(nov06_frames(i)));
%     saveas(gcf, [path num2str(nov06_frames(i)) '.jpg']);
    %TODO - continue from here!
    frameGray = imgs(:,:,1,nov06_frames(i));
    flow = estimateFlow(opticFlow,frameGray);
%     subplot(1,2,i);
%     hold on; imshow(frameGray)
%     hold on; plot(flow)
    imshow(frameGray)
    hold on
    plot(flow,'DecimationFactor',[5 5],'ScaleFactor',60,'Parent',hPlot);
    hold off
    
end