function [feature_vectors] = scan_image(img_path, scan_settings)
%SCAN_IMAGE scans image and extracts features from circle-shaped regions
%   scan_settings - describes how to scan the region

t1 = tic;
[~, filename, ~] = fileparts(img_path);

if(scan_settings.draw_circles)
    numPoints=100; %Number of points making up the drawn circle
end

feature_vectors = [];

img = imread(img_path);

if(scan_settings.color_edge)
    %     imgBW = edge3ch(img,'Canny');
    for ch=1:3
        if(scan_settings.apply_histeq)
            img_ch = adapthisteq(img(:,:,ch));
            
            ch_edge(:,:,ch) = edge(img_ch,'Canny');
        else
            ch_edge(:,:,ch) = edge(img(:,:,ch),'Canny');
        end
    end
    imgBW = (ch_edge(:,:,1) | ch_edge(:,:,2) | ch_edge(:,:,3));
else
    % figure(1),imshow(img);
    img_gray = rgb2gray(img);
    % figure(2),imshow(img);
    if(scan_settings.apply_histeq)
        img_gray = adapthisteq(img_gray); % for dark images
        % figure(3),imshow(img);
    end

    imgBW = edge(img_gray,'Canny');
end

% figure(4); imshow(imgBW);

% if GT is available, extraction can be done directly from it
if(scan_settings.use_GT && ~isempty(scan_settings.GT))
    % find corresponding entry in the ground truth
    [~, fname, fext] = fileparts(img_path);
    is_GT_img = cellfun(@(Entry) strcmp(Entry.file_name,[fname fext]), scan_settings.GT);
    GT_img_idx = find(is_GT_img);
    % extract features from region specified in ground truth
    for ball_idx=1:size(scan_settings.GT{GT_img_idx}.data,1)
        GT_r = 0.5*scan_settings.GT{GT_img_idx}.data(ball_idx,3);
        GT_x0 = scan_settings.GT{GT_img_idx}.data(ball_idx,1) + GT_r;
        GT_y0 = scan_settings.GT{GT_img_idx}.data(ball_idx,2) + GT_r;
        feature_vectors = vertcat(feature_vectors, [GT_x0 GT_y0 GT_r]);
    end
end

% find all circles with radii in the specified range
for rad=scan_settings.radius_range
    [y0detect,x0detect,Accumulator] = houghcircle(imgBW,rad,...
                                                  scan_settings.circle_detection_th*2*pi*rad,...
                                                  [1,1,size(imgBW,2),size(imgBW,1)], ...
                                                  scan_settings.suppression_alpha);
    
    feature_vectors = vertcat(feature_vectors, [x0detect y0detect repmat(rad,[size(x0detect,1) 1])]);
    fprintf('radius=%d, number of detected circles: %d\n', rad, length(y0detect));
    
    if(scan_settings.draw_circles)
        imshow(img);
        title(sprintf('%s - detection radius: %d (found %d)', filename, rad, length(y0detect)));
        
        if(isempty(x0detect))
            pause(0.1);
        else
            hold all;
            %Define circle in polar coordinates (angle and radius)
            theta=linspace(0,2*pi,numPoints); % evenly spaced points between 0 and 2pi
            rho=ones(1,numPoints)*rad;
            
            %Convert polar coordinates to Cartesian for plotting
            [X0,Y0] = pol2cart(theta,rho);
            
            for circle_num=1:length(x0detect)
                X = X0+x0detect(circle_num);
                Y = Y0+y0detect(circle_num);
                plot(X,Y,'c','LineWidth',1);
            end
            
            hold off;
            pause;
        end
        
    end
    
end

t2 = toc(t1);
fprintf('total scan time: %3.2f\n', t2);

end
