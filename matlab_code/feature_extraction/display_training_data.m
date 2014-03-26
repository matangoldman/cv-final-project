function display_training_data(training_data)

for img_num=1:length(training_data)
    imshow(training_data{img_num}.filename); hold all;
    title(sprintf('%s', training_data{img_num}.filename), 'Interpreter', 'none');
    pause;
    
    title(sprintf('%s: positive: %d. negative: %d', ...
          training_data{img_num}.filename, sum(training_data{img_num}.is_positive), sum(~training_data{img_num}.is_positive)),...
          'Interpreter', 'none');
    
    for sample_idx=1:size(training_data{img_num}.data,1)
        x0 = training_data{img_num}.data(sample_idx,1);
        y0 = training_data{img_num}.data(sample_idx,2);
        rad = training_data{img_num}.data(sample_idx,3);
        theta=linspace(0,2*pi,100); % evenly spaced points between 0 and 2pi
        rho=ones(1,100)*rad;
        [Xn,Yn] = pol2cart(theta,rho);
        X = Xn+x0;
        Y = Yn+y0;
        
        if(training_data{img_num}.is_positive(sample_idx))
            plot(X,Y,'g','LineWidth',2);
        else
            plot(X,Y,'c','LineWidth',1);
        end
    end
    
    hold off;
    pause;
end


end

