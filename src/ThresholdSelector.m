classdef ThresholdSelector < handle
    
    properties
        Thresholds % Vector mapping from slice index to threshold
        imageSeries % ComstatImageSeries instance (not saved) DELETE
        numSamples % number of samples taken to determine thresholds
        adaptiveThresholding % true if the threshold changes down the stack
    end
    
    properties (Dependent)
        averageThreshold
    end

    methods
        function obj = ThresholdSelector(numSamples)
            if nargin == 0, numSamples = 5; end
            
            obj.numSamples = numSamples;
        end
        
        function selectManually(obj, imageSeries)
            obj.adaptiveThresholding = true;
            
            [SampleIndices SampleImages] = obj.selectSamples(imageSeries);
            
            %figure;
            SampleThresholds = zeros(1, obj.numSamples);
            for i = 1:obj.numSamples
                SampleThresholds(i) = ...
                    obj.findManualThreshold(SampleIndices(i), SampleImages{i});
            end
            
            obj.interpSamples(imageSeries, SampleIndices, SampleThresholds);
        end
        
        function selectAverage(obj, imageSeries, otherSelector)
            obj.adaptiveThresholding = false;
            
            obj.Thresholds = otherSelector.averageThreshold * ...
                             ones(1, imageSeries.numImages);
        end
        
        function avg = get.averageThreshold(obj)
            avg = mean(obj.Thresholds);
        end
        
        function plot(obj, style)
            plot(1:length(obj.Thresholds), obj.Thresholds, style);
        end
        
        function releaseImages(obj)
            obj.imageSeries = [];
        end
              
        function Images = apply(obj, imageSeries)
            Images = cell(1, imageSeries.numImages);
            for i = 1 : imageSeries.numImages
                Images{i} = im2bw(imageSeries.Images{i}, obj.Thresholds(i));
            end
        end
        
    end
    
    methods (Hidden)
        function [Indices Images] = selectSamples(obj, imageSeries)
            Indices = round(linspace(1, imageSeries.numImages, ...
                            obj.numSamples));
            Images = cell(1, obj.numSamples);
            for i = 1 : obj.numSamples
                Images{i} = imageSeries.Images{Indices(i)};
            end
        end
        
        function interpSamples(obj, imageSeries, Indices, Thresholds)
            obj.Thresholds = interp1(Indices, Thresholds, ...
                                     1:imageSeries.numImages);
        end
        
        function threshold = findManualThreshold(obj, index, Image)
            disp(['Determine threshold for image ' num2str(index) '...']);
            threshold = 0.5; % guess randomly here.

            while true
                subplot(1, 2, 1);
                imshow(Image);
                title('Original Image');

                subplot(1, 2, 2);
                imshow(im2bw(Image, threshold));
                title(['Threshold = ' num2str(threshold)]);

                disp(['Current threshold is ' num2str(threshold)]);

                try 
                    in = input(['Input a threshold value (from 0.0 to 1.0)', ...
                                ' or type ''a'' to accept the current ', ...
                                'threshold > ']);
                    if in == 'a'
                        break
                    elseif isnumeric(in) && in > 0 && in < 1
                        threshold = in;
                    else
                        error('Not a valid input');
                    end
                catch err
                    disp('Didn''t recognize that... trying again.');
                end
            end
        end
    end
    
end

