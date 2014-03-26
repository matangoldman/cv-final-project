function plot_hs_hist(bin_lims, bin_val,max_z)

hold all;


for bin_idx=1:size(bin_lims,1)
   r1 = bin_lims(bin_idx,3); 
   r2 = bin_lims(bin_idx,4);
   theta1 = bin_lims(bin_idx,1)*2*pi;
   theta2 = bin_lims(bin_idx,2)*2*pi;
   z2 = bin_val(bin_idx);
   
   mean_h = mean(bin_lims(bin_idx,1:2));
   mean_s = mean(bin_lims(bin_idx,3:4));
   mean_v = 1;
   rgb_color = hsv2rgb([mean_h mean_s mean_v]);
   
   draw_3D_wedge(r1,r2,0,z2,theta1,theta2,rgb_color);
end

if(exist('max_z','var'))
    axis([-1 1 -1 1 0 max_z]);
else
    axis([-1 1 -1 1]);
end

hold off;

end

