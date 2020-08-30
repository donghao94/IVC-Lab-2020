Image and Video Compression Lab 2020
Optimization of Video Compression based on effective bit depth adaptation and CNN\
===============================
Last updated:  2020/08/14

##########Author#########
Donghao,Song
Mail: Donghao.song@tum.de


########Main function########
By running this project, the compression of the video frames of Foreman will be optimized. The corresponding bit rate and PSNR will be plot in a diagram.

########Requirement########
Install the Matlab Image Processing Toolbox.
Install the python3 with Tensorflow 2.3, Numpy, Matplotlib.
The code is tested on Matlab 2020a, with operating system Unix.

########Usage Description########
 
Step 1: Unzip the file. Please do not change the architecture of the file!
Step 2: Open and run the 'CompressAndSplit.m' in Matlab. Then you will see two files named           Block and DecFrame been created under the path.
Step 3: Open and run the CNNPrediction.py in Python3.(I test the code with Jupyter Notebook and Spyder.) Then you will see a file named CNNBlock been created under the path.
Step 4: Open and run the 'Block2Frame.m' in Matlab. At the end you will see the results plotted in a diagram.
Attention: As I don't have a computer with another operating system, it may has some path issues if you run this code not in Unix.

########Catalog########

+--DonghaoSongIVCLab
 |   +--foreman20_40_RGB
 |   +--lena_small.tif
 |   +--IVCLabPresentation.pptx
 |   +--Readme
 |   +--Presentation.mp4
 |   +--CompressAndSplit.m
 |   +--CNNPrediction.py
 |   +--Block2Frame.m
 |   +--CNNWeights


########Basic Description of Algorithms########

The basic idea of my concept is using bit depth adaptation to reduce the bit rate and using a trained CNN to improve the performance of PSNR. One of the highlight of our work is that I trained three different CNN-models for different quantisation scales, namely reconstructing frames with different quantisation scales individually. In this way the reconstructed frames achieve a better performance in PSNR than using a single model.