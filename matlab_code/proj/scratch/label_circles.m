function [circle_labels, num_clusters] = label_circles(circles, overlap_th)
%LABEL_CIRCLES connected components labeling for list of circles
%   circles: each row is a circle, in format: [center_x, center_y, radius]
%   overlap_th: circle pairs are considered as connected if their overlap
%       measure is larger than overlap_th, where:
%       overlap measure = intersection_area/min_area
%   circle_labels: connected component label for each circle
%   num_clusters:  number of circle clusters

connection_list = [];
num_circles = size(circles,1);

% calc overlap measure between all pairs of circles
% overlap measure = intersection_area / min_area
A = area_intersect_circle_analytical(circles);
intersection_area = A;
circ_area = diag(A);
circ_area_mat1 = repmat(circ_area, [1 num_circles]);
circ_area_mat2 = circ_area_mat1';
min_area = min(cat(3,circ_area_mat1,circ_area_mat2),[],3);
overlap_measure = intersection_area ./ min_area;

circ_has_connections = false(num_circles,1);

% pairs of circles for which the overlap measure is higher than
% the overlap threshold are "connected in the graph"
for circ_i=1:num_circles
    found_connections = false;
    for circ_j=circ_i+1:num_circles
        if(overlap_measure(circ_i,circ_j) >= overlap_th)
            connection_list = vertcat(connection_list, [circ_i circ_j]);
            circ_has_connections(circ_i) = true;
            circ_has_connections(circ_j) = true;
        end
    end
    if(~circ_has_connections(circ_i))
        connection_list = vertcat(connection_list, [circ_i circ_i]);
    end
end

% cluster connected circles
circ_graph = sparse( connection_list(:,1), connection_list(:,2), 1, max(connection_list(:)), max(connection_list(:)) );
circ_graph = circ_graph + circ_graph.'; %' make graph undirected
[num_clusters, circle_labels] = graphconncomp(circ_graph);

end
