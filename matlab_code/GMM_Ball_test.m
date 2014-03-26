close all;
img_file = 'Training Set\MVC-019F.JPG';
% img_file = 'Training Set\MVC-012F.JPG';
I = imread(img_file);
Num_modes = 3;
color_map_size = [500 500];

% % mark ball region
h_im = imshow(I);
e = imellipse(gca,[55 10 120 120]);
e.setFixedAspectRatioMode('1'); % force circle
BW = createMask(e,h_im);

% each pixel in marked roi is a row in I_pix_mat
mask = cat(3,BW,BW,BW);
I_pix = I(mask);
I_pix_mat = reshape(I_pix,[length(I_pix)/3 3]);

% cluster using kmeans and find statistics
kmeans_idx = kmeans(double(I_pix_mat),Num_modes);
for c=1:Num_modes
   color_idx = find(kmeans_idx==c);
   I_color_pix = I_pix_mat(color_idx,:);
   mu_colors(c,:) = mean(I_color_pix);
end

% estimate GMM parameters, use kmeans as initial guess
options = statset('Display','final','MaxIter',200);
obj = gmdistribution.fit(double(I_pix_mat),Num_modes,'Options',options,'Start',kmeans_idx);
mu_colors_GMM = uint8(obj.mu);

% display mean colors
% for c=1:Num_modes
% % 	mu = mu_colors(c,:);
%     mu = mu_colors_GMM(c,:);
%     mu = reshape(mu,[1 1 3]);
%     I_c = repmat(mu,[color_map_size 1]);
%     figure,imshow(I_c);
%     pause;
% end

% sample points from each mode
for c=1:Num_modes
    rand_pix = mvnrnd(obj.mu(c,:),obj.Sigma(:,:,c),prod(color_map_size));
    rand_pix = (rand_pix>255).*255 + (rand_pix<0).*0 + (rand_pix>=0 & rand_pix<=255).*rand_pix;
    rand_pix_hsv = rgb2hsv(rand_pix);
    rand_pix_hsv_sorted = sortrows(rand_pix_hsv,[-1 -3 2]);
    rand_pix = hsv2rgb(rand_pix_hsv_sorted);
    I_c = reshape(rand_pix,[color_map_size 3]);
    figure,imshow(uint8(I_c));
    pause;
end