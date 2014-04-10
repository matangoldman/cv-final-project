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
img_path = '..\Training Set\MVC-009F.JPG'; % test image

% load detector
[balls_detector] = load_detector(color_hist_path, gradients_hist_path, texture_matrices_path, classifier_path, img_path);

% load image
I = imread(img_path);
% imshow(I);
% convert to hsv (detector's colorspace)
I_hsv = rgb2hsv(I);

% ball position
x0 = 350; y0 = 240; r = 60;
[detection_grade] = classify_region(balls_detector,I_hsv,x0,y0,r);

% some false position
x0 = 150; y0 = 100; r = 60;
[detection_grade] = classify_region(balls_detector,I_hsv,x0,y0,r);


% scan entire image
rad = 50;
x_step = 10;
y_step = 10;
detection_mat = zeros(size(I,1), size(I,2));
figure, imshow(I);
hold on;
x_sum = 0;
y_sum = 0;
det_count = 0;
grade_sum = 0;
for y=1:y_step:size(I,1)
    for x=1:x_step:size(I,2)
       detection_mat(y,x) = classify_region(balls_detector,I_hsv,x,y,rad); 
       
       if(detection_mat(y,x) > 0)
           draw_circle(x,y,rad);
           x_sum = x_sum+x;
           y_sum = y_sum+y;
           det_count = det_count+1;

%            x_sum = x_sum+x*detection_mat(y,x);
%            y_sum = y_sum+y*detection_mat(y,x);
%            grade_sum = grade_sum + detection_mat(y,x);
       end
    end
    
    fprintf('y=%d\n',y);
end
% draw_circle(x_sum/grade_sum,y_sum/grade_sum,rad,'c');
draw_circle(x_sum/det_count,y_sum/det_count,rad,'c');
hold off;

% imshow(detection_mat,[]); colormap hot;
