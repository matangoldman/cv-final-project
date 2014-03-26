function [bin_lims, bin_val] = calc_hs_hist(hs_data, Q_h, Q_s)
h_lims = linspace(0,1,Q_h+1);
s_lims = linspace(0,1,Q_s+1);

bin_val = zeros(Q_h*Q_s, 1);
bin_lims = zeros(Q_h*Q_s, 4);
N = size(hs_data,1);

num_bin = 1;
for h_seg=1:Q_h
    for s_seg=1:Q_s
        % hue limits
        bin_lims(num_bin, 1) = h_lims(h_seg);
        bin_lims(num_bin, 2) = h_lims(h_seg+1);
        % saturation limits
        bin_lims(num_bin, 3) = s_lims(s_seg);
        bin_lims(num_bin, 4) = s_lims(s_seg+1);
        
        % increment bin index
        num_bin = num_bin+1;
    end
end

for bin_idx=1:size(bin_lims,1)
    num_vals = sum(...
    hs_data(:,1) >= bin_lims(bin_idx,1) & hs_data(:,1) < bin_lims(bin_idx,2) & ...
    hs_data(:,2) >= bin_lims(bin_idx,3) & hs_data(:,2) < bin_lims(bin_idx,4));

    bin_val(bin_idx) = num_vals/N;
end


end

