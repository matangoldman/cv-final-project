function [bin_val] = extract_hs_hist(hs_data, bin_lims)

bin_val = zeros(size(bin_lims,1), 1);
N = size(hs_data,1);
idx = zeros(size(hs_data,1),1);
max_h_lim = max(bin_lims(:,2));
max_s_lim = max(bin_lims(:,4));

for bin_idx=1:size(bin_lims,1)
    is_max_h_lim = bin_lims(bin_idx,2)==max_h_lim;
    is_max_s_lim = bin_lims(bin_idx,4)==max_s_lim;
    
    if(is_max_h_lim && is_max_s_lim)
        num_vals = sum(...
        hs_data(:,1) >= bin_lims(bin_idx,1) & hs_data(:,1) <= bin_lims(bin_idx,2) & ...
        hs_data(:,2) >= bin_lims(bin_idx,3) & hs_data(:,2) <= bin_lims(bin_idx,4));
    elseif(is_max_h_lim)
        num_vals = sum(...
        hs_data(:,1) >= bin_lims(bin_idx,1) & hs_data(:,1) <= bin_lims(bin_idx,2) & ...
        hs_data(:,2) >= bin_lims(bin_idx,3) & hs_data(:,2) < bin_lims(bin_idx,4));        
    elseif(is_max_s_lim)
        num_vals = sum(...
        hs_data(:,1) >= bin_lims(bin_idx,1) & hs_data(:,1) < bin_lims(bin_idx,2) & ...
        hs_data(:,2) >= bin_lims(bin_idx,3) & hs_data(:,2) <= bin_lims(bin_idx,4));        
    else
        num_vals = sum(...
        hs_data(:,1) >= bin_lims(bin_idx,1) & hs_data(:,1) < bin_lims(bin_idx,2) & ...
        hs_data(:,2) >= bin_lims(bin_idx,3) & hs_data(:,2) < bin_lims(bin_idx,4));
    end

    idx = idx | ...
        (hs_data(:,1) >= bin_lims(bin_idx,1) & hs_data(:,1) < bin_lims(bin_idx,2) & ...
        hs_data(:,2) >= bin_lims(bin_idx,3) & hs_data(:,2) < bin_lims(bin_idx,4));

    bin_val(bin_idx) = num_vals/N;
end


end
