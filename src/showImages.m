function showImages(Originals, Images, Thresholds)
    while true
        try 
            arg = input(['Type ''c'' to continue or input an image number ', ...
                         'to view (1 - ', num2str(length(Images)), ')> ']);
            if arg == 'c'
                break
            elseif isnumeric(arg)
                figure;

                subplot(1, 2, 1);
                imshow(Originals{arg});
                title('Original Image');

                subplot(1, 2, 2);
                imshow(Images{arg});
                title(['Thresholded Image'
                       'Threshold = ' num2str(Thresholds(arg))]);
            else
                error('Not a valid input');
            end
        catch err
            disp('Didn''t recognize that... trying again.');
        end
    end
end