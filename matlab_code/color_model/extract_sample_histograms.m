load('color_model.mat');
load('..\balls_GT.mat');

sample_hist = cell(size(balls_GT));

for img_num=1:length(balls_GT)
    sample_hist{img_num}.file_name = balls_GT{img_num}.file_name;
    sample_hist{img_num}.data = [];
    I = imread(['..\Training Set\' sample_hist{img_num}.file_name]);
    I_hsv = rgb2hsv(I);
    mask_img = false([size(I,1), size(I,2)]);
    
    for ball_idx=1:size(balls_GT{img_num}.data,1)
        hs_data = [];
        
        x0 = round(balls_GT{img_num}.data(ball_idx,1));
        y0 = round(balls_GT{img_num}.data(ball_idx,2));
        
        % create circle mask in proper location
        mask_img_t = mask_img;
        circle_mask = fspecial('disk', round(0.5*balls_GT{img_num}.data(ball_idx,3)));
        circle_mask = (circle_mask > max(circle_mask(:))/10); % binary circle mask
        W = size(circle_mask,2);
        
        % extract hue & saturation from labeled region
        mask_img_t(y0:y0+W-1,x0:x0+W-1) = circle_mask;
        mask_img_hs = repmat(mask_img_t,[1 1 2]);
        sample_hs = I_hsv(mask_img_hs);
        hs_data(:,1) = sample_hs(1:0.5*length(sample_hs));
        hs_data(:,2) = sample_hs(0.5*length(sample_hs)+1:end);
        
        % calculate sample histogram
        hs_hist = extract_hs_hist(hs_data, color_model.bin_lims)';
%         plot_hs_hist(color_model.bin_lims, hs_hist)

        sample_hist{img_num}.data = vertcat(sample_hist{img_num}.data, hs_hist);
    end
end

bin_lims = color_model.bin_lims;
save('sample_hs_histograms.mat', 'sample_hist', 'bin_lims');
