function [hist_dist, saliency_measure, gray_saliency, ...
          texture_saliency_h, texture_saliency_s, texture_saliency_v, ...
          hue_comat_dist, sat_comat_dist, lum_comat_dist, grad_hist_dist, ...
          matched_hist_file_idx, matched_hist_offset_within_file_idx] = ...
    extract_color_features(I_hsv, x0, y0, r, bin_lims, training_histograms, training_comatrices, training_Ghists,sample_hists)

% input: sample_hists
% outputs: matched_hist_file_idx, matched_hist_offset_within_file_idx, 
% are for debugging purposes


mask_img = generate_circle_mask([size(I_hsv,1) size(I_hsv,2)], x0, y0, r);
hs_hist = extract_HS_hist_from_mask(I_hsv, mask_img, bin_lims);

% compare to sample histograms
hist_dist = 1;
best_match_hist_idx = 0;
for hist_idx=1:size(training_histograms,1)
    % compute histogram intersection metric
    hist_intersection = sum(min(hs_hist,training_histograms(hist_idx,:)));
    
    % store minimal distance among all sample histograms
    curr_dist = 1-hist_intersection;
    if(curr_dist < hist_dist)
        hist_dist = curr_dist;
        best_match_hist_idx = hist_idx;
    end
end

% saliency measure
% histogram of external ring
large_circ_mask = generate_circle_mask([size(I_hsv,1) size(I_hsv,2)], x0, y0, sqrt(2)*r);
external_ring_mask = (~mask_img & large_circ_mask);
external_hist = extract_HS_hist_from_mask(I_hsv, external_ring_mask, bin_lims);
saliency_measure = sum(min(hs_hist,external_hist));

% gray saliency
I_h = I_hsv(:,:,3);
v_ext_pix = I_h(external_ring_mask);
v_int_pix = I_h(mask_img);
hist_ext = hist(v_ext_pix,linspace(0,1,255))/length(v_ext_pix);
hist_int = hist(v_int_pix,linspace(0,1,255))/length(v_int_pix);
gray_saliency = sum(min(hist_ext,hist_int));

% texture saliency
[texture_saliency_h] = calculate_texture_saliency(I_hsv, x0, y0, r, 1);
[texture_saliency_s] = calculate_texture_saliency(I_hsv, x0, y0, r, 2);
[texture_saliency_v] = calculate_texture_saliency(I_hsv, x0, y0, r, 3);

% comatrix distance
Gcomat = extract_bounded_rect_comatrices(x0,y0,r,I_hsv);

% compare to sample comatrices
min_dist = [1 1 1];
for samp_idx=1:length(training_comatrices)
    comat_int = min(Gcomat,training_comatrices{samp_idx});
    for ch=1:3
        comat_int_ch = comat_int(:,:,ch);
        samp_dist = 1-sum(comat_int_ch(:));
        if(samp_dist < min_dist(ch))
           min_dist(ch) = samp_dist; 
        end
    end
end

hue_comat_dist = min_dist(1);
sat_comat_dist = min_dist(2);
lum_comat_dist = min_dist(3);

% gradient histogram
g_hist = extract_region_grads_hist(x0,y0,r,I_hsv);

grad_hist_dist = 1;
for hist_idx=1:size(training_histograms,1)
    % compute histogram intersection metric
    hist_intersection = sum(min(g_hist,training_Ghists(hist_idx,:)));
    
    % store minimal distance among all sample histograms
    curr_dist = 1-hist_intersection;
    if(curr_dist < hist_dist)
        grad_hist_dist = curr_dist;
    end
end


% for debugging purposes
if(exist('sample_hists','var'))
    matched_hist_file_idx = 0;
    matched_hist_offset_within_file_idx = 0;
    matching_hist = training_histograms(best_match_hist_idx,:);
    for sample_hist_file_idx=1:length(sample_hists)
        file_hists = sample_hists{sample_hist_file_idx}.data;
        hists_diff = abs(file_hists - repmat(matching_hist, [size(file_hists,1) 1]));
        [min_val,min_idx] = min(sum(hists_diff,2));
        if(min_val == 0)
            matched_hist_file_idx = sample_hist_file_idx;
            matched_hist_offset_within_file_idx = min_idx;
        end
    end

else
    matched_hist_file_idx = [];    
    matched_hist_offset_within_file_idx = [];
end
% plot_hs_hist(bin_lims, hs_hist)


end
