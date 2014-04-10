function [texture_saliency] = calculate_texture_saliency(I_hsv, x0, y0, r, channel)

% bounded rectangle
a = sqrt(2)*r;
xs = round(max(x0-a/2, 1));
xe = round(min(x0+a/2, size(I_hsv,2)));
ys = round(max(y0-a/2, 1));
ye = round(min(y0+a/2, size(I_hsv,1)));
Ib = I_hsv(ys:ye,xs:xe,channel); % bounded rect patch

% bounding rectangle
a = 2*r;
xs = round(max(x0-a/2, 1));
xe = round(min(x0+a/2, size(I_hsv,2)));
ys = round(max(y0-a/2, 1));
ye = round(min(y0+a/2, size(I_hsv,1)));
IB = I_hsv(ys:ye,xs:xe,channel); % bounded rect patch

% external rectangular ring around bounding rect
a = sqrt(6)*r;
xs = round(max(x0-a/2, 1));
xe = round(min(x0+a/2, size(I_hsv,2)));
ys = round(max(y0-a/2, 1));
ye = round(min(y0+a/2, size(I_hsv,1)));
Ic = I_hsv(ys:ye,xs:xe,channel); % bounded rect patch
max_val = prctile(Ic(:),90);
min_val = prctile(Ic(:),10);

% calculate co-occurance matrices
Gb = graycomatrix(Ib, 'GrayLimits', [min_val max_val], 'NumLevels', 8, 'offset', [0 1; -1 1; -1 0; -1 -1]);
Gc = graycomatrix(Ic, 'GrayLimits', [min_val max_val], 'NumLevels', 8, 'offset', [0 1; -1 1; -1 0; -1 -1]);
GB = graycomatrix(IB, 'GrayLimits', [min_val max_val], 'NumLevels', 8, 'offset', [0 1; -1 1; -1 0; -1 -1]);
Gcs = sum(Gc,3);
GBs = sum(GB,3);
Ge = Gcs-GBs;
Gi = sum(Gb,3);
% normalize
Ge = Ge / sum(Ge(:));
Gi = Gi / sum(Gi(:));
hist_int = min(Ge,Gi);
% intersection between bounded rect and external rect
texture_saliency = sum(hist_int(:));


end

