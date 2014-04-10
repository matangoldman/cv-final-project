addpath C:\Users\Arie\Downloads\mexopencv-master\mexopencv-master

min_rad = 20;
max_rad = 60;
I = imread('Training Set\MVC-003F.jpg');
% imshow(I);

circles = cv.HoughCircles(rgb2gray(I), ...
                          'MinRadius', min_rad, 'MaxRadius', max_rad, 'MinDist', 10, ...
                          'Param2', 20);


imshow(I);
hold on;
cellfun(@(X) draw_circle(X(1), X(2), X(3)), circles);
hold off;
