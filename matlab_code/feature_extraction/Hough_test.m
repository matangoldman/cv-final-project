close all;

img_file = '..\Training Set\MVC-023F.JPG'; % fails with rad=330:10:400!, th=0.2*rad*pi
% img_file = 'Training Set\MVC-019F.JPG';
% img_file = 'Training Set\MVC-001F.JPG';

img = imread(img_file);
figure(1),imshow(img);
img = rgb2gray(img);
figure(2),imshow(img);
img = adapthisteq(img); % for dark images
figure(3),imshow(img);
imgBW = edge(img,'Canny');
% rad = 24;
numPoints=100; %Number of points making up the drawn circle

figure(4);
imshow(imgBW);
Total_circles = 0;
% for rad=20:10:120
for rad=140:10:200
    [y0detect,x0detect,Accumulator] = houghcircle(imgBW,rad,0.5*rad*pi);
    Total_circles=Total_circles+length(y0detect);
    % figure;
    % imagesc(Accumulator);

    %Define circle in polar coordinates (angle and radius)
    theta=linspace(0,2*pi,numPoints); %100 evenly spaced points between 0 and 2pi
    rho=ones(1,numPoints)*rad; %Radius should be 1 for all 100 points

    %Convert polar coordinates to Cartesian for plotting
    [X0,Y0] = pol2cart(theta,rho); 

    hold on;
    for circle_num=1:length(x0detect)
        X = X0+x0detect(circle_num);
        Y = Y0+y0detect(circle_num);
        plot(X,Y,'m','LineWidth',1);
    end

end

hold off;
Total_circles