clear;
clc;
% TODO Add paths
addpath('~/lib/vlfeat/toolbox');
vl_setup();
setenv('LD_LIBRARY_PATH','/usr/local/lib/'); 
addpath('~/lib/liblinear/matlab');
addpath('~/lib/libsvm/matlab');

[video_data_dir,video_dir,fullvideoname, videoname,vocabDir,featDir_FV,featDir_LLC,descriptor_path,actionName,class_category] = getconfig();
st = 1;
send = length(videoname);
fprintf('Start : %d \n',st);
fprintf('End : %d \n',send);
addpath('0-trajectory');
fprintf('select salient trajectory\n');
getSalient(st,send,fullvideoname,descriptor_path)

encode = 'fv';
addpath('1-fv');
fprintf('getGMM \n');
% create GMM model, Look at this function see if parameters are okay for you.
[gmm] = getGMMAndBOW(fullvideoname,vocabDir,descriptor_path);

% generate Fisher Vectors
fprintf('generate Fisher Vectors \n');
gmmSize = 256;
AllFeatureDimension = 396;
FVEncodeFeatures_w(fullvideoname,gmm,vocabDir,st,send,featDir_FV,descriptor_path);
getVideoDarwin(fullvideoname,featDir_FV,descriptor_path,gmmSize,AllFeatureDimension);
clear gmm;
combine_w_25File(fullvideoname,featDir_FV,descriptor_path);

encode = 'llc';
addpath('1-cluster');
fprintf('begin llc encoding\n');
addpath('1-cluster');
totalnumber = 256000;
kmeans_size = 8000;
fprintf('clustering \n');
centers = SelectSalient(kmeans_size,totalnumber,fullvideoname,descriptor_path,vocabDir);
fprintf('llc Encoding now \n');
llcEncodeFeatures(centers,fullvideoname,descriptor_path,featDir_LLC,class_category);
clear centers;

addpath('2-trainAndtest');
%	trainAndTest_normalizedL2_LLC(featDir_FV,featDir_LLC);
%	trainAndTest_normalizedL2_FV(featDir_FV,featDir_LLC);
trainAndTest_normalizedL2_FV_LLC(featDir_FV,featDir_LLC,gmmSize,AllFeatureDimension);