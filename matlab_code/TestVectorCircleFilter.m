% I=imread('Training Set\MVC-001F.JPG');
% r = 58;
% I=imread('Training Set\MVC-008F.JPG');
% r = 33;

I=imread('Training Set\MVC-008F.JPG');
r = 48;
fw = 3; % filter width

[H_Gx,H_Gy, H_nconst] = create_circle_filter(r,fw);

fhf = (size(H_Gx)-1)/2; % filter half size

I_gray = double(rgb2gray(I));
Ie = edge(I_gray,'canny');
Gx = imfilter(I_gray, [1 0 -1]);
Gy = imfilter(I_gray, [1 0 -1]');

Gm = sqrt(Gx.^2 + Gy.^2);
Gx = Gx ./ Gm;
Gy = Gy ./ Gm;
nan_idx = isnan(Gx);
Gx(nan_idx) = 0;
nan_idx = isnan(Gy);
Gy(nan_idx) = 0;

Gx = Gx .* Ie;
Gy = Gy .* Ie;

pix_corr = zeros(size(I_gray));

for y=fhf+1:size(I,1)-fhf
    y0 = y-fhf; y1 = y+fhf;
    
    for x=fhf+1:size(I,2)-fhf
        x0 = x-fhf; x1 = x+fhf;
        
        pix_corr(y,x) = sum(sum(abs(Gx(y0:y1,x0:x1).*H_Gx + Gy(y0:y1,x0:x1).*H_Gy)));
    end
end

pix_corr = pix_corr / H_nconst;
imshow(pix_corr,[]);

% for comparison - circular hough transform
[y0detect,x0detect,Accumulator] = houghcircle(Ie,r,0.25*pi*r);
figure, imshow(Accumulator,[]);