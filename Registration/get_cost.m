function cost = get_cost(eig1,eig2,img1,img2)
    for i=1:size(eig1,2)
        for j=1:size(eig2,2)
            histo1=hist3([double(img1(:)),eig1(:,i)],[20,20]);
            histo2=hist3([double(img2(:)),eig2(:,j)],[20,20]);
            histo3=hist3([double(img2(:)),-eig2(:,j)],[20,20]);
            cost1=sqrt(mean((eig1(:,i)-eig2(:,j)).^2))+sqrt(sum((histo1(:)-histo2(:)).^2)/(length(img1(:)).^2));
            cost2=sqrt(mean((eig1(:,i)+eig2(:,j)).^2))+sqrt(sum((histo1(:)-histo3(:)).^2)/(length(img1(:)).^2));
            cost(i,j)=min(cost1,cost2);
        end
    end
end