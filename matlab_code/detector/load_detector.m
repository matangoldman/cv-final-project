function [balls_detector] = load_detector(color_hist_path, grad_hist_path, texture_matrices_path, classifier_path, img_path)
%LOAD_DETECTOR Loads ball classifier detector, which can be used for
% detection (in detect_ball) later
%   color_hist_path - path of color histograms that are used by the detector
%   grad_hist_path - path of gradient histograms that are used by the detector
%   texture_matrices_path - path of texture co-occurance matrices that are used by the detector
%   classifier_path - stores features data
%   img_path - if supplied, histograms and textures from this image will
%   not be used by the detector (test image cannot be part of training data)


load(color_hist_path);
load(texture_matrices_path);
load(classifier_path);
load(grad_hist_path);

% filter out detector data from this image
detector_hists = [];
detector_ghists = [];
detector_comatrices = cell(0);
if(exist('img_path', 'var'))
    [~,fname,fext] = fileparts(img_path);
    
    valid_hist_files = ~cellfun(@(entry) strcmp(entry.file_name, [fname fext]), sample_hist);
else
    valid_hist_files = ones(length(sample_hist));
end

for hist_file_idx=1:length(valid_hist_files)
    is_valid_file =  valid_hist_files(hist_file_idx);
    if(~is_valid_file)
        continue;
    end

    detector_hists  = vertcat(detector_hists, sample_hist{hist_file_idx}.data); %#ok
    
    for num_samp=1:length(samples_Comatrix(hist_file_idx).data)
        detector_comatrices{end+1} = samples_Comatrix(hist_file_idx).data{num_samp};
        detector_ghists = vertcat(detector_ghists, grads_hists(hist_file_idx).data{num_samp});
    end
end

% use average of color and gradient histograms
% (produces more stable features)
detector_ghists = sum(detector_ghists) / sum(detector_ghists(:));
detector_hists = sum(detector_hists) / sum(detector_hists(:));

% add data to detector struct
balls_detector.color_model.bin_lims = bin_lims;
balls_detector.color_model.color_hists = detector_hists;
balls_detector.grads_hists = detector_ghists;
balls_detector.texture_comatrices = detector_comatrices;
balls_detector.classifier_features = ball_classifier;
