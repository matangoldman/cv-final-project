function [ mask_img ] = generate_circle_mask(img_size, x0, y0, r)

r = round(r);
mask_img = false(img_size);
circle_mask = fspecial('disk', r);
circle_mask = (circle_mask > max(circle_mask(:))/10); % binary circle mask
W = size(circle_mask,2);

% support circles which are partially out of image's boundaries
xs = max(x0-r,1);
ys = max(y0-r,1);

DXs = 1-(x0-r);
DXs = double((DXs>0).*DXs);
DYs = 1-(y0-r);
DYs = double((DYs>0).*DYs);
DXe = xs+W-1 - img_size(2);
DXe = double((DXe>0).*DXe);
DYe = ys+W-1 - img_size(1);
DYe = double((DYe>0).*DYe);

xe = min(xs+W-(DXe+DXs+1),img_size(2));
ye = min(ys+W-(DYe+DYs+1),img_size(1));

mask_img(ys:ye,xs:xe) = circle_mask(1+DYs:W-DYe, 1+DXs:W-DXe);

end

