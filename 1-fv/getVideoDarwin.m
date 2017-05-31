function  getVideoDarwin(fullvideoname,featDir,descriptor_path,gmmSize,AllFeatureDimension)
    video_dir = '~/remote/KTH/';
    category = dir(video_dir);
    if ~exist(fullfile(featDir,'wall'),'dir')
        mkdir(fullfile(featDir,'wall'));
    end
    index = 1;
    dimension = gmmSize*AllFeatureDimension;
    for i = 3:length(category) % 1-6 actions'
            for j = 1:25
                for k = 1:4 % for clips
                    timest = tic();
                    allfeatFile = [];
                    clipName = 'person';
                    clipName = sprintf('%s%02d',clipName,j);
                    clipName = sprintf('%s_%s_d%d_uncomp',clipName,category(i).name,k);
                    allfeatFile = fullfile(featDir,sprintf('all/%s.mat',clipName));
                    %fprintf('%s is mbhfeatFile \n', mbhfeatFile);%'
                    if exist(allfeatFile,'file')
                            wallFile = fullfile(featDir,sprintf('wall/%s.mat',clipName));
                            if exist(wallFile,'file') == 0
                                timest = tic();
                                data = dlmread(allfeatFile);
                                data = reshape(data,dimension, size(data,1)/dimension);
                                w = genRepresentation(data,1);
                                class_label = i-2;
                                classLabelAndw = [class_label;w];
                                clear w;
                                dlmwrite(wallFile,classLabelAndw');
                                timest = toc(timest);
                                fprintf('%d/%d -> %s --> %1.2f sec\n',index,length(fullvideoname),wallFile,timest);
                            else
                                fprintf(' %s exist!\n',wallFile);
                            end
                        index = index+1;
                    end
                end
            end
    end

end