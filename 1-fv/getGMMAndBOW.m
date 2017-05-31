function [gmm] = getGMMAndBOW(fullvideoname,vocabDir,descriptor_path)
    samples = 256000;
    gmmSize = 256;
    pcaFactor = 0.5;
    sampleFeatFile = fullfile(vocabDir,'featfile.mat');
    modelFilePath = fullfile(vocabDir,'gmmvocmodel.mat');
    if exist(modelFilePath,'file')
        load(modelFilePath);
        return;
    end

      if ~exist(sampleFeatFile,'file')
        All = zeros(samples,396); 
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
                    all = [hog hof mbhx mbhy];
                    rnsam = randperm(size(all,1));
                    if numel(rnsam) > num_samples_per_vid
                        rnsam = rnsam(1:num_samples_per_vid);
                    end
                    send = st + numel(rnsam) - 1;
                    All(st:send,:) = all(rnsam,:);
                    st = st + numel(rnsam);        
                    timest = toc(timest);
                    fprintf('%d/%d -> %s --> %1.2f sec\n',index,length(fullvideoname),descriptorFile,timest);
                end
            end
        end

        if send ~= samples
            All(send+1:samples,:) = [];
            
        end
            fprintf('start computing pca\n');
            gmm.pcamap.all = pca(All);
            fprintf('start saving descriptors\n');
            save(sampleFeatFile,'All','gmm','-v7.3');    
    else
        load(sampleFeatFile);
    end

    fprintf('start create gmm \n');
    allProjected = All * gmm.pcamap.all(:,1:size(gmm.pcamap.all,1)*pcaFactor);
    [gmm.means.all, gmm.covariances.all, gmm.priors.all] = vl_gmm(allProjected', gmmSize);
    
    fprintf('start saving gmm and bow models\n');
    save(modelFilePath,'gmm');

end