%% data from IMS. jpg img. 
db_path = '..\data\ims\rainmaps_10min_2018\2018\';
path_nov06 = fullfile(db_path, '11\06\*.asc');
path_dec06 = fullfile(db_path, '12\06\*.asc');

dp_path_out = '..\results\radar\';
out_dir_nov06 = fullfile(dp_path_out, '2018_11_06\');
out_dir_dec06 = fullfile(dp_path_out, '2018_12_06\');

%config:
curr_path = path_nov06;
out_dir = out_dir_nov06;
clims = [0 20];
opticFlow = opticalFlowFarneback;

h = figure;
movegui(h);
hViewPanel = uipanel(h,'Position',[0 0 1 1],'Title','Plot of Optical Flow Vectors');
hPlot = axes(hViewPanel);

files = dir(curr_path);
for i=1:length(images)
    fid = fopen(fullfile(files(i).folder , files(i).name), 'rt');
    C = textscan(fid, '%f', 'Delimiter',' ', 'HeaderLines', 0);
    fclose(fid);
    t = cell2mat(C);
    RM = reshape(t, [561 561] );
    figure; 
    imagesc( RM , clims);
    
    flow = estimateFlow(opticFlow,RM);
    imagesc(RM)
    hold on
    plot(flow,'DecimationFactor',[5 5],'ScaleFactor',60,'Parent',hPlot);
    hold off
    
    out_name = files(i).name(1:end-4);
%     saveas( gcf , [out_dir out_name '.jpg']);
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
curr_path = 'C:\Users\mhadar\Documents\personal\thesis_materials\data\ims\weather2day\';
nov06 = '2018-11-06.gif';
nov06_frames = 12:17;
dec06 = '2018-12-06.gif';

[imgs,map] = imread(fullfile(curr_path , nov06),'frames','all');
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