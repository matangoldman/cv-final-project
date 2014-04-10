function [ hs_hist ] = extract_HS_hist_from_mask(I_hsv, mask_img, bin_lims)

mask_img_hs = repmat(mask_img,[1 1 2]);
sample_hs = I_hsv(mask_img_hs);
hs_data(:,1) = sample_hs(1:0.5*length(sample_hs));
hs_data(:,2) = sample_hs(0.5*length(sample_hs)+1:end);
hs_hist = extract_hs_hist(hs_data, bin_lims)';

end

