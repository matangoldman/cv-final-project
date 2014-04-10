function [Gcomat] = extract_bounded_rect_comatrices(x0,y0,r,I_hsv,ch)

if(exist('ch','var'))
    Gcomat = zeros(8,8);
else
    Gcomat = zeros(8,8,3);
end

% calculate bounded rect
a = sqrt(2)*r;
xs = round(max(x0-a/2, 1));
xe = round(min(x0+a/2, size(I_hsv,2)));
ys = round(max(y0-a/2, 1));
ye = round(min(y0+a/2, size(I_hsv,1)));

% return co-occurance matrix of all channels unless specified otherwise
if(exist('ch','var'))
    Ib = I_hsv(ys:ye,xs:xe,ch); % bounded rect patch
    G = graycomatrix(Ib, 'GrayLimits', [0.1 0.9], 'NumLevels', 8, 'offset', [0 1; -1 1; -1 0; -1 -1]);
    Gs = sum(G,3);
    Gcomat(:,:) = Gs / sum(Gs(:));    
else
    for ch=1:3
        Ib = I_hsv(ys:ye,xs:xe,ch); % bounded rect patch
        G = graycomatrix(Ib, 'GrayLimits', [0.1 0.9], 'NumLevels', 8, 'offset', [0 1; -1 1; -1 0; -1 -1]);
        Gs = sum(G,3);
        Gcomat(:,:,ch) = Gs / sum(Gs(:));
    end
end

end

