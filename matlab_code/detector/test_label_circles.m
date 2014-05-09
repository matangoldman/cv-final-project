addpath('..\feature_extraction');
overlap_th = eps;
% overlap_th = 0.1;
% circ_list = [ ...
%     [0 0 40]; ...
%     [0 20 30]; ...
%     [20 15 20]; ...
%     [0 0 8]; ...
%     [75 0 30]; ...
%     [80 10 30]; ...
%     [100 100 10]; ...
% %     [80 66 35];
%     [80 64 35];
%     ];

N = 50;
circ_list = [(rand(N,1)-0.5), (rand(N,1)-0.5), 0.1*rand(N,1)];

% plot all circles
% figure(1);
% viscircles(circ_list(:,1:2), circ_list(:,3));
% axis image;

[circle_labels, num_clusters] = label_circles(circ_list, overlap_th);

% plot clustered circles
figure(2);
hold on;
hsv_colors = [(linspace(1/num_clusters, 1, num_clusters))' ones(num_clusters,1) ones(num_clusters,1)];
rgb_colors = hsv2rgb(hsv_colors);

for cluster_idx=1:num_clusters
    cluster_circles = find(circle_labels == cluster_idx);
    viscircles(circ_list(cluster_circles,1:2), circ_list(cluster_circles,3), 'EdgeColor', rgb_colors(cluster_idx,:));
end

axis image;
hold off;
