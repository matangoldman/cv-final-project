function [detection_grade] = classify_region(balls_detector,I_hsv,x0,y0,r)
%CLASSIFY_REGION classify a circular region of the input image
% I_hsv - input image, in hsv format
%   region's properties defined by 
%   1. (x0,y0) - center pixel
%   2. r       - radius
% balls_detector - loaded by load_detector.m
% detection_grade - when the region is considered as a ball, a grade is
% returned, taking into account all of the detectors features
% when detection_grade=0, the region isn't considered a ball
% 
% detector is implemented as a cascade of features in order 
% to reduce CPU consumption. cascade order:
% 1. color histogram feature
% 2. color saliency feature
% 3. texture comatrix feature

detection_grade = 0;
feat_vals = [];

% 1st level of cascade - color feature
mask_img = generate_circle_mask([size(I_hsv,1) size(I_hsv,2)], x0, y0, r);
hs_hist = extract_HS_hist_from_mask(I_hsv, mask_img, balls_detector.color_model.bin_lims);

% compare to sample histograms
hist_dist = 1;
for hist_idx=1:size(balls_detector.color_model.color_hists,1)
    % compute histogram intersection metric
    hist_intersection = sum(min(hs_hist,balls_detector.color_model.color_hists(hist_idx,:)));
    
    % store minimal distance among all sample histograms
    curr_dist = 1-hist_intersection;
    if(curr_dist < hist_dist)
        hist_dist = curr_dist;
    end
end

if(hist_dist > balls_detector.classifier_features.th(1))
   return; 
end

feat_vals(end+1) = hist_dist; % color feature value

% 2nd level of cascade - color saliency
% histogram of external ring
large_circ_mask = generate_circle_mask([size(I_hsv,1) size(I_hsv,2)], x0, y0, sqrt(2)*r);
external_ring_mask = (~mask_img & large_circ_mask);
external_hist = extract_HS_hist_from_mask(I_hsv, external_ring_mask, balls_detector.color_model.bin_lims);
saliency_measure = sum(min(hs_hist,external_hist));

if(saliency_measure > balls_detector.classifier_features.th(2))
    return;
end

feat_vals(end+1) = saliency_measure; % saliency feature value

% 3rd level of cascade - texture feature (saturation co-occurance matrix)
sat_ch = 2;
Gcomat = extract_bounded_rect_comatrices(x0,y0,r,I_hsv,sat_ch); % saturation channel

% compare to sample comatrices
min_dist = 1;
for samp_idx=1:length(balls_detector.texture_comatrices)
    % distance from training sample
    comat_int = min(Gcomat,balls_detector.texture_comatrices{samp_idx}(:,:,sat_ch));
    
    samp_dist = 1-sum(comat_int(:));
    if(samp_dist < min_dist)
       min_dist = samp_dist; 
    end
end

if(min_dist > balls_detector.classifier_features.th(3))
    return;
end

feat_vals(end+1) = min_dist; % texture feature value

% 4th level of cascade - histogram of gradients
grads_hist = extract_region_grads_hist(x0,y0,r,I_hsv);

% compare to sample histograms
ghist_dist = 1;
for hist_idx=1:size(balls_detector.grads_hists,1)
    % compute histogram intersection metric
    hist_intersection = sum(min(grads_hist,balls_detector.grads_hists(hist_idx,:)));
    
    % store minimal distance among all sample histograms
    curr_dist = 1-hist_intersection;
    if(curr_dist < ghist_dist)
        ghist_dist = curr_dist;
    end
end

if(ghist_dist > balls_detector.classifier_features.th(4))
   return; 
end

feat_vals(end+1) = ghist_dist; % histogram of gradients

% cascade passed - ball detected!
% calculate detection grade
num_of_features = length(feat_vals);
for feat_idx=1:num_of_features
    feat_th  = balls_detector.classifier_features.th(feat_idx);
    feat_std = balls_detector.classifier_features.std(feat_idx);
    
    % grade is based on distance from threshold 
    % and std of positive population
    detection_grade = detection_grade + abs(feat_vals(feat_idx)-feat_th)/feat_std;
end

detection_grade = detection_grade / num_of_features;

end
