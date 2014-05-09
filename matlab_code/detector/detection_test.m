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

T0 = tic;
for img_ind = 1:size(img_path,1)
% for img_ind = 1:2
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
    
    rad = [20 25 35 50 70 95 125 160 200];
    min_radius = rad(1:end-1);
    max_radius = rad(2:end);
    
%     radius_step = 40;
%     min_radius = 20:radius_step:200;
%     max_radius = min_radius+radius_step;

%     radius_step = 2;
%     min_radius = 50:radius_step:60;
%     max_radius = min_radius+radius_step;
    
    % edges image: edges in red/green channels
%     Ie = edge(I(:,:,1),'canny') | edge(I(:,:,2),'canny');
    Ie = edge(I(:,:,1),'canny') | edge(I(:,:,2),'canny');
    sensitivity = 1;
    valid_mat = [];
    
    for ind=1:size(min_radius,2)
        radius_range = [min_radius(ind) max_radius(ind)];
%         [centers,radius,metric] = imfindcircles(I,radius_range,...
%             'Sensitivity',sensitivity,'ObjectPolarity','bright','EdgeThreshold',0.1);
%         [centers2,radius2,metric2] = imfindcircles(I,radius_range,...
%             'Sensitivity',sensitivity,'ObjectPolarity','dark','EdgeThreshold',0.1);
        [centers,radius,metric] = imfindcircles(Ie,radius_range,...
            'Sensitivity',sensitivity,'ObjectPolarity','bright','EdgeThreshold',0.1);
        
        %merge and sort bright and dark
        num_of_candidates = 50;
%         best_centers = vertcat(centers(1:num_of_candidates,:),centers2(1:num_of_candidates,:));
%         best_radius  = vertcat(radius(1:num_of_candidates),radius2(1:num_of_candidates));
%         best_metric  = vertcat(metric(1:num_of_candidates),metric2(1:num_of_candidates));

        best_centers = vertcat(centers(1:num_of_candidates,:),[]);
        best_radius  = vertcat(radius(1:num_of_candidates),[]);
        best_metric  = vertcat(metric(1:num_of_candidates),[]);
        
%         imshow(I);
%         viscircles(best_centers, best_radius,'EdgeColor','b');
%         title(sprintf('radius range: %d-%d', min_radius(ind),max_radius(ind)));
%         pause;
        
        
        %round and arrange the circles
        rad = round(best_radius);
        x = round(best_centers(:, 1));
        y = round(best_centers(:, 2));
        
        %remove circles that goes out of the image
        mask_vec = (y + rad < 480 & y-rad > 0 & x+rad < 640 & x-rad > 0);
        x = x(mask_vec);
        y = y(mask_vec);
        rad = rad(mask_vec);
        metric = best_metric(mask_vec);
        
        %grade every x,y,r using the detector
        detection_mat = zeros(size(I,1), size(I,2));
        valid_candidates = false(size(x));
        for ind2=1:size(x);
            detector_grade = classify_region(balls_detector,I_hsv,x(ind2),y(ind2),rad(ind2));
            fprintf('img_ind=%d,ind=%d,ind2=%d,detector_grade=%d\n',img_ind,ind,ind2,detector_grade);
            if (detector_grade > 0)
                valid_mat = vertcat(valid_mat ,[x(ind2) y(ind2) rad(ind2) detector_grade metric(ind2)]);
            end
        end
    end
    % draw_circle(x_sum/grade_sum,y_sum/grade_sum,rad,'c');
    %draw_circle(x_sum/det_count,y_sum/det_count,rad,'c');
%     hold off;
    
    
    %%
    %use the detector for each one of the candidate circles
    
    
%     subplot(5,5,img_ind);
    figure(img_ind);
    imshow(I);
    hold on;
    
    % cluster detected balls
    [circle_labels, num_clusters] = label_circles(valid_mat(:,1:3), overlap_th);
    
    hsv_colors = [(linspace(1/num_clusters, 1, num_clusters))' ones(num_clusters,1) ones(num_clusters,1)];
    rgb_colors = hsv2rgb(hsv_colors);

    for cluster_idx=1:num_clusters
        cluster_circle_indeces = find(circle_labels == cluster_idx);
        cluster_circles = valid_mat(cluster_circle_indeces,:);
        viscircles(cluster_circles(:,1:2), cluster_circles(:,3), 'EdgeColor', rgb_colors(cluster_idx,:));
        
        % detection weights
        weight_det = cluster_circles(:,4)/sum(cluster_circles(:,4));
        weight_hough = cluster_circles(:,5)/sum(cluster_circles(:,5));
        circ_weight = weight_det.*weight_hough;
        
        % best circle in the cluster
        [~,best_circle_idx] = max(circ_weight); % top scoring circle
        viscircles(cluster_circles(best_circle_idx,1:2), cluster_circles(best_circle_idx,3), 'EdgeColor', 'k');
        
        % average circle
        avg_circle = sum((cluster_circles(:,1:3).*repmat(circ_weight,[1 3])), 1)/sum(circ_weight);
        viscircles(avg_circle(1:2), avg_circle(3), 'EdgeColor', 'w');
    end
    
    hold off;
    
%     %sort the valid matrix
%     %draw the "best" match
%     if size(valid_mat,2)>0
%         detection_results{img_ind} = valid_mat;
%         valid_mat = flipud(sortrows(valid_mat,4));
%         viscircles(valid_mat(1,1:2), valid_mat(1,3),'EdgeColor','r');
%     end
%     
%     %draw the rest
%     if size(valid_mat,2)>1
%         viscircles(valid_mat(2:end,1:2), valid_mat(2:end,3),'EdgeColor','b');
%     end
    
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
