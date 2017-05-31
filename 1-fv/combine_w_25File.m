function  combine_w_25File(fullvideoname,featDir_FV,descriptor_path)    
    video_dir = '~/remote/KTH/';
    category = dir(video_dir);
    if ~exist(fullfile(featDir_FV,'cwall'),'dir')
        mkdir(fullfile(featDir_FV,'cwall'));
    end
   
    index = 0;
    j = 1;
    cwallFile = fullfile(featDir_FV,sprintf('cwall/%d.mat',j));
    classLabelAndwall = [];
    if exist(cwallFile,'file')
        classLabelAndwall =  dlmread(cwallFile);
    end
    if size(classLabelAndwall,1) ~= 24*202753
              for i = 3:length(category) % 1-6 actions'
                        for j = 1:25
                            for k = 1:4 % for clips
                                clipName = 'person';
                                clipName = sprintf('%s%02d',clipName,j);
                                clipName = sprintf('%s_%s_d%d_uncomp',clipName,category(i).name,k);
                                wallFile = fullfile(featDir_FV,sprintf('wall/%s.mat',clipName));
                                cwallFile = fullfile(featDir_FV,sprintf('cwall/%d.mat',j));
                                if exist(wallFile,'file')
                                        index = index+1;
                                        timest = tic();
                                        classLabelAndwall = dlmread(wallFile);
                                        dlmwrite(cwallFile,classLabelAndwall,'-append');
                                        timest = toc(timest);
                                        fprintf('%d/%d -> %s --> %1.2f sec\n',index,length(fullvideoname),cwallFile,timest);
                                end
                            end
                        end
                end
    end


end