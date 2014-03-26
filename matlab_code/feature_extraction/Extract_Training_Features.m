% scan_folder.m and scan_image.m are slow, because they perform
% hough transform to detect the circles.
% after they were ran and training data was labeled by label_samples.m
% training data features can be extracted using this script

addpath('..\color_model');
load('training_data.mat');
load('..\color_model\sample_hs_histograms.mat'); % for color features


% for img_num=1:length(training_data)
%     fprintf('processing image %d/%d\n', img_num, length(training_data));
%     
%     % pre-processing for color features:
%     % select valid training histograms - 
%     % don't use histograms extracted from the tested file
%     [~,fname,fext] = fileparts(training_data{img_num}.filename);
%     I = imread(training_data{img_num}.filename);
%     valid_hist_files = ~cellfun(@(entry) strcmp(entry.file_name, [fname fext]), sample_hist);
%     training_hists = [];
%     
%     for hist_file_idx=1:length(valid_hist_files)
%         is_valid_file =  valid_hist_files(hist_file_idx);
%         if(~is_valid_file)
%             continue;
%         end
%         
%         training_hists = vertcat(training_hists, sample_hist{hist_file_idx}.data); %#ok
%     end
%     
%     % additional column for histogram distance feature
%     training_data{img_num}.data(:,end+1) = 0;
%     
%     I_hsv = rgb2hsv(I);
%     % extract color features
%     for sample_idx=1:length(training_data{img_num}.is_positive)
% %         fprintf('processing sample %d/%d\n', sample_idx, length(training_data{img_num}.is_positive));
%         x0 = round(training_data{img_num}.data(sample_idx,1));
%         y0 = round(training_data{img_num}.data(sample_idx,2));
%         r = round(training_data{img_num}.data(sample_idx,3));
%         [hist_dist] = extract_color_features(I_hsv, x0, y0, r, bin_lims, training_hists);
%         training_data{img_num}.data(sample_idx,4) = hist_dist;
%         
% %         [hist_dist, hist_file_idx, hist_inner_offset] = extract_color_features(I_hsv, x0, y0, r, bin_lims, training_hists, sample_hist);
% %         training_data{img_num}.data(sample_idx,4) = hist_dist;
% %         training_data{img_num}.data(sample_idx,5) = hist_file_idx;
% %         training_data{img_num}.data(sample_idx,6) = hist_inner_offset;
%     end
% 
% end
% save('training_data_with_color_hist_feat.mat', 'training_data');

load('training_data_with_color_hist_feat.mat');

[training_samples] = unwrap_cells(training_data, 4);
save('training_samples.mat','training_samples');

% display positive/negative feature responses
pos_idx = logical(training_samples.is_positive);
neg_idx = ~pos_idx;
n_pos = sum(training_samples.is_positive);
n_neg = sum(~training_samples.is_positive);
hist_bin_vals = linspace(min(training_samples.feature_data(:,1)), max(training_samples.feature_data(:,1)), 50);
h_pos = hist(training_samples.feature_data(pos_idx,1), hist_bin_vals);
h_neg = hist(training_samples.feature_data(neg_idx,1), hist_bin_vals);
plot(hist_bin_vals, h_pos/n_pos, 'b'); hold on;
plot(hist_bin_vals, h_neg/n_neg, 'r');
hold off;

% filter out separable samples
feat1_th = max(training_samples.feature_data(pos_idx,1)) + std(training_samples.feature_data(pos_idx,1));
% feat1_th = max(training_samples.feature_data(pos_idx,1));
[out_training_data] = filter_training_data(training_data, training_samples, 4, 1, feat1_th, -1);

% display remaining samples
display_training_data(out_training_data);
% display_training_data(training_data);