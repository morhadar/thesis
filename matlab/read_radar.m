%% data from IMS. jpg img.
if(0)
    db_path = '..\data\ims\rainmaps_10min_2018\2018\';
    path_nov06 = fullfile(db_path, '11\06\*.asc');
    path_dec06 = fullfile(db_path, '12\06\*.asc');
else
    dp_path_out = '..\results\radar\';
    out_dir_nov06 = fullfile(dp_path_out, '2018_11_06\');
    out_dir_dec06 = fullfile(dp_path_out, '2018_12_06\');
end

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
curr_path = '..\data\ims\weather2day\';
if(1)
    gif_gile = '2018-11-06.gif';
    frames = 12:17;
else
    gif_gile = '2018-12-06.gif';
end

[imgs,map] = imread(fullfile(curr_path , gif_gile),'frames','all');
% opticFlow = opticalFlowLK('NoiseThreshold',0.009);
% opticFlow = opticalFlowFarneback('NumPyramidLevels', 1);
opticFlow = opticalFlowHS;


h = figure;
movegui(h);
hViewPanel = uipanel(h,'Position',[0 0 1 1],'Title','Plot of Optical Flow Vectors');
hPlot = axes(hViewPanel);

% figure;
i = 0;

for fm_i = frames
    i= i+1;
    figure;
%     subplot(2,3,i); 
    frameGray = imgs(:, :, 1, fm_i);
%     flow = estimateFlow(opticFlow,frameGray);
    hold on; imshow(frameGray)
    %     hold on; plot(flow)
%     hold on
%     plot(flow,'DecimationFactor',[5 5],'ScaleFactor',60,'Parent',hPlot);
%     hold off
    
end