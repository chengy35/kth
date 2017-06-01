function FVEncodeFeatures_w(fullvideoname,gmm,vocab,st,send,featDir,descriptor_path)
    video_dir = '~/remote/KTH/';
    category = dir(video_dir);
    pcaFactor = 0.5;
    
    if ~exist(fullfile(featDir),'dir')
        mkdir(fullfile(featDir));
    end
    if ~exist(fullfile(featDir,'all'),'dir')
        mkdir(fullfile(featDir,'all'));
    end
    
    index = 1;
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
                    if exist(descriptorFile,'file')
                        [~,partfile,~] = fileparts(fullvideoname{index});
                        allfeatFile = fullfile(featDir,sprintf('/all/%s.mat',partfile));
                        temp = index; 
                         if exist(allfeatFile) == 0
                            load(descriptorFile);
                            hog = sqrt(hog);hof = sqrt(hof);mbhx = sqrt(mbhx);mbhy = sqrt(mbhy);
                            all = [hog hof mbhx mbhy];
                            index = temp + 1;
                            frames = unique(obj(:,1));
                            fv_all = zeros( numel(frames),pcaFactor*size(gmm.pcamap.all,1)*2*size(gmm.means.all,2));
                            for frm = 1 : numel(frames)
                                frm_indx = find(obj(:,1)==frames(frm)); 
                                fv_all(frm,:) = getFisherVector(all,gmm.means.all, gmm.covariances.all, gmm.priors.all,gmm.pcamap.all,pcaFactor,frm_indx);
                            end
                            dlmwrite(allfeatFile,fv_all);
                        else
                            fprintf(' %s exist!\n',allfeatFile);
                        end
                        timest = toc(timest);
                        fprintf('%d/%d -> %s --> %1.2f sec\n',index-1,length(fullvideoname),descriptorFile,timest);
                    end
                end
            end
    end
end

function h = getFisherVector(all, means, covariances, priors,pcamap,pcaFactor,frm_indx)  
    comps = pcamap(:,1:size(pcamap,1)*pcaFactor);
    h = vl_fisher((all(frm_indx,:)*comps)', means, covariances, priors);
end