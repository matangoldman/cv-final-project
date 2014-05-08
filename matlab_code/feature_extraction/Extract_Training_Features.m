% scan_folder.m and scan_image.m are slow, because they perform
% hough transform to detect the circles.
% after they were ran and training data was labeled by label_samples.m
% training data features can be extracted using this script

close all;
addpath('..\color_model');
load('training_data.mat');
% 1. loading hue-saturation histograms (sample_hist)
% each entry belongs to a different file from the training data
% each row in sample_hist{file_num}.data, is a histogram of a separate ball
% 2. loading bin_lims - histogram's bin limits
load('..\color_model\sample_hs_histograms.mat'); % for color features
load('sample_comatrices.mat'); % for texture features
load('grads_hists.mat');
margin_factor = 0.5;
% which features we use for training from the extracted features
detector_features = [1 2 8 10];
% detector_features = [1 2 8];

display_feature_histograms = false;
extract_features = false;
display_remaining_detection = false;


if(extract_features)
    for img_num=1:length(training_data)
        fprintf('processing image %d/%d\n', img_num, length(training_data));

        % pre-processing for color features:
        % select valid training histograms - 
        % don't use histograms extracted from the tested file
        [~,fname,fext] = fileparts(training_data{img_num}.filename);
        I = imread(training_data{img_num}.filename);
        valid_hist_files = ~cellfun(@(entry) strcmp(entry.file_name, [fname fext]), sample_hist);
        training_hists = [];
        training_grads_hists = [];
        training_comatrices = cell(0);
        

        for hist_file_idx=1:length(valid_hist_files)
            is_valid_file =  valid_hist_files(hist_file_idx);
            if(~is_valid_file)
                continue;
            end

            training_hists = vertcat(training_hists, sample_hist{hist_file_idx}.data); %#ok
            for num_samp=1:length(samples_Comatrix(hist_file_idx).data)
                training_comatrices{end+1} = samples_Comatrix(hist_file_idx).data{num_samp};
                training_grads_hists = vertcat(training_grads_hists, grads_hists(hist_file_idx).data{num_samp});
            end
        end
        
        % use average of color and gradient histograms
        % (produces more stable features)
        training_hists = sum(training_hists) / sum(training_hists(:));
        training_grads_hists = sum(training_grads_hists) / sum(training_grads_hists(:));

        I_hsv = rgb2hsv(I);
        % extract color features
        for sample_idx=1:length(training_data{img_num}.is_positive)
    %         fprintf('processing sample %d/%d\n', sample_idx, length(training_data{img_num}.is_positive));
            x0 = round(training_data{img_num}.data(sample_idx,1));
            y0 = round(training_data{img_num}.data(sample_idx,2));
            r = round(training_data{img_num}.data(sample_idx,3));
            [hist_dist, saliency_dist, gray_saliency, texture_saliency_h, texture_saliency_s, texture_saliency_v, ...
             hue_comat_dist, sat_comat_dist, lum_comat_dist, grad_hist_dist] = ...
            extract_color_features(I_hsv, x0, y0, r, bin_lims, training_hists, training_comatrices, training_grads_hists);

            training_data{img_num}.data(sample_idx,4)  = hist_dist;
            training_data{img_num}.data(sample_idx,5)  = saliency_dist;
            training_data{img_num}.data(sample_idx,6)  = gray_saliency;
            training_data{img_num}.data(sample_idx,7)  = texture_saliency_h;
            training_data{img_num}.data(sample_idx,8)  = texture_saliency_s;
            training_data{img_num}.data(sample_idx,9)  = texture_saliency_v;
            training_data{img_num}.data(sample_idx,10) = hue_comat_dist;
            training_data{img_num}.data(sample_idx,11) = sat_comat_dist;
            training_data{img_num}.data(sample_idx,12) = lum_comat_dist;
            training_data{img_num}.data(sample_idx,13) = grad_hist_dist;

    %         [hist_dist, saliency_dist, saliency_dist, gray_saliency, hist_file_idx, hist_inner_offset] = ...
    %           extract_color_features(I_hsv, x0, y0, r, bin_lims, training_hists, training_comatrices, sample_hist);
    %         training_data{img_num}.data(sample_idx,4) = hist_dist;
    %         training_data{img_num}.data(sample_idx,5) = hist_file_idx;
    %         training_data{img_num}.data(sample_idx,6) = hist_inner_offset;
        end

    end
    
    % features extracted. save them
    save('training_data_with_color_hist_feat.mat', 'training_data');
else
    load('training_data_with_color_hist_feat.mat');
end

[training_samples] = unwrap_cells(training_data, 4);

if(extract_features)
    save('training_samples.mat','training_samples');
end

% display positive/negative feature responses
pos_idx = logical(training_samples.is_positive);
neg_idx = ~pos_idx;
n_pos = sum(training_samples.is_positive);
n_neg = sum(~training_samples.is_positive);

det_feat_idx = 1;
out_training_samples = training_samples;
out_training_data = training_data;
% for feat_idx = 1:1 ...size(training_samples.feature_data,2)
for feat_idx = 1:size(training_samples.feature_data,2)
    
    detector_feat = logical(sum(detector_features == feat_idx));
    if(~detector_feat)
        continue;
    end
    % find threshold
    feat_std = std(training_samples.feature_data(pos_idx,feat_idx));
    feat_th = max(training_samples.feature_data(pos_idx,feat_idx)) + margin_factor*feat_std;
        
    fprintf('(%d) feature seperability: %2.0f%%\n', feat_idx, 100*sum(training_samples.feature_data(neg_idx,feat_idx) > feat_th) / n_neg);
    [out_training_data, out_training_samples] = filter_training_data(training_data, out_training_samples, feat_idx, feat_th, -1);
    
    % append detector structure
    ball_classifier.th(det_feat_idx)  = feat_th;
    ball_classifier.std(det_feat_idx) = feat_std;
    det_feat_idx = det_feat_idx+1;
    
    % display histograms when asked for
    if(display_feature_histograms)
        figure(feat_idx);
        hist_bin_vals = linspace(min(training_samples.feature_data(:,feat_idx)), max(training_samples.feature_data(:,feat_idx)), 50);
        h_pos = hist(training_samples.feature_data(pos_idx,feat_idx), hist_bin_vals);
        h_neg = hist(training_samples.feature_data(neg_idx,feat_idx), hist_bin_vals);
        plot(hist_bin_vals, h_pos/n_pos, 'b'); hold on;
        plot(hist_bin_vals, h_neg/n_neg, 'r');
        plot([feat_th feat_th], ylim, '--k');
        legend('positive', 'negative', 'threshold');
        hold off;
    end
end



fprintf('number of false positives: %d\n', sum(~out_training_samples.is_positive));


save('..\detector\balls_classifier_data.mat', 'ball_classifier');

% display remaining samples
if(display_remaining_detection)
    figure;
    display_training_data(out_training_data);
    % display_training_data(training_data);
end

% SVM classifier
% train
p=training_samples.feature_data(pos_idx,detector_features);  % positive data
n=training_samples.feature_data(~pos_idx,detector_features); % negative data
labels = [ones(size(p,1),1);-ones(size(n,1),1)]; % class labels

% test on training data
svm_train_data = [p;n];
SVMStruct = svmtrain(svm_train_data, labels);
classify_results = svmclassify(SVMStruct, svm_train_data);
sum(abs(classify_results - labels));

% note: projections are calculated in svmdecision, 
% which is called from svmclassify. can be used as detector grades