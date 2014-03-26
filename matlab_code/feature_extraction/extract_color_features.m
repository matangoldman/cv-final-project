function [hist_dist, matched_hist_file_idx, matched_hist_offset_within_file_idx] = extract_color_features(I_hsv, x0, y0, r, bin_lims, training_histograms, sample_hists)

% input: sample_hists
% outputs: matched_hist_file_idx, matched_hist_offset_within_file_idx, 
% are for debugging purposes

mask_img = false([size(I_hsv,1), size(I_hsv,2)]);
circle_mask = fspecial('disk', r);
circle_mask = (circle_mask > max(circle_mask(:))/10); % binary circle mask
W = size(circle_mask,2);

% support circles which are partially out of image's boundaries
xs = max(x0-r,1);
ys = max(y0-r,1);

DXs = 1-(x0-r);
DXs = double((DXs>0).*DXs);
DYs = 1-(y0-r);
DYs = double((DYs>0).*DYs);
DXe = xs+W-1 - size(I_hsv,2);
DXe = double((DXe>0).*DXe);
DYe = ys+W-1 - size(I_hsv,1);
DYe = double((DYe>0).*DYe);

xe = min(xs+W-(DXe+DXs+1),size(I_hsv,2));
ye = min(ys+W-(DYe+DYs+1),size(I_hsv,1));

% % circle exceeds image's bounds
% if(DXs+DXe+DYe+DYs > 0)
%     num = 5;
% end

mask_img(ys:ye,xs:xe) = circle_mask(1+DYs:W-DYe, 1+DXs:W-DXe);
mask_img_hs = repmat(mask_img,[1 1 2]);
sample_hs = I_hsv(mask_img_hs);
hs_data(:,1) = sample_hs(1:0.5*length(sample_hs));
hs_data(:,2) = sample_hs(0.5*length(sample_hs)+1:end);
hs_hist = extract_hs_hist(hs_data, bin_lims)';

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
