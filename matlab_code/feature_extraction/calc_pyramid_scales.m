function [pyramids_metadata] = calc_pyramid_scales(max_scale, min_scale, spacing)

requires_scales = min_scale:spacing:max_scale;
num_pyramids = 0;
pyramids_metadata = [];

while ~isempty(requires_scales)
    num_pyramids = num_pyramids+1;
    pyramids_metadata(num_pyramids).initial_scale = pyramids_metadata(end);
    pyramids_metadata(end) = [];
    
end

end

