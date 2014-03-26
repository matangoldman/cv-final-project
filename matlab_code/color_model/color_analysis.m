addpath('C:\Program Files\MATLAB\R2011a\work\MSc\cv\project');

%% store object pixels in each image
load('..\balls_GT.mat');
obj_rgb_pix = cell(length(balls_GT),1);

for filenum=1:length(balls_GT)
   img_path = fullfile('..\Training Set', balls_GT{filenum}.file_name);
   I = imread(img_path);
   subplot(1,2,1); imshow(I); hold all
   I_mask = zeros([size(I,1) size(I,2)]);
   for obj_num=1:size(balls_GT{filenum}.data,1)
       obj_props = balls_GT{filenum}.data(obj_num,:);
       r = 0.5*obj_props(3);
       cx = obj_props(1)+r;
       cy = obj_props(2)+r;
       draw_circle(cx,cy,r);
       
       e = imellipse(gca,obj_props);
       I_mask = I_mask | createMask(e);
   end
   hold off;
   subplot(1,2,2); imshow(I_mask);
   drawnow;
   
   % crop labeled object's pixels
   obj_pix_inds_ch1 = find(I_mask==true);
   obj_pix_inds_ch2 = obj_pix_inds_ch1+size(I,1)*size(I,2);
   obj_pix_inds_ch3 = obj_pix_inds_ch1+2*size(I,1)*size(I,2);
   r_vals = I(obj_pix_inds_ch1);
   g_vals = I(obj_pix_inds_ch2);
   b_vals = I(obj_pix_inds_ch3);
   
   % store in data structure
   obj_rgb_pix{filenum}.file_name = balls_GT{filenum}.file_name;
   obj_rgb_pix{filenum}.data = [r_vals g_vals b_vals];
   fprintf('%s [%d/%d]\n', obj_rgb_pix{filenum}.file_name, filenum, length(balls_GT));
   pause;
end
if(~exist('balls_pixels.mat', 'file'))
    save('balls_pixels.mat', 'obj_rgb_pix');
end

%% analyze data
Q_h = 12;
Q_s = 3;
min_mode_ratio = 0.105;
% concat all pixels to a single matrix
if(~exist('obj_rgb_pix', 'var'))
    load('balls_pixels.mat');
end

Num_modes = 3; % number of modes
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

% divide data to different modes
kmeans_idx = kmeans(pq_data, Num_modes);
figure(1);
hold all;
plot(p_data(kmeans_idx==1), q_data(kmeans_idx==1), 'xb'); axis image;
plot(p_data(kmeans_idx==2), q_data(kmeans_idx==2), 'xr'); axis image;
plot(p_data(kmeans_idx==3), q_data(kmeans_idx==3), 'xg'); axis image;
plot([-1 1], [0 0], [0 0], [-1 1], 'k'); % axes
hold off;

% calc hue pdf for each mode
hue_hist = zeros(Num_modes,256);
apriori_prob = zeros(Num_modes,1);

for mode_num=1:Num_modes
    num_vals = sum(kmeans_idx==mode_num);
    hue_hist(mode_num,:) = hist(round(hsv_data(kmeans_idx==mode_num,1)*255),0:255) / num_vals;
    apriori_prob(mode_num) = num_vals / length(kmeans_idx);    
end

figure(2);
plot(0:255,hue_hist(1,:),'r'); hold on;
plot(0:255,hue_hist(2,:),'g');
plot(0:255,hue_hist(3,:),'b');
hold off;

close all;
% calculate and plot hue-sat histograms
color_hist = zeros(Num_modes, Q_h*Q_s);
for mode_num=1:Num_modes
    [bin_lims, bin_val] = calc_hs_hist(hsv_data(kmeans_idx==mode_num,1:2), Q_h, Q_s);
    color_hist(mode_num,:) = bin_val;
    
    figure(mode_num);
    plot_hs_hist(bin_lims, color_hist(mode_num,:), 0.5);
end

% associate each bin with most probable mode
% if probability is very low, the bin isn't assigned to any mode
[mode_val,bin_mode] = max(color_hist);
max_val = max(mode_val);
bin_mode = bin_mode.*(mode_val > min_mode_ratio*max_val);

% plot bin modes
figure(4);
bin_color = zeros(Num_modes,3);
for mode_num=1:Num_modes
    [~,max_bin] = max(color_hist(mode_num,:));
    mean_h = mean(bin_lims(max_bin,1:2));
    mean_s = mean(bin_lims(max_bin,3:4));
    mean_v = 1;
    bin_color(mode_num,:) = hsv2rgb([mean_h mean_s mean_v]);
end

plot_bin_mode(bin_lims, bin_mode, bin_color);

% store color model
color_model.num_modes = 3;
color_model.bin_lims = bin_lims;
color_model.color_hist = color_hist;
color_model.bin_mode = bin_mode;
save('color_model.mat', 'color_model');