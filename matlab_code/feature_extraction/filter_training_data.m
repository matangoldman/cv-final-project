function [out_training_data] = filter_training_data(training_data, training_samples, feature0_idx, feature_idx, feature_th, feature_polarity)
%FILTER_TRAINING_DATA filter out samples from training data

% out_training_data = training_data;

filter_sample = feature_polarity*training_samples.feature_data(:,feature_idx) < feature_polarity*feature_th;
cell_idx=training_samples.cell_idx(~filter_sample);
idx_within_cell = training_samples.idx_within_cell(~filter_sample);

% first of all - copy file names
out_training_data = cell(size(training_data));
for img_num=1:length(training_data)
    out_training_data{img_num}.filename = training_data{img_num}.filename;
    out_training_data{img_num}.is_positive = [];
    out_training_data{img_num}.data = [];
end

for sample_num=1:length(cell_idx)
    cell_num = cell_idx(sample_num);
    circle_idx = idx_within_cell(sample_num);
    out_training_data{cell_num}.data = vertcat(out_training_data{cell_num}.data, training_data{cell_num}.data(circle_idx,:));
    out_training_data{cell_num}.is_positive = vertcat(out_training_data{cell_num}.is_positive, training_data{cell_num}.is_positive(circle_idx));
end

end

