addpath '..\feature_extraction';
addpath '..\color_model';

color_hist_path       = '..\color_model\sample_hs_histograms.mat';     % for color features
gradients_hist_path   = '..\feature_extraction\grads_hists.mat';     % for color features
texture_matrices_path = '..\feature_extraction\sample_comatrices.mat'; % for texture features
classifier_path       = 'balls_classifier_data.mat'; % features data
addpath '..\';
% img_path = '..\Training Set\MVC-001F.JPG'; % test image
% img_path = '..\Training Set\MVC-004F.JPG'; % test image
% img_path = '..\Training Set\MVC-023F.JPG'; % test image

img_path = dir('..\Training Set\*.jpg');
%img_path = img_path(11);

overlap_th = 0.1;
detection_results = cell(size(img_path,1));

% hough scaling / scanning parameters
% scaling_factor = [1 2 2.5];
% min_radius = [20 30 46];
% max_radius = [60 70 67];

% scaling_factor = [1 1 2 2 2.5 2.5];
% min_radius = [20 50 40 55 56 68];
% max_radius = [50 80 55 70 68 80];

% scaling_factor = [1 1 2 2 2 3];
% min_radius = [20 40 30 40 55 46];
% max_radius = [40 60 40 55 70 67];

scaling_factor = [1 1 2 2 2 3];
min_radius = [20 41 28 40 55 46];
max_radius = [40 65 40 55 72 67];

T0 = tic;
for img_ind = 1:size(img_path,1)
% for img_ind = 19
% for img_ind = 1:25
% for img_ind = 19
    % load detector
    [balls_detector] = load_detector(color_hist_path, gradients_hist_path, texture_matrices_path, classifier_path,...
        ['..\Training Set\' img_path(img_ind).name]);
    
    % load image
    I = imread(['..\Training Set\' img_path(img_ind).name]);
    % imshow(I);
    % convert to hsv (detector's colorspace)
    I_hsv = rgb2hsv(I);
    %%
    % use hough transform to find candidate circles in the image
%     min_radius =  (5:2:14).^2;
%     max_radius =  (7:2:16).^2;
    %     min_radius = 20:10:200;
    %     max_radius = 30:10:210;
    
    %changing the radius every iteration
    %rad = [20 25 35 50 70 95 125 160 200];
    %min_radius = rad(1:end-1);
    %max_radius = rad(2:end);
    
    %changing the scaling factor and mainttaing constant radius
%     scaling_factor = 5:-1:1;
%     min_radius = 20;
%     max_radius = 40;
    
    
    
%     radius_step = 40;
%     min_radius = 20:radius_step:200;
%     max_radius = min_radius+radius_step;

%     radius_step = 2;
%     min_radius = 50:radius_step:60;
%     max_radius = min_radius+radius_step;
    
    % edges image: edges in red/green channels
%     Ie = edge(I(:,:,1),'canny') | edge(I(:,:,2),'canny');
    
    
    sensitivity = 1;
    valid_mat = [];
    
    for ind=1:size(scaling_factor,2)
        radius_range = [min_radius(ind) max_radius(ind)];
%         [centers,radius,metric] = imfindcircles(I,radius_range,...
%             'Sensitivity',sensitivity,'ObjectPolarity','bright','EdgeThreshold',0.1);
%         [centers2,radius2,metric2] = imfindcircles(I,radius_range,...
%             'Sensitivity',sensitivity,'ObjectPolarity','dark','EdgeThreshold',0.1);
%         T_HOUGH = tic;
%         Ie_scaled = imresize(Ie,1/scaling_factor(ind));
        
        I_scaled = imresize(I,1/scaling_factor(ind));
        Ie_scaled = edge(I_scaled(:,:,1),'canny') | edge(I_scaled(:,:,2),'canny');
        
        [centers,radius,metric] = imfindcircles(Ie_scaled,radius_range,...
            'Sensitivity',sensitivity,'ObjectPolarity','bright','EdgeThreshold',0.1);
%         DT_hough(ind) = toc(T_HOUGH);
        
        %merge and sort bright and dark
        num_of_candidates = 50;
%         best_centers = vertcat(centers(1:num_of_candidates,:),centers2(1:num_of_candidates,:));
%         best_radius  = vertcat(radius(1:num_of_candidates),radius2(1:num_of_candidates));
%         best_metric  = vertcat(metric(1:num_of_candidates),metric2(1:num_of_candidates));

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
        
%         imshow(I);
%         viscircles([x y], rad,'EdgeColor','b');
%         title(sprintf('radius range: %d-%d', min_radius(ind),max_radius(ind)));
%         pause;
        
        %grade every x,y,r using the detector
        detection_mat = zeros(size(I,1), size(I,2));
        valid_candidates = false(size(x));
        
        %descale x and y and rad;
        x = round(x.*scaling_factor(ind));
        y = round(y.*scaling_factor(ind));
        rad = round(rad.*scaling_factor(ind));
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
    
    figure(img_ind);
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
%             viscircles(cluster_circles(:,1:2), cluster_circles(:,3), 'EdgeColor', rgb_colors(cluster_idx,:));

            % detection weights
            weight_det = cluster_circles(:,4)/sum(cluster_circles(:,4));
            weight_hough = cluster_circles(:,5)/sum(cluster_circles(:,5));
%             circ_weight = weight_det.*weight_hough;
            circ_weight = weight_det;

            % best circle in the cluster
            [~,best_circle_idx] = max(circ_weight); % top scoring circle
            viscircles(cluster_circles(best_circle_idx,1:2), cluster_circles(best_circle_idx,3), 'EdgeColor', 'k');

            % average circle
%             avg_circle = sum((cluster_circles(:,1:3).*repmat(circ_weight,[1 3])), 1)/sum(circ_weight);
%             viscircles(avg_circle(1:2), avg_circle(3), 'EdgeColor', 'w');
        end
    end
    
    hold off;
    
end %img_ind
DT = toc(T0);
save('detection_res.mat', 'detection_results');


%%
% scan entire image
% rad = 50;
% x_step = 10;
% y_step = 10;
% detection_mat = zeros(size(I,1), size(I,2));
% for y=1:y_step:size(I,1)
%     for x=1:x_step:size(I,2)
%        detection_mat(y,x) = classify_region(balls_detector,I_hsv,x,y,rad);
%     end
%
%     fprintf('y=%d\n',y);
% end
%
% imshow(detection_mat,[]); colormap hot;
