% % close all;
% % clc;
% % clear variables;
% % 
% 
% scan settings
scan_settings.suppression_alpha = 1;
scan_settings.color_edge = true;
scan_settings.draw_circles = false;
scan_settings.apply_histeq = false;
% this portion of the circle's circumference is good enough for detection
scan_settings.circle_detection_th = 0.3;
scan_settings.radius_range = 20:10:200;
scan_settings.use_GT = false;

load('..\balls_GT.mat');
scan_settings.use_GT = true;
scan_settings.GT = balls_GT;

% labeling settings
labeling_settings.draw_best_match = false;
labeling_settings.positive_label_th = 0.7;
labeling_settings.negative_label_th = 0;

scan_dir = '..\Training Set';
search_mask = [scan_dir '\*.JPG'];
file_list = dir(search_mask);
FV_DB = cell(length(file_list),1);

% scan directory
for img_num=1:length(file_list)
    img_path = fullfile(scan_dir,file_list(img_num).name);
%     img_path = '..\Training Set\MVC-019F.JPG';
    [img_feature_vectors] = scan_image(img_path, scan_settings);
    
    % add vectors to DB
    FV_DB{img_num}.filename = img_path;
    FV_DB{img_num}.feature_vectors = img_feature_vectors;
end


% compare to ground truth
% load('FV_DB_fromGT.mat');
load('..\balls_GT.mat'); % load ground truth

training_data = label_samples(balls_GT, FV_DB, labeling_settings);
display_training_data(training_data);