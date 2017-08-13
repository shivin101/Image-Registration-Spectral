function result=distort_image(I,type)
    if type==1
        %Sinusoid Distortion
        [nrows,ncols] = size(I);
        [xi,yi] = meshgrid(1:ncols,1:nrows);
        a1 = 10; % Try varying the amplitude of the sinusoids.
        a2 = 7;
        imid = round(size(I,2)/2); % Find index of middle element
        u = xi + a1*sin(pi*xi/imid);
        v = yi - a2*sin(pi*yi/imid);
        tmap_B = cat(3,u,v);
        resamp = makeresampler('linear','fill');
        I_sinusoid = tformarray(I,[],resamp,[2 1],[1 2],[],tmap_B,.3);

        figure, imshow(I_sinusoid)
        title('sinusoid');
        result = I_sinusoid;
    elseif type==2
        [nrows,ncols] = size(I);
        [xi,yi] = meshgrid(1:ncols,1:nrows);
        imid = round(size(I,2)/2);
        resamp = makeresampler('linear','fill');
        % radial pin cushion distortion
        xt = xi(:) - imid;
        yt = yi(:) - imid;
        [theta,r] = cart2pol(xt,yt);
        a = -.00001; % Try varying the amplitude of the cubic term.
        s = r + a*r.^3;
        [ut,vt] = pol2cart(theta,s);
        u = reshape(ut,size(xi)) + imid;
        v = reshape(vt,size(yi)) + imid;
        tmap_B = cat(3,u,v);
        I_pin = tformarray(I,[],resamp,[2 1],[1 2],[],tmap_B,.3);
        result = I_pin;
    end
    
end