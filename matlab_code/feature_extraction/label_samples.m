function [training_data] = label_samples(balls_GT, FV_DB, labeling_settings)

color_str = 'cm';
training_data = cell(size(balls_GT,1),1);

for img_num=1:size(balls_GT,1)
    training_data{img_num}.is_positive = [];
    training_data{img_num}.data = [];
%     training_data{img_num}.positive_data = [];
    training_data{img_num}.filename = FV_DB{img_num}.filename;
    
    if(labeling_settings.draw_best_match)
        imshow(FV_DB{img_num}.filename); hold all;
    end
    
    % (x0,y0,radius,measure)
    M = zeros(size(FV_DB{img_num}.feature_vectors,1), 4);
    M(:,1:3) = FV_DB{img_num}.feature_vectors;
    measure = zeros(size(FV_DB{img_num}.feature_vectors,1), size(balls_GT{img_num}.data,1));
    max_vals = [];
    
    % loop over labeled balls
    for ball_idx=1:size(balls_GT{img_num}.data,1)
        GT_rad = 0.5*balls_GT{img_num}.data(ball_idx,3);
        GT_x0 = balls_GT{img_num}.data(ball_idx,1) + GT_rad;
        GT_y0 = balls_GT{img_num}.data(ball_idx,2) + GT_rad;
        
        % find closest detected circle
        for detected_idx=1:size(FV_DB{img_num}.feature_vectors,1)
            Det_rad = FV_DB{img_num}.feature_vectors(detected_idx, 3);
            Det_x0 = FV_DB{img_num}.feature_vectors(detected_idx, 1);
            Det_y0 = FV_DB{img_num}.feature_vectors(detected_idx, 2);
            
            
            A = area_intersect_circle_analytical([[Det_x0;GT_x0] [Det_y0;GT_y0] [Det_rad;GT_rad]]);
            intersection_area = A(1,2);
            union_area = pi*Det_rad^2 + pi*GT_rad^2 - intersection_area;
            measure(detected_idx, ball_idx) = intersection_area / union_area;
        end
        
        [max_val, max_idx] = max(measure(:,ball_idx));
        if(max_val > labeling_settings.positive_label_th)
           training_data{img_num}.data = vertcat(training_data{img_num}.data, FV_DB{img_num}.feature_vectors(max_idx, :));
%            training_data{img_num}.positive_data =  vertcat(training_data{img_num}.positive_datass, FV_DB{img_num}.feature_vectors(max_idx, :));
           training_data{img_num}.is_positive = vertcat(training_data{img_num}.is_positive, 1);
        end
        
        max_vals = vertcat(max_vals, max_val); %#ok
        
        if(labeling_settings.draw_best_match)
            % draw circle
            max_x0 = M(max_idx,1);
            max_y0 = M(max_idx,2);
            max_rad = M(max_idx,3);
            theta=linspace(0,2*pi,100); % evenly spaced points between 0 and 2pi
            rho=ones(1,100)*max_rad;
            [Xn,Yn] = pol2cart(theta,rho);
            X = Xn+max_x0;
            Y = Yn+max_y0;
            plot(X,Y,color_str(ball_idx),'LineWidth',1);
        end
    end
    
    % label according to distance metric from labeled data
    max_measure = max(measure,[],2);
    is_negative_sample = bsxfun(@le, max_measure, labeling_settings.negative_label_th);
%     training_data{img_num}.negative_data = FV_DB{img_num}.feature_vectors(is_negative_sample,:);
    training_data{img_num}.data = vertcat(training_data{img_num}.data, FV_DB{img_num}.feature_vectors(is_negative_sample,:));
    training_data{img_num}.is_positive = vertcat(training_data{img_num}.is_positive, zeros(size(FV_DB{img_num}.feature_vectors(is_negative_sample,:),1),1));
    
    if(labeling_settings.draw_best_match)
        if(size(balls_GT{img_num}.data,1) == 1)
            legend(sprintf('score: %0.2f',max_vals(1)));
        else
            legend(sprintf('score: %0.2f',max_vals(1)), sprintf('score: %0.2f',max_vals(2)));
        end
        
        hold off;
        pause;
    end
    
end

end

