function W = genRepresentation(data,CVAL)
    OneToN = [1:size(data,1)]';    
    Data = cumsum(data);
    Data = Data ./ repmat(OneToN,1,size(Data,2));
    W_fow = liblinearsvr(getNonLinearity(Data),CVAL,2);
    %fprintf('obtain the W_fow\n');         
    order = 1:size(data,1);
    [~,order] = sort(order,'descend');
    data = data(order,:);
    Data = cumsum(data);
    Data = Data ./ repmat(OneToN,1,size(Data,2));
    W_rev = liblinearsvr(getNonLinearity(Data),CVAL,2);
    %fprintf('obtain the W_rev\n');                                   
    W = [W_fow ; W_rev];
end

function Data = getNonLinearity(Data)
    Data = sign(Data).*sqrt(abs(Data));
    % Data = vl_homkermap(Data',2,'kchi2');
    %Data =  sqrt(abs(Data));                       
    %Data =  sqrt(Data);       
end

function w = liblinearsvr(Data,C,normD)
    %fprintf('before liblinearsvr \n');      
    if normD == 2
        Data = normalizeL2(Data);
    end
    
    if normD == 1
        Data = normalizeL1(Data);
    end
    % in case it is complex, takes only the real part.  
    N = size(Data,1);
    Labels = [1:N]';
    %fprintf('before model train \n');      
    model = train(double(Labels), sparse(double(Data)),sprintf('-c %1.6f -s 11 -q',C) );
    w = model.w';
    %fprintf('after model train \n');
end

function x = normalizeL2(x)
    x=x./repmat(sqrt(sum(x.*conj(x),2)),1,size(x,2));
end
