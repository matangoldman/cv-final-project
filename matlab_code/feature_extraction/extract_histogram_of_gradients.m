load('training_data.mat');
addpath '..\'
close all;

% first of all - copy image name
for img_num=1:length(training_data)
    [dir,file,ext] = fileparts(training_data{img_num}.filename);
    grads_hists(img_num).file_name = [file,ext];
end


for img_num=1:length(training_data)
    grads_hists(img_num).data = cell(0);
    
    pos_idx = find(training_data{img_num}.is_positive);
    
    x0_vec = training_data{img_num}.data(pos_idx,1);
    y0_vec = training_data{img_num}.data(pos_idx,2);
    r_vec = training_data{img_num}.data(pos_idx,3);
    
    I = imread(training_data{img_num}.filename);
    I_hsv = rgb2hsv(I);
    
    for samp_num=1:length(pos_idx)
        x0 = x0_vec(samp_num);
        y0 = y0_vec(samp_num);
        r = r_vec(samp_num);
        
        g_hist = extract_region_grads_hist(x0,y0,r,I_hsv);
        
        grads_hists(img_num).data{end+1} = g_hist;
        
%         imshow(I);
%         hold on;
%         draw_circle(x0,y0,r);
%         hold off;
%         pause;
    end
    
end

save('grads_hists.mat', 'grads_hists');