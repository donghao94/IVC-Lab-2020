videoFolder = './foreman20_40_RGB/';
videoPath  = dir([videoFolder, '*.bmp']);
videoLength = length(videoPath);
OriFrame = cell(videoLength, 1);
NewForemanFolder = '/Users/donghao/Desktop/EBDForeman/';
if ~exist(NewForemanFolder, 'dir')
    mkdir(NewForemanFolder);
else
    rmdir(NewForemanFolder,"s");
    mkdir(NewForemanFolder);
end

for i = 1:videoLength
    Frame = bitshift(double(imread([videoFolder, videoPath(i).name])),-1);
    imwrite(uint8(Frame),[NewForemanFolder,'DecNewForeman_',num2str(i),'.bmp']);
end