function plot_bin_mode(bin_lims, bin_mode, bin_color)

hold all;

for bin_idx=1:size(bin_lims,1)
   r1 = bin_lims(bin_idx,3); 
   r2 = bin_lims(bin_idx,4);
   theta1 = bin_lims(bin_idx,1)*2*pi;
   theta2 = bin_lims(bin_idx,2)*2*pi;
   %    z2 = bin_mode(bin_idx)>0;
   z2 = 1;
   
   if(bin_mode(bin_idx) == 0)
       rgb_color = [0.4 0.4 0.4];
   else
       rgb_color = bin_color(bin_mode(bin_idx),:);
   end
   
   draw_3D_wedge(r1,r2,0,z2,theta1,theta2,rgb_color);
end

hold off;


end

