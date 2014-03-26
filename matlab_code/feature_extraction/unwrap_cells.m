function [training_samples] = unwrap_cells(training_data, feature0_idx)
%UNWRAP_CELLS converts training_data cell format to raw feature vectors
%   for each sample, the following information is stored
%   training_samples.cell_idx - which cell (training data image) the sample came from
%   training_samples.idx_within_cell - sample index within its training data image
%   training_samples.is_positive - negative or positive sample
%   training_samples.feature_data - feature vector

% input: training_data - in cell format, as calculated by
%                        Extract_Training_Features.m
%        feature0_idx - column index in training_data.data of first actual
%                       feature (ignoring circle coordinates and radius)

training_samples.cell_idx = [];
training_samples.idx_within_cell = [];
training_samples.is_positive = [];
training_samples.feature_data = [];

for img_num=1:length(training_data)
    num_samples = length(training_data{img_num}.is_positive);
    
    training_samples.idx_within_cell = vertcat(training_samples.idx_within_cell,(1:num_samples)');
    training_samples.is_positive = vertcat(training_samples.is_positive, training_data{img_num}.is_positive);
    training_samples.feature_data = vertcat(training_samples.feature_data, training_data{img_num}.data(:,feature0_idx:end));
    training_samples.cell_idx = vertcat(training_samples.cell_idx, img_num*ones(num_samples,1));
end

end

