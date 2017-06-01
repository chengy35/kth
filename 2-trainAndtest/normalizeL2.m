function x = normalizeL2(x)
    x=x./repmat(sqrt(sum(x.*conj(x),2)),1,size(x,2));
end
