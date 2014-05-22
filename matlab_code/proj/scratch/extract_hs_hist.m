function [bin_val] = extract_hs_hist(hs_data, bin_lims)

% uniform quantization in both hue and saturation
Q_h = 12;
Q_s = 3;

is_max_val = (hs_data(:,1)==1);
h_bin(is_max_val) = Q_h;
h_bin(~is_max_val) = floor(hs_data(~is_max_val,1)*Q_h+1);

is_max_val = (hs_data(:,2)==1);
s_bin(is_max_val) = Q_s;
s_bin(~is_max_val) = floor(hs_data(~is_max_val,2)*Q_s+1);

pixel_bin = Q_s*(h_bin-1)+s_bin;
bin_val = hist(pixel_bin,1:36)'/length(pixel_bin);

% bin_val = zeros(size(bin_lims,1), 1);
% N = size(hs_data,1);
% max_h_lim = max(bin_lims(:,2));
% max_s_lim = max(bin_lims(:,4));
% 
% for bin_idx=1:size(bin_lims,1)
%     is_max_h_lim = bin_lims(bin_idx,2)==max_h_lim;
%     is_max_s_lim = bin_lims(bin_idx,4)==max_s_lim;
%     
%     if(is_max_h_lim && is_max_s_lim)
%         num_vals = sum(...
%         hs_data(:,1) >= bin_lims(bin_idx,1) & hs_data(:,1) <= bin_lims(bin_idx,2) & ...
%         hs_data(:,2) >= bin_lims(bin_idx,3) & hs_data(:,2) <= bin_lims(bin_idx,4));
%     elseif(is_max_h_lim)
%         num_vals = sum(...
%         hs_data(:,1) >= bin_lims(bin_idx,1) & hs_data(:,1) <= bin_lims(bin_idx,2) & ...
%         hs_data(:,2) >= bin_lims(bin_idx,3) & hs_data(:,2) < bin_lims(bin_idx,4));        
%     elseif(is_max_s_lim)
%         num_vals = sum(...
%         hs_data(:,1) >= bin_lims(bin_idx,1) & hs_data(:,1) < bin_lims(bin_idx,2) & ...
%         hs_data(:,2) >= bin_lims(bin_idx,3) & hs_data(:,2) <= bin_lims(bin_idx,4));        
%     else
%         num_vals = sum(...
%         hs_data(:,1) >= bin_lims(bin_idx,1) & hs_data(:,1) < bin_lims(bin_idx,2) & ...
%         hs_data(:,2) >= bin_lims(bin_idx,3) & hs_data(:,2) < bin_lims(bin_idx,4));
%     end
%     bin_val(bin_idx) = num_vals/N;
% end



end
