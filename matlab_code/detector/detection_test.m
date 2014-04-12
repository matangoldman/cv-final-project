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



for img_ind = 1:size(img_path)
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

    min_radius = 25:25:200;
    max_radius = min_radius+25;
    sensitivity = 1;
    valid_mat = [];
for ind=1:size(min_radius,2)
    radius_range = [min_radius(ind) max_radius(ind)];
    [centers,radius,metric] = imfindcircles(I,radius_range,...
        'Sensitivity',sensitivity,'ObjectPolarity','dark');
    
%     figure(1);
%     imshow(I);
%     viscircles(centers(1:100,:), radius(1:100),'EdgeColor','b');
%     pause;

    
    %leave only the X best circles
    num_of_candidates = 50;
    rad = round(radius(1:num_of_candidates));
    x = round(centers(1:num_of_candidates, 1));
    y = round(centers(1:num_of_candidates, 2));
    
    %remove circles that goes out of the image
    mask_vec = (y + rad < 480 & y-rad > 0 & x+rad < 640 & x-rad > 0);
    x = x(mask_vec);
    y = y(mask_vec);
    
    %grade every x,y,r using the detector
    detection_mat = zeros(size(I,1), size(I,2));
    valid_candidates = false(size(x));
    for ind2=1:size(x);
       temp = classify_region(balls_detector,I_hsv,x(ind2),y(ind2),rad(ind2));    
       fprintf('ind=%d,ind2=%d,temp=%d\n',ind,ind2,temp);
       if (temp > 0)
           valid_mat = vertcat(valid_mat ,[x(ind2) y(ind2) rad(ind2) temp]);
       end
    end
end
% draw_circle(x_sum/grade_sum,y_sum/grade_sum,rad,'c');
%draw_circle(x_sum/det_count,y_sum/det_count,rad,'c');
hold off;


%%
%use the detector for each one of the candidate circles

subplot(5,5,img_ind);
imshow(detection_mat,[]); colormap hot;
hold on;
imshow(I);
%sort the valid matrix
valid_mat = flipud(sortrows(valid_mat,4));
viscircles(valid_mat(1:1,1:2), valid_mat(1:1,3),'EdgeColor','b');

end %img_ind




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
