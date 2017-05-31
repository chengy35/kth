function llcEncodeFeatures(centers,fullvideoname,descriptor_path,featDir_LLC,class_category)
	video_dir = '~/remote/KTH/';
	category = dir(video_dir);
	if ~exist(fullfile(featDir_LLC,'all'),'dir')
		mkdir(fullfile(featDir_LLC,'all'));
	end
	if ~exist(fullfile(featDir_LLC,'call'),'dir')
		mkdir(fullfile(featDir_LLC,'call'));
	end
	
	pyramid = [1, 2, 4];                % spatial block structure for the SPM               
	knn = 5;                            % number of neighbors for local coding
	index = 0;
	allfeatFile = fullfile(featDir_LLC,sprintf('all/%d.mat',1));

	classAndwordTermall = [];

	if exist(allfeatFile,'file')
    		classAndwordTermall =  dlmread(allfeatFile);
    	end
    	if size(classAndwordTermall,1) ~= 24*168001
		for i = 3:length(category) % 1-6 actions
			timest = tic();
			for j = 1:25
				for k = 1:4 % for clips
				descriptorFile = [];
				clipName = 'person';
				clipName = sprintf('%s%02d',clipName,j);
				clipName = sprintf('%s_%s_d%d_uncomp',clipName,category(i).name,k);
				descriptorFile = fullfile(descriptor_path,sprintf('%s.mat',clipName));
				if exist(descriptorFile,'file') == 2 
					fprintf('%d/%d %s \n',index,length(fullvideoname),descriptorFile);
					index = index + 1;
					load(descriptorFile);
					hog = sqrt(hog);hof = sqrt(hof);mbhx = sqrt(mbhx);mbhy = sqrt(mbhy);
					all = [hog hof mbhx mbhy];
					feaSet.feaArr = all';
					feaSet.x = obj(:,2);
					feaSet.y = obj(:,3); 
					video_name = fullvideoname{index};
					videoObj = VideoReader(video_name);
					feaSet.width = videoObj.Width;
					feaSet.height = videoObj.Height;
					fea = LLC_pooling(feaSet, centers, pyramid, knn); % get unnderstand of LLC_pooling
			 		allfeatFile = fullfile(featDir_LLC,sprintf('/all/%d.mat',j));
			 	    	class_label = class_category{index};
			 	    	classAndwordTermall = [class_label, fea']; 
		    			dlmwrite(allfeatFile,classAndwordTermall,'-append');
		    			end
				end
			end
			timest = toc(timest);
			fprintf('%d/%d -> %s --> %1.2f sec\n',i-2,length(category)-2,category(i-2).name,timest);		
		end
	end
	callfeatFile = fullfile(featDir_LLC,sprintf('call/%d.mat',1));
    	for j = 1:25
    		classAndwordTermall = [];
    		callfeatFile = fullfile(featDir_LLC,sprintf('call/%d.mat',j));
    		allfeatFile = fullfile(featDir_LLC,sprintf('/all/%d.mat',j));
    		if exist(callfeatFile,'file') ==0 
    			classAndwordTermall =  dlmread(allfeatFile);
    			classAndwordTermall = reshape(classAndwordTermall,168001,size(classAndwordTermall,1)/168001)';
    			save(callfeatFile,'classAndwordTermall');
    		end
    		fprintf('%s\n',callfeatFile);		
    	end
end