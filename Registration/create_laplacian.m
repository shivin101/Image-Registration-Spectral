function lap=create_laplacian(img)
    [X1,Y1] = meshgrid(1:size(img,2),1:size(img,1));
    X= X1(:);
    Y= Y1(:);
    coord_mat = [X,Y];
    eps = 1;
    dist = pdist2(coord_mat,coord_mat,'euclidean').^2+eps;
    W = pdist2(img(:),img(:),'euclidean');
%     W=W-diag(diag(W));
    sigma = mean(W(:));
    W=exp(-(W.^2)/(2*(sigma^2)));
    W = W./dist;
    W(isnan(W))=0;
    W(find(W==(1/eps)))=1;
    D = sum(W,2);
    D = diag(D);
    G=D^-1;
    lap = G*(D-W);
end