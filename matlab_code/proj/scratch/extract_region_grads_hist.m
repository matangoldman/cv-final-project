function [grads_hist] = extract_region_grads_hist(x0,y0,r,I_hsv)

Q_levels = 8;
grads_hist = zeros(1,Q_levels);

% calculate bounded rect
a = sqrt(2)*r;
xs = round(max(x0-a/2, 1));
xe = round(min(x0+a/2, size(I_hsv,2)));
ys = round(max(y0-a/2, 1));
ye = round(min(y0+a/2, size(I_hsv,1)));

Ib = I_hsv(ys:ye,xs:xe,2); % bounded rect patch

[Gx,Gy] = gradient(Ib);

mag = sqrt(Gx.^2 + Gy.^2); % magnitude
theta = atan2(Gy,Gx)-eps;
theta = (theta<0).*(theta+pi) + (theta>=0).*theta; % ignore brightness polarity

% quantize to Q_levels
theta_lvl = theta*(Q_levels/pi);
theta_Q = floor(theta_lvl)+1;
theta_Q = (theta_Q>Q_levels).*Q_levels + (theta_Q<=Q_levels).*theta_Q;

% calculate total magnitude for each direction
for lvl=1:Q_levels
    angle_magnitudes = (theta_Q==lvl).*mag;
    grads_hist(lvl) = sum(angle_magnitudes(:));
end

% normalize
grads_hist = grads_hist / sum(grads_hist);


end

