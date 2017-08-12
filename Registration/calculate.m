close all;
clear all;

% Choose Images to run the code on
img1 = imread('brain1.png');
img2 = imread('brain2.png');
img1 = imresize(img1,0.3);
img2 = imresize(img2,0.3);

% Storing the original images for reference 
im1 = img1;
im2 = img2;

%Calculate the Grayscale values of the image 
if size(img1,3)==3
    img1 = rgb2gray(img1);
end
test1 = single(img1);
if size(img2,3)==3
    img2 = rgb2gray(img2);
end;
test2 = single(img2);

%Calculate the Dense Sift features for the image
[feat1,desc1]=vl_dsift(test1,'step',5,'size',6);
% [feat2,desc2]=vl_dsift(test1,'step',2,'size',10);
[feat3,desc3]=vl_dsift(test2,'step',5,'size',6);
% [feat4,desc4]=vl_dsift(test2,'step',2,'size',10);

%Find Pairwise difference matrix for the image
sigma = 1;
cross_dist1 = exp(-(pdist2(desc1',desc3','cosine').^2)/sigma);
cross_dist2 = exp(-(pdist2(desc3',desc1','cosine').^2)/sigma);
intra_dist1 = exp(-(pdist2(desc1',desc1','cosine').^2)/sigma);
intra_dist2 = exp(-(pdist2(desc3',desc3','cosine').^2)/sigma);

%Concatenate The matrices
mat1 = horzcat(intra_dist1,cross_dist1);
mat2 = horzcat(cross_dist2,intra_dist2);
W = vertcat(mat1,mat2);

%Find The Normalized Graph laplacian
D = sum(W,2);
D = diag(D);
D = D^(-1/2);
L = 1-(D*W*D);
% L = D-W;
%Find the required eigen vectors
[eig_vec,eig_val] = eig(L);
eig_val = diag(eig_val);

eig_vec = D*eig_vec;
[val,idx]=sort(real(eig_val));
K = 5;
vec=zeros(size(eig_vec,1),K);
vec(:,1:K)=eig_vec(:,(idx(1:K)));
eig1 = vec(1:size(desc1,2),:);
eig2 = vec(size(desc1,2)+1:size(desc1,2)+size(desc3,2),:);

%Remove unwanted variables
clear D;
clear W;
clear cross_dist1;
clear cross_dist2;
clear intra_dist1;
clear intra_dist2;
clear desc1;
clear desc3;
clear eig_vec;
clear eig_val;
clear mat1;
clear mat2;

%Interpolating back the values
[X1,Y1] = meshgrid(1:size(img1,2),1:size(img1,1));
[X2,Y2] = meshgrid(1:size(img2,2),1:size(img2,1));

for i=1:K
    eig1(:,i)=eig1(:,i)-min(eig1(:,i));
    eig1(:,i)=eig1(:,i)/max(eig1(:,i))*255;
    mat_eig1{i}=griddata(feat1(1,:)',feat1(2,:)',abs(eig1(:,i)),X1,Y1);
    mat_eig1{i}(isnan(mat_eig1{i}))=0;
end
for i=1:K
    eig2(:,i)=eig2(:,i)-min(eig2(:,i));
    eig2(:,i)=eig2(:,i)/max(eig2(:,i))*255;
    mat_eig2{i}=griddata(feat3(1,:)',feat3(2,:)',abs(eig2(:,i)),X2,Y2);
    mat_eig2{i}(isnan(mat_eig2{i}))=0;
end

%%Uncommment code for saving eigen images
% colormap('HSV');
% % subplot(1,K)
% for i=1:K
%     f = figure;
%     colormap('HSV');
%     imagesc(mat_eig1{i});
% %     name = strcat('./result2/eig1_',num2str(i),'.jpg');
% %     saveas(f,name);
% %     close;
% % end
% % subplot(1,K)
% % for i=1:K
% %     f = figure;
%     colormap('HSV');
%     name = strcat('./result2/eig_',num2str(i),'.jpg');
%     imagesc(mat_eig2{i});
%     saveas(f,name);
%     close;
% end
%

%% 
%Calculate the MSER Features
for i=1:K
    MSERfeat1{i} = detectMSERFeatures(uint8(mat_eig1{i}));
end
for i=1:K
    MSERfeat2{i} = detectMSERFeatures(uint8(mat_eig2{i}));
end
%calculate frames for SIFT descriptors
for i=1:K
    frames1{i} = double(extractFrames(MSERfeat1{i}));
    frames2{i} = double(extractFrames(MSERfeat2{i}));
end

%Get Sift Features(Probem: Matlab Crashing for this if you try to pass all as a matrix)
for i=1:K 
    feature = [];
    for j=1:length(frames1{i})
        [~,feature(j,:)] = vl_sift(im2single((img1)),'frames',frames1{i}(j,:)');
    end
    siftfeat1{i}=feature;
    feature = [];
    for j=1:length(frames2{i})
        [~,feature(j,:)] = vl_sift(im2single((img2)),'frames',frames2{i}(j,:)');
    end
    siftfeat2{i}=feature;

end

% Method For matching SIFT features
matched_pts1 = [];
matched_pts2 = [];

for i=1:K
%     indexPairs = match_features(MSERfeat1{i},MSERfeat2{i},siftfeat1{i}, siftfeat2{i}) ;
    indexPairs = vl_ubcmatch(siftfeat1{i}',siftfeat2{i}',1.5);
    matched_pts1 = cat(1,matched_pts1,frames1{i}(indexPairs(1, :),1:2));
    matched_pts2 = cat(1,matched_pts2,frames2{i}(indexPairs(2, :),1:2));
end
%  for i=1:K 
%     [surffeat1{i},vpts1{i}] = extractFeatures((uint8(mat_eig1{i})),MSERfeat1{i});
%     [surffeat2{i},vpts2{i}] = extractFeatures((uint8(mat_eig2{i})),MSERfeat2{i});
% end
%  for i=1:K 
%     [surffeat1{i},vpts1{i}] = extractFeatures((uint8(img1)),MSERfeat1{i});
%     [surffeat2{i},vpts2{i}] = extractFeatures((uint8(img2)),MSERfeat2{i});
% end
% for i=1:K
%     indexPairs = match_features(MSERfeat1{i},MSERfeat2{i},surffeat1{i}, surffeat2{i}) ;
%     matched_pts1{i} = MSERfeat1{i}(indexPairs(:, 1));
%     matched_pts2{i} = MSERfeat2{i}(indexPairs(:, 2));
% end
figure;showMatchedFeatures(im1,im2,matched_pts1,matched_pts2,'montage');
% for i=1:K
%     f = figure;
%     colormap('jet');
%     subplot(2,1,1);
%     imagesc(mat_eig1{i});
%     hold on
%     plot(MSERfeat1{i});
% %     name = strcat('./Presentation/mser1_',num2str(i),'.jpg');
% %     saveas(f,name);
% %     close;
% % end
% % for i=1:K
% %     f = figure;
%     subplot(2,1,2)
%     colormap('jet');
%     imagesc(mat_eig2{i});
%     hold on;
%     plot(MSERfeat2{i});
%     name = strcat('./Presentation/mser_',num2str(i),'.jpg');
%     saveas(f,name);
%     close;
% end

% colorbar;