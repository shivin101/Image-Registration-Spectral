function [vec1,vec2]=rearrange(eig1,eig2,cost)
    vec1=eig1;
    for i=1:size(eig2,2)
        [~,idx]=min(cost(i,:));
        vec2(:,i)=eig2(:,idx)
    end
end