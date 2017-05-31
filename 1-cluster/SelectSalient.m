function [centers] =  SelectSalient(kmeans_size,totalnumber,fullvideoname,descriptor_path,vocabDir)
    sampleFeatFile = fullfile(vocabDir,'featfile.mat');
    modelFilePath = fullfile(vocabDir,'kmenasmodel.mat');
    if exist(modelFilePath,'file')
        load(modelFilePath);
        return;
    end
    start_index = 1;
    end_index = 1;
    
        if ~exist(sampleFeatFile,'file')
        trjAll = zeros(samples,30); 
        hogAll = zeros(samples,96); 
        hofAll = zeros(samples,108); 
        mbhAll = zeros(samples,96*2); 
        
        st = 1;
        warning('getGMM : update num_videos only to include training videos')
        video_dir = '~/remote/KTH/';
        category = dir(video_dir);
        index = 0;
        num_samples_per_vid = round(samples/length(fullvideoname));
        for i = 3:length(category) % 1-6 actions
            for j = 1:25
                for k = 1:4 % for clips
                    timest = tic();
                    descriptorFile = [];
                    clipName = 'person';
                    clipName = sprintf('%s%02d',clipName,j);
                    clipName = sprintf('%s_%s_d%d_uncomp',clipName,category(i).name,k);
                    descriptorFile = fullfile(descriptor_path,sprintf('%s.mat',clipName));
                    %fprintf('%s is descriptorFile \n', descriptorFile);
                    video_name = fullfile(video_dir,category(i).name,sprintf('%s.avi',clipName));
                    if exist(descriptorFile,'file') 
                        load(descriptorFile);
                        index = index + 1;
                    elseif exist(video_name,'file')
                        warning('Descriptor file not found\n');
                        index = index + 1;
                        [obj,trj,hog,hof,mbhx,mbhy] = extract_improvedfeatures(fullvideoname{index}) ;
                        save(descriptorFile,'obj','trj','hog','hof','mbhx','mbhy');
                    else
                        continue;
                    end
                    hog = sqrt(hog); hof = sqrt(hof); mbhx = sqrt(mbhx);mbhy = sqrt(mbhy);
                    mbh = [mbhx mbhy];
                    rnsam = randperm(size(mbh,1));
                    if numel(rnsam) > num_samples_per_vid
                        rnsam = rnsam(1:num_samples_per_vid);
                    end
                    send = st + numel(rnsam) - 1;
                    trjAll(st:send,:) = trj(rnsam,:);
                    hogAll(st:send,:) = hog(rnsam,:);
                    hofAll(st:send,:) = hof(rnsam,:);
                    mbhAll(st:send,:) = [mbhx(rnsam,:) mbhy(rnsam,:)];
                    st = st + numel(rnsam);        
                    timest = toc(timest);
                    fprintf('%d/%d -> %s --> %1.2f sec\n',index,length(fullvideoname),descriptorFile,timest);
                end
            end
        end

        if send ~= samples
            trjAll(send+1:samples,:) = [];
            hogAll(send+1:samples,:) = [];
            hofAll(send+1:samples,:) = [];
            mbhAll(send+1:samples,:) = [];
        end
            fprintf('start computing pca\n');
            gmm.pcamap.trj = pca(trjAll);
            gmm.pcamap.hog = pca(hogAll);
            gmm.pcamap.hof = pca(hofAll);
            gmm.pcamap.mbh = pca(mbhAll);
            fprintf('start saving descriptors\n');
            save(sampleFeatFile,'trjAll','hogAll','hofAll','mbhAll','gmm','-v7.3');    
    else
        load(sampleFeatFile);
    end


    % start to generating kmeans.
    numData = size(All,1);
    dimension = size(All,2);
    numClusters = kmeans_size;
    fprintf('%d\n', numData);
    [centers, ~] = vl_kmeans(All', kmeans_size, 'Initialization', 'plusplus') ; % need to transpose it...
    save(modelFilePath,'centers'); % remember it's size and dimension, take care of it.
end