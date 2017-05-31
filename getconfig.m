function [video_data_dir,video_dir,fullvideoname, videoname,vocabDir,featDir_FV,featDir_LLC,descriptor_path,actionName,class_category] = getconfig()
    vocabDir = '~/remote/KTHData/Vocab'; % Path where dictionary/GMM will be saved.
    featDir_LLC = '~/remote/KTHData/llc/feats'; % Path where features will be saved
    featDir_FV = '~/remote/KTHData/fv/feats'; % Path where features will be saved
    descriptor_path = '~/remote/KTHData/descriptor/'; % change paths here 
    video_dir = '~/remote/KTH/';
    video_data_dir = '~/remote/KTHData/';
    category = dir(video_dir);
    index = 1;
    for i = 3 : length(category)
        fnames = dir(fullfile(video_dir,category(i).name));
        for j = 3: length(fnames)
            fullvideoname{index,1}=fullfile(video_dir,category(i).name,fnames(j).name);
            videoname{index,1} = fnames(j).name;
            class_category{index,1}= i-2;
            index = index+1;
        end
    end
    actionName = {'boxing','handclapping','handwaving','jogging','running','walking'};    
end