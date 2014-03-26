% %% store object pixels in each image
% load('balls_GT.mat');
% obj_rgb_pix = cell(length(balls_GT),1);
% 
% for filenum=1:length(balls_GT)
%    img_path = fullfile('Training Set', balls_GT{filenum}.file_name);
%    I = imread(img_path);
%    subplot(1,2,1); imshow(I); hold all
%    I_mask = zeros([size(I,1) size(I,2)]);
%    for obj_num=1:size(balls_GT{filenum}.data,1)
%        obj_props = balls_GT{filenum}.data(obj_num,:);
%        r = 0.5*obj_props(3);
%        cx = obj_props(1)+r;
%        cy = obj_props(2)+r;
% %        draw_circle(cx,cy,r);
%        
%        e = imellipse(gca,obj_props);
%        I_mask = I_mask | createMask(e);
%    end
%    hold off;
%    subplot(1,2,2); imshow(I_mask);
%    drawnow;
%    
%    % crop labeled object's pixels
%    obj_pix_inds_ch1 = find(I_mask==true);
%    obj_pix_inds_ch2 = obj_pix_inds_ch1+size(I,1)*size(I,2);
%    obj_pix_inds_ch3 = obj_pix_inds_ch1+2*size(I,1)*size(I,2);
%    r_vals = I(obj_pix_inds_ch1);
%    g_vals = I(obj_pix_inds_ch2);
%    b_vals = I(obj_pix_inds_ch3);
%    
%    % store in data structure
%    obj_rgb_pix{filenum}.file_name = balls_GT{filenum}.file_name;
%    obj_rgb_pix{filenum}.data = [r_vals g_vals b_vals];
%    fprintf('%s [%d/%d]\n', obj_rgb_pix{filenum}.file_name, filenum, length(balls_GT));
% %    pause;
% end
% if(~exist('balls_pixels.mat', 'file'))
%     save('balls_pixels.mat', 'obj_rgb_pix');
% end
% 
% %% analyze data
% concat all pixels to a single matrix
if(~exist('obj_rgb_pix', 'var'))
    load('balls_pixels.mat');
end

Num_modes = 3; % number of modes in the GMM
rgb_data = [];
for num_obj=1:length(obj_rgb_pix);
    rgb_data = [rgb_data;obj_rgb_pix{num_obj}.data];
end

% convert rgb->hsv
hsv_data = rgb2hsv(rgb_data);
% convert hsv->pq colorspace (to avoid hue wrap-around)
p_data = hsv_data(:,2).*cos(2*pi*hsv_data(:,1));
q_data = hsv_data(:,2).*sin(2*pi*hsv_data(:,1));
pq_data = [p_data q_data];

% calculate GMM on pq colorspace
kmeans_idx = kmeans(pq_data, Num_modes);
options = statset('Display','final','MaxIter',200);
color_GMM = gmdistribution.fit(pq_data, Num_modes, 'Options', options, 'Start', kmeans_idx);

% display resulted GMM pdf
% contour plot
xp1 = linspace(-1,1,500); xp2 = linspace(-1,1,500);
[X1,X2] = meshgrid(xp1,xp2);
F = color_GMM.PComponents(1)*mvnpdf([X1(:) X2(:)],color_GMM.mu(1,:),color_GMM.Sigma(:,:,1)) + ... 
    color_GMM.PComponents(2)*mvnpdf([X1(:) X2(:)],color_GMM.mu(2,:),color_GMM.Sigma(:,:,2)) + ...
    color_GMM.PComponents(3)*mvnpdf([X1(:) X2(:)],color_GMM.mu(3,:),color_GMM.Sigma(:,:,3));

F = reshape(F,length(xp2),length(xp1));
plot([-1 1], [0 0], 'k', 'LineWidth', 2); hold on;
plot([0 0], [-1 1], 'k', 'LineWidth', 2);
contour(xp1,xp2,F,15, 'LineWidth', 2); 
hold off;
xlabel('p');
ylabel('q');
hObj = title('color GMM pdf');
set(hObj, 'FontSize', 14);
axis([-1 1 -1 1]);


%% randomize colors from each mode
color_map_size = [500 500];
for mode_num=1:3
    fprintf('[%d] mean hue: %0.3f, prob: %0.2f\n', ...
            mode_num, ...
            (360 / (2*pi)) * atan(color_GMM.mu(mode_num,2) / color_GMM.mu(mode_num,1)), ...
            color_GMM.PComponents(mode_num));
    
    rand_pix = mvnrnd(color_GMM.mu(mode_num,:),color_GMM.Sigma(:,:,mode_num), prod(color_map_size));
    % convert pq to hs
    rand_h = atan2(rand_pix(:,2), rand_pix(:,1));
    rand_h = (rand_h/(2*pi)).*(rand_h>0) + ((rand_h+2*pi)/(2*pi)).*(rand_h<0);
    rand_s = sqrt(rand_pix(:,1).^2 + rand_pix(:,2).^2);
    rand_s = 1*(rand_s>1) + rand_s.*(rand_s<1); % truncate values
    rand_pix_hsv = [rand_h rand_s ones(size(rand_h))];
%     rand_pix_hsv = rand_pix_hsv*255;
    rand_pix_hsv_sorted = sortrows(rand_pix_hsv,[-1 -3 2]);
    rand_pix = hsv2rgb(rand_pix_hsv_sorted);
    I_c = reshape(rand_pix,[color_map_size 3]);
    figure,imshow(I_c,[]);
    pause;
    
end

