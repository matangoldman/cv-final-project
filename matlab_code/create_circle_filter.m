function [Gx,Gy,nconst] = create_circle_filter(radius, num_lvls)

rad = radius + ~mod(radius,2); % make sure it's odd
num_lvls = num_lvls + ~mod(num_lvls,2);

max_sz = 2*rad+1 + (num_lvls-1);
min_sz = 2*rad+1 - (num_lvls-1);
% 6,4,2,0,-2,-4,-6

% Gx = zeros(2*rad+1+4,2*rad+1+4);
% Gy = zeros(2*rad+1+4,2*rad+1+4);
% H = zeros(2*rad+1+4,2*rad+1+4);

Gx = zeros(max_sz);
Gy = zeros(max_sz);
H = zeros(max_sz);

% 5 layers
lvl = 1;

% for sz=2*rad+1+4:-2:2*rad+1-4
% for sz=2*rad+1+4:-2:2*rad+1-4
for sz=max_sz:-2:min_sz
   r = (sz-1)/2;
   H(lvl:end-(lvl-1), lvl:end-(lvl-1)) = H(lvl:end-(lvl-1), lvl:end-(lvl-1)) + ... 
                                         lvl*fspecial('disk',r)*pi*(r^2);
   
   lvl = lvl+1;
end

Gx = imfilter(H,[1 0 -1]);
Gy = imfilter(H,[1 0 -1]');

% normalize to unit vectors
Gx = Gx ./ (sqrt(Gx.^2 + Gy.^2));
Gy = Gy ./ (sqrt(Gx.^2 + Gy.^2));

nan_idx = isnan(Gx);
Gx(nan_idx) = 0;
nan_idx = isnan(Gy);
Gy(nan_idx) = 0;

nconst = sum(sum(Gx~=0));

end

