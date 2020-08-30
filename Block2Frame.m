% save the original frames in the cell variable 'OriFrame' 
videoFolder = './foreman20_40_RGB/';
videoPath  = dir([videoFolder, '*.bmp']);
videoLength = length(videoPath);
OriFrame = cell(videoLength, 1);
for i = 1:videoLength
    OriFrame{i} = double(imread([videoFolder, videoPath(i).name]));
end

VideoOrStillImg = ["Video","Still Image"];
%Please give the path of the folder where CNN predicted frame blocks saved
newPSNRStill = zeros(1,11);
newPSNRVideo = zeros(1,11);
for x = 1:2
    switch VideoOrStillImg(x)
        case 'Still Image'
            CNNBlockFolder = './CNNBlock/Still/';
            if ~exist(CNNBlockFolder, 'dir')
                error('Please check the folder path!');
            end
            RecFrameFolder = './RecFrame/Still/QP';
        case 'Video'
            CNNBlockFolder = './CNNBlock/Video/';
            if ~exist(CNNBlockFolder, 'dir')
                error('Please check the folder path!');
            end
            RecFrameFolder = './RecFrame/Video/QP';  
    end
    
    scales = [0.07,0.1,0.2,0.4,0.8,1.0,1.5,2.0,3.0,4.0,4.5];
    for scaleIdx = 1 : numel(scales)
        QP = scales(scaleIdx);
        CNNBlockName = ['QP',num2str(QP),'/'];
        CNNBlockPath  = dir([CNNBlockFolder,CNNBlockName, '*.bmp']);
        % You can see the final reconstructed frames under this Folder.
        RecFramePath = [RecFrameFolder,num2str(QP),'/'];
        if ~exist(RecFramePath, 'dir')
            mkdir(RecFramePath);
        else
            rmdir(RecFramePath,"s");
            mkdir(RecFramePath);
        end
        
        BlockLength = length(CNNBlockPath);
        Blocks = cell(BlockLength, 1);
        FrameCell = cell(3,4);
        Frame = zeros(288,384);
        % read all frame blocks in the cell variable 'Blocks'
        for i = 1:BlockLength
            Blocks{i} = double(imread([CNNBlockFolder,CNNBlockName,'Block_',num2str(i),'.bmp']));
        end
        % reconstruct frame blocks to full frame and calculate the PSNR
        psnrCNN = 0;
        for i = 1:21
            j = (i-1)*12+1;
            for p = 1:3
                for q = 1:4
                    FrameCell{p,q} = Blocks{j};
                    j = j+1;
                end
            end
            Frame = cell2mat(FrameCell);
            Frame(:,353:end,:) = [];
            psnrCNN = psnrCNN + calcPSNR(OriFrame{i},Frame);
            imwrite(uint8(Frame),[RecFramePath,'RecForeman_',num2str(i),'.bmp']);
        end
        
        switch x 
            case 1
                newPSNRVideo(scaleIdx) = psnrCNN/21;
            case 2
                newPSNRStill(scaleIdx) = psnrCNN/21;
        end
        
    end
end

%% plot the result 

% BPP and PSNR data before optimization（this data is from result of the code of chapter 5）
oldBPPStill  = [5.34, 4.56, 3.30, 2.26, 1.56, 1.39, 1.12, 0.93, 0.74, 0.63, 0.60];
oldPSNRStill = [45.67,43.69,40.19,37.26,34.59,33.80,32.44,31.45,29.93,28.77,28.36];
oldBPPVideo  = [3.89, 3.20, 2.07, 1.22, 0.68, 0.56, 0.41, 0.31, 0.23, 0.19, 0.18]; 
oldPSNRVideo = [44.01,42.12,38.80,36.21,34.14,33.49,32.41,31.57,30.22,29.36,29.04];
% BPP data after optimization
[bppStill1,bppStill2,bppStill3,bppStill4,bppStill5,bppStill6,bppStill7,bppStill8,bppStill9,bppStill10,bppStill11] = textread('./BPPStill.txt',...
    '%f%f%f%f%f%f%f%f%f%f%f','delimiter', ',');
newBPPStill = [bppStill1,bppStill2,bppStill3,bppStill4,bppStill5,bppStill6,bppStill7,bppStill8,bppStill9,bppStill10,bppStill11];
[bppVideo1,bppVideo2,bppVideo3,bppVideo4,bppVideo5,bppVideo6,bppVideo7,bppVideo8,bppStill9,bppStill10,bppStill11] = textread('./BPPVideo.txt',...
    '%f%f%f%f%f%f%f%f%f%f%f','delimiter', ',');
newBPPVideo = [bppVideo1,bppVideo2,bppVideo3,bppVideo4,bppVideo5,bppVideo6,bppVideo7,bppVideo8,bppStill9,bppStill10,bppStill11];
newPSNRVideo(1) = 44.01;
newBPPVideo(1)  = 3.89;
newPSNRStill(1) = 45.67;
newBPPStill(1)  = 5.34;

% plot
figure(1);
oldVideo = plot(oldBPPVideo, oldPSNRVideo, ':x', 'Color', 'm','LineWidth',2,'MarkerSize',5);
hold on
oldStill= plot(oldBPPStill, oldPSNRStill, ':o', 'Color', 'm','LineWidth',2,'MarkerSize',5);
hold on
% bpp_1 = [2.64,1.24,0.68,0.38,0.31,0.23,0.19,0.17];
% psnr_1 = [40.6937768979592,38.2384779472758,35.6379634419647,34.6459096385387,33.7260006393659,33.0716636319192,32.9650037040838,31.7775698756072];
newStill = plot(newBPPStill,newPSNRStill,'-o', 'Color', 'c','LineWidth',2,'MarkerSize',5);
% bpp_2 = [3.92,2.27,1.56,1.04,0.93,0.74,0.63,0.48];
% psnr_2 = [40.6445721637495,38.1646127156070,35.9055304351428,33.4468295806701,32.6301826514331,31.0794255693478,29.8723293863039,28.1726964701420];
newVideo = plot(newBPPVideo,newPSNRVideo,'-x', 'Color', 'c','LineWidth',2,'MarkerSize',5);

ylim([25 50])
xlim([0.2 4.5])
hold on;
grid on;
xlabel('bitrate [bit/pixel]');
ylabel('PSNR [dB]');
legend([oldVideo, newVideo,oldStill,newStill], {'Baseline2(chapter 5)','My Optimization2','Baseline1(chapter 4)','My Optimization1'});
title('RD Performance of Optimization,Foreman Sequence');


function PSNR = calcPSNR(Image, recImage)
% Input         : Image    (Original Image)
%                 recImage (Reconstructed Image)
%
% Output        : PSNR     (Peak Signal to Noise Ratio)
% call calcMSE to calculate MSE
MSE = calcMSE(Image, recImage);
max_intensity = 2^8 - 1;
PSNR = 10*log10(max_intensity.^2/MSE);
end
function MSE = calcMSE(Image, recImage)
% Input         : Image    (Original Image)
%                 recImage (Reconstructed Image)
% Output        : MSE      (Mean Squared Error)
img_double = double(Image);
recImg_double = double(recImage);
img_diff = img_double - recImg_double;
mse = img_diff.^2;
MSE = mean(mse(:));
end