search_dir = 'Training Set';
search_mask = [search_dir '\*.JPG'];
file_list = dir(search_mask);

ground_truth = cell(length(file_list));

for file_num=1:length(file_list)
    file_name = file_list(file_num).name;
    full_file_name = fullfile(search_dir,file_name);
    ground_truth{file_num}.file_name = file_name;
    ground_truth{file_num}.data = [];
    
    I = imread(full_file_name);
    h_im = imshow(I);
    e = imellipse(gca,[55 10 120 120]);
    e.setFixedAspectRatioMode('1'); % force circle
    ground_truth{file_num}.data = vertcat(ground_truth{file_num}.data, getPosition(e));
    e = e;
    
end


ball_data_ct_rad = cellfun(@(ball_data) [ball_data(:,1)+0.5*ball_data(:,3) ball_data(:,2)+0.5*ball_data(:,3) ball_data(:,3)], balls_GT);