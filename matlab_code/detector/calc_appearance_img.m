function [app_img] = calc_appearance_img(I_hsv, bin_lims, model_hist)

app_img = [];
max_h_lim = max(bin_lims(:,2));
max_s_lim = max(bin_lims(:,4));

app_img = zeros([size(I_hsv,1) size(I_hsv,2)]);

for bin_idx=1:size(bin_lims,1)
    is_max_h_lim = bin_lims(bin_idx,2)==max_h_lim;
    is_max_s_lim = bin_lims(bin_idx,4)==max_s_lim;
    
    if(is_max_h_lim && is_max_s_lim)
        app_img = app_img + model_hist(bin_idx) .* ...
            (I_hsv(:,:,1) >= bin_lims(bin_idx,1) & I_hsv(:,:,1) <= bin_lims(bin_idx,2) & ...
            I_hsv(:,:,2) >= bin_lims(bin_idx,3) & I_hsv(:,:,2) <= bin_lims(bin_idx,4));
        
    elseif(is_max_h_lim)
        app_img = app_img + model_hist(bin_idx) .* ...
            (I_hsv(:,:,1) >= bin_lims(bin_idx,1) & I_hsv(:,:,1) <= bin_lims(bin_idx,2) & ...
            I_hsv(:,:,2)  >= bin_lims(bin_idx,3) & I_hsv(:,:,2) < bin_lims(bin_idx,4));
        
    elseif(is_max_s_lim)
        app_img = app_img + model_hist(bin_idx) .* ...
            (I_hsv(:,:,1) >= bin_lims(bin_idx,1) & I_hsv(:,:,1) < bin_lims(bin_idx,2) & ...
            I_hsv(:,:,2)  >= bin_lims(bin_idx,3) & I_hsv(:,:,2) <= bin_lims(bin_idx,4));
    else
        app_img = app_img + model_hist(bin_idx) .* ...
            (I_hsv(:,:,1) >= bin_lims(bin_idx,1) & I_hsv(:,:,1) < bin_lims(bin_idx,2) & ...
            I_hsv(:,:,2)  >= bin_lims(bin_idx,3) & I_hsv(:,:,2) < bin_lims(bin_idx,4));
    end
    
end


end
