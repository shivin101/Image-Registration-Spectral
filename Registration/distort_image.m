function result=distort_image(I)
% locally varying with sinusoid
[nrows,ncols] = size(I);
[xi,yi] = meshgrid(1:ncols,1:nrows);
a1 = 5; % Try varying the amplitude of the sinusoids.
a2 = 3;
imid = round(size(I,2)/2); % Find index of middle element
u = xi + a1*sin(pi*xi/imid);
v = yi - a2*sin(pi*yi/imid);
tmap_B = cat(3,u,v);
resamp = makeresampler('linear','fill');
I_sinusoid = tformarray(I,[],resamp,[2 1],[1 2],[],tmap_B,.3);
result = I_sinusoid;
end