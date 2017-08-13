
close all;
clear all;

% Choose Images to run the code on
img1 = imread('brain1.png');
img2 = imread('brain2.png');

% img1 = imresize(img1,0.3);
% img2 = imresize(img2,0.3);
% Storing the original images for reference 
im1 = img1;
im2 = img2;

%Calculate the Grayscale values of the image 
if size(img1,3)==3
    img1 = rgb2gray(img1);
    img2 = rgb2gray(img2);
end
img2 = imresize(img2,size(img1));

%For distortimg image
img2 = distort_image(img1,2);

%Subsample the image
subsampleRate = 5;
img1 = sample_img(img1,subsampleRate);
img2 = sample_img(img2,subsampleRate);

%Create the laplacian based on intensity and spatial regularization measure
lap1 = create_laplacian(img1);
lap2 = create_laplacian(img2);

%Define number of eigen vectors and values
K=10;

%Get EigenValues and EigenVectors for each laplacian
[eig1,vals1] = eigs(lap1,K);
eig1 = real(eig1);

[eig2,vals2] = eigs(lap2,K);
eig2 = real(eig2);

% Scale and Reorder the vectors
eig1 = process_eig(eig1);
eig2 = process_eig(eig2);
cost = get_cost(eig1,eig2,img1,img2);
[eig1,eig2]=rearrange(eig1,eig2,cost);

[X1,Y1] = meshgrid(1:size(img1,2),1:size(img1,1));
[X2,Y2] = meshgrid(1:size(img2,2),1:size(img2,1));

for i=1:K
%     eig1(:,i)=eig1(:,i)-min(eig1(:,i));
%     eig1(:,i)=eig1(:,i)/max(eig1(:,i))*255;
    mat_eig1{i}=griddata(X1(:),Y1(:),(eig1(:,i)),X1,Y1);
    mat_eig1{i}(isnan(mat_eig1{i}))=0;
end
for i=1:K
%     eig2(:,i)=eig2(:,i)-min(eig2(:,i));
%     eig2(:,i)=eig2(:,i)/max(eig2(:,i))*255;
    mat_eig2{i}=griddata(X2(:),Y2(:),(eig2(:,i)),X2,Y2);
    mat_eig2{i}(isnan(mat_eig2{i}))=0;
end
mkdir('./result2');
%Uncommment code for saving eigen images
colormap('HSV');
% subplot(1,K)
for i=1:K
    f = figure;
    colormap('HSV');
    imagesc(mat_eig1{i});
    name = strcat('./result2/eig1_',num2str(i),'.jpg');
    saveas(f,name);
    close;
% end
% subplot(1,K)
% for i=1:K
    f = figure;
    colormap('HSV');
    name = strcat('./result2/eig2_',num2str(i),'.jpg');
    imagesc(mat_eig2{i});
    saveas(f,name);
    close;
end


