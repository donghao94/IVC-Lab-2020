
% split the original foreman frames to blocks with size 96x96x3
% and save it to target folder
OriFrameFolder = './foreman20_40_RGB/';
OriFramePath  = dir([OriFrameFolder, '*.bmp']);
videoLength = length(OriFramePath);
OriFrame = cell(videoLength, 1);
% The original frames will be splited to blocks and saved unter this folder
% path.
OriBlockPath = '/Users/donghao/Desktop/Block_foreman_V2/OriBlock/';
if ~exist(OriBlockPath, 'dir')
    mkdir(OriBlockPath);
else
    rmdir(OriBlockPath,"s");
    mkdir(OriBlockPath);
end
for i = 1:videoLength
    OriFrame{i} = double(imread([OriFrameFolder, OriFramePath(i).name]));
end
PadOri = cellfun(@(x)padarray(x,[0,32],'replicate','post'), OriFrame, 'Uniform', false);
BlockOri = cellfun(@(x)mat2cell(x,[96,96,96],[96,96,96,96],3), PadOri, 'Uniform', false);
for i = 1 : length(BlockOri)
    for j = 1:3
        for k = 1:4
            OriFrameCell = BlockOri{i};
            imwrite(uint8(OriFrameCell{j,k}),[OriBlockPath,'OriForeman_',num2str(12*(i-1)+4*(j-1)+k),'.bmp']);
        end
    end
end

% split the compressed and decoded foreman frames with different Quantization scales to blocks with size 96x96x3
% and save it in target folder
videoLength = 21;
EBDFrame = cell(videoLength, 1);
scales = [0.07,0.2,0.4,0.8,1.0,1.5,2.0,3.0];

VideoOrImg = 'Video'; 
for scaleIdx = 1 : numel(scales)
    qScale   = scales(scaleIdx);
    % This is the folder path of the reduced EBD frames after decoding.
    switch VideoOrImg
        case 'Video'
            DecPath = '/Users/donghao/Desktop/DecForeman_Video/';
        case 'Still Image'
            DecPath = '/Users/donghao/Desktop/DecForeman_StillImg/';
    end
    EBDFolder = [DecPath,'QP',num2str(qScale),'/'];
    EBDPath  = dir([EBDFolder, '*.bmp']);
    % This is the folder path to save the splited frame blocks.
    EBDBlockFolder = ['/Users/donghao/Desktop/Block_test/',num2str(VideoOrImg(x)),'/'];
    EBDBlockPath = [EBDBlockFolder,'Block_QP',num2str(qScale),'/'];
    if ~exist(EBDBlockPath, 'dir')
        mkdir(EBDBlockPath);
    else
        rmdir(EBDBlockPath,"s");
        mkdir(EBDBlockPath);
    end
    
    for i = 1:videoLength
        EBDFrame{i} = double(imread([EBDFolder, 'Frame_',num2str(i),'.bmp']));
    end
    PadEBD = cellfun(@(x)padarray(x,[0,32],'replicate','post'), EBDFrame, 'Uniform', false);
    BlockEBD = cellfun(@(x)mat2cell(x,[96,96,96],[96,96,96,96],3), PadEBD, 'Uniform', false);
    for i = 1 : length(BlockEBD)
        for j = 1:3
            for k = 1:4
                EBDFrameCell = BlockEBD{i};
                imwrite(uint8(EBDFrameCell{j,k}),[EBDBlockPath,'Block_',num2str(12*(i-1)+4*(j-1)+k),'.bmp']);
            end
        end
    end

end
end


