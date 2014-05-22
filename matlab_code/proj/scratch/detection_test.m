color_hist_path       = 'sample_hs_histograms.mat';     % for color features
gradients_hist_path   = 'grads_hists.mat';     % for color features
texture_matrices_path = 'sample_comatrices.mat'; % for texture features
classifier_path       = 'balls_classifier_data.mat'; % features data

balls_path  = '..\ball';
result_path = '..\results';
img_path = dir([balls_path '\*.jpg']);

overlap_th = 0.1;
detection_results = cell(size(img_path,1));

% hough scaling / scanning parameters
scaling_factor = [1 1 2 2 2 3];
min_radius = [20 41 28 40 55 46];
max_radius = [40 65 40 55 72 67];

num_of_candidates = 40;

T0 = tic;
for img_ind = 1:size(img_path,1)
% for img_ind = 16
% for img_ind = 23
    T0_Img = tic;
    
    fprintf('processing %s... ', img_path(img_ind).name);
    [img_directory, img_name, img_ext] = fileparts(img_path(img_ind).name);
    
    % load detector
    [balls_detector] = load_detector(color_hist_path, gradients_hist_path, texture_matrices_path, classifier_path,...
        [balls_path '\' img_path(img_ind).name]);
    
    % load image
    I = imread([balls_path '\' img_path(img_ind).name]);
    % convert to hsv (detector's colorspace)
    I_hsv = rgb2hsv(I);
    
    sensitivity = 1;
    valid_mat = [];
    
    for ind=1:size(scaling_factor,2)
        radius_range = [min_radius(ind) max_radius(ind)];
        
        I_scaled = imresize(I,1/scaling_factor(ind));
        Ie_scaled = edge(I_scaled(:,:,1),'canny') | edge(I_scaled(:,:,2),'canny');
        
        [centers,radius,metric] = imfindcircles(Ie_scaled,radius_range,...
            'Sensitivity',sensitivity,'ObjectPolarity','bright','EdgeThreshold',0.1);
        
        best_centers = vertcat(centers(1:num_of_candidates,:),[]);
        best_radius  = vertcat(radius(1:num_of_candidates),[]);
        best_metric  = vertcat(metric(1:num_of_candidates),[]);
        
        %round and arrange the circles
        rad = round(best_radius);
        x = round(best_centers(:, 1));
        y = round(best_centers(:, 2));
        
        %remove circles that goes out of the image
        mask_vec = (y + rad < size(Ie_scaled,1) & y-rad > 0 & x+rad < size(Ie_scaled,2) & x-rad > 0);
        x = x(mask_vec);
        y = y(mask_vec);
        rad = rad(mask_vec);
        metric = best_metric(mask_vec);
        
        %grade every x,y,r using the detector
        detection_mat = zeros(size(I,1), size(I,2));
        valid_candidates = false(size(x));
        
        %descale x and y and rad;
        x = x.*scaling_factor(ind);
        y = y.*scaling_factor(ind);
        rad = rad.*scaling_factor(ind);
        for ind2=1:size(x);
            detector_grade = classify_region(balls_detector,I_hsv,x(ind2),y(ind2),rad(ind2));
%             fprintf('img_ind=%d,ind=%d,ind2=%d,detector_grade=%d\n',img_ind,ind,ind2,detector_grade);
            if (detector_grade > 0)
                valid_mat = vertcat(valid_mat ,[x(ind2) y(ind2) rad(ind2) detector_grade metric(ind2)]);
            end
        end
    end
    %%
    %use the detector for each one of the candidate circles
    
    f = figure(img_ind);
    imshow(I);
    hold on;
    
    % cluster detected balls
    if(~isempty(valid_mat))
        [circle_labels, num_clusters] = label_circles(valid_mat(:,1:3), overlap_th);

        hsv_colors = [(linspace(1/num_clusters, 1, num_clusters))' ones(num_clusters,1) ones(num_clusters,1)];
        rgb_colors = hsv2rgb(hsv_colors);

        for cluster_idx=1:num_clusters
            cluster_circle_indeces = find(circle_labels == cluster_idx);
            cluster_circles = valid_mat(cluster_circle_indeces,:);
            % display all detected circles
%             viscircles(cluster_circles(:,1:2), cluster_circles(:,3), 'EdgeColor', rgb_colors(cluster_idx,:));

            % detection weights
            weight_det = cluster_circles(:,4)/sum(cluster_circles(:,4));
            weight_hough = cluster_circles(:,5)/sum(cluster_circles(:,5));
%             circ_weight = weight_det.*weight_hough;
            circ_weight = weight_det;

            % best circle in the cluster
            [~,best_circle_idx] = max(circ_weight); % top scoring circle
            viscircles(cluster_circles(best_circle_idx,1:2), cluster_circles(best_circle_idx,3), 'EdgeColor', 'c');

            % average circle
%             avg_circle = sum((cluster_circles(:,1:3).*repmat(circ_weight,[1 3])), 1)/sum(circ_weight);
%             viscircles(avg_circle(1:2), avg_circle(3), 'EdgeColor', 'w');
        end
    end
    
    hold off;
    print(f, '-dbmp', [result_path '\' img_name '.bmp']);
    close(f);
    
    DT_Img = toc(T0_Img);
    fprintf('(time: %2.1f)\n', DT_Img);
    
end %img_ind
DT = toc(T0);
fprintf('total time: %2.2f [minutes]\n', DT/60);
