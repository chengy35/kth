function trainAndTest_normalizedL2_FV(featDir_FV,featDir_LLC)
    video_dir = '~/remote/KTH/';
    category = dir(video_dir);
    nClasses = 6;
    nCorrect = 0;
    nTotal = 0; 
    resultFile = './result-normalized2';
    result = zeros(nClasses,nClasses);
    classAndwordTerm = {};
    for j = 1:25
    	featFile{j} = [fullfile(featDir_FV,sprintf('/cwall/%d.mat',j))];
    	fprintf('load %s\n',featFile{j});
	classAndwordTerm{j} = dlmread(featFile{j});
    end
    for j = 1:25
	timest = tic();
	trainfeatFile = {};
	index = 1;
	trainclassAndwordTerm = [];
	for k = 1:25
		if j ~= k,
			trainclassAndwordTerm = [trainclassAndwordTerm; classAndwordTerm{k}];
		end
	end
	testclassAndwordTerm = classAndwordTerm{j};

	trainSize = size(trainclassAndwordTerm,1);
	testSize = size(testclassAndwordTerm,1);
	trainlabel = trainclassAndwordTerm(:,1);
	testlabel = testclassAndwordTerm(:,1);
	nTrain = 1:trainSize;
	nTest = trainSize+1:trainSize+testSize;


	trainData = trainclassAndwordTerm(:,2:size(trainclassAndwordTerm,2));
	trainData = normalizeL2(trainData);
	
	testData = testclassAndwordTerm(:,2:size(testclassAndwordTerm,2));
	testData = normalizeL2(testData);
	testData_Kern_cell = [testData * trainData']; 

	trainData_Kern_cell = [trainData * trainData']; 
	trainData = [nTrain' trainData_Kern_cell];       %'
	
	testData = [nTest' testData_Kern_cell];       %'

	clear total;
	C = [0.1 1 10 100 500 1000 ];
	for ci = 1 : numel(C)
	     model(ci) = svmtrain(trainlabel, trainData, sprintf('-t 4 -c %1.6f -v 2 -q ',C(ci)));               
	end
	[~,max_indx]=max(model);

	C = C(max_indx);
	for ci = 1 : numel(C)
		model = svmtrain(trainlabel, trainData, sprintf('-t 4 -c %1.6f -q ',C(ci)));
		[predicted_label{ci}, acc, scores{ci}] = svmpredict(testlabel, testData ,model);	                 
		accuracy(ci) = acc(1,1);
	end
        	[acc,cindx] = max(accuracy); 
        	best_predicted_label =  predicted_label{cindx};
    	for i = 1: testSize
    		nTotal = nTotal + 1;
    		if best_predicted_label(i) == testlabel(i)
    			nCorrect = nCorrect + 1;
    		end
    		result(testlabel(i),best_predicted_label(i)) = result(testlabel(i),best_predicted_label(i))+1;
    	end
    	clear model;

    	clear trainData;
    	clear testData;
    	clear trainData_Kern_cell;
    	clear testData_Kern_cell;
    	clear trainclassandwordterm;
    	clear testclassAndwordTerm;
    	
	timest = toc(timest);
	fprintf('%d/%d --> %1.2f sec\n',j,25,timest);
      end

	average_accuracy = 0;
	for i = 1:nClasses
		nsequences = sum(result(i,:));
		if nsequences ~= 0
			average_accuracy = average_accuracy + result(i,i)/nsequences;
		end
	end
	average_accuracy = average_accuracy / nClasses;
	accuracy = nCorrect / nTotal;
	save(resultFile,'result','nTotal','average_accuracy','accuracy');
	fprintf('average_accuracy is %f, and accuracy is %f, and nTotal is %d',average_accuracy,accuracy,nTotal);
end

function X = normalizeL2(X)
	X = sqrt(abs(X));
	for i = 1 : size(X,1)
		if norm(X(i,:)) ~= 0
			X(i,:) = X(i,:) ./ norm(X(i,:));
		end
    end	   
end
