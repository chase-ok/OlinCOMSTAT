classdef Results < handle
    
    properties
        settings 
        % RunSettings
        
        Voxel 
        % [x, y, z] sizes of each voxel in microns
        
        thresholdSelector 
        % instance of ThresholdSelector
        % TODO: DELETE
             
        biomass 
        % Total volume of biofilm per surface area of substrate (microns^3
        % / microns^2)
        
        Coverage
        % A vector whose indices correspond to slice depth and values
        % correspond to the percent coverage of the biofilm.
        
        Heights
        % 512x512 matrix of the height of the biofilm (in microns)
        
        HeightDist
        % Matrix with two columns. Each row contains a height and the
        % number of pixels that reach that height exactly.
        
        roughness
        % The unit-less roughness coefficient
        
        surfaceArea
        % The surface area of the biofilm per surface area of substrate
        % (microns^2 / microns^2).
        
        Colonies
        % Vector of colony sizes (in microns^2)
        
        ColonyImage
        % A black/white image containing on the recognized colonies.
        
        minColonySize = 500;
        % Minimum recognizable colony size in pixels.
    end
    
    properties (Hidden)
        Images 
        % Cell array of images
    end
    
    properties (Dependent)
        maxHeight
        % The maximum height (in microns) of the biofilm.
        
        averageHeight
        % The average height (im microns) of the biofilm).
        % DIFFERENT FROM COMSTAT! USES ONLY NON-EMPTY PIXELS!
        
        surfaceAreaToBiomass
        % Ratio of biofilm surface area to biofilm biomass (in
        % microns^2/microns^3).
        
        numColonies
        % The number of colonies found.
        
        averageColonySize
        % In (microns^2)
        
        pixelArea
        sliceArea
        voxelVolume
        
        adaptiveThresholding % bool
        % TODO: DELETE
    end
    
    methods
        function obj = Results()
        end
        
        function compute(obj, settings)
            obj.settings = settings;
            
            obj.Voxel = settings.imageSeries.Voxel;
            obj.Images = settings.thresholds.apply(settings.imageSeries);
            
            obj.filterByConnectedVolume();
            
            obj.calculateBiomass();
            obj.calculateCoveragePerLayer();
            obj.calculateBiofilmHeight();
            obj.calculateRoughness();
            obj.calculateSurfaceArea();
        end
        
        function releaseImages(obj)
            obj.Images = [];
            obj.settings = obj.settings.releaseImages();
        end
        
        function volume = get.voxelVolume(obj)
            volume = prod(obj.Voxel);
        end
        
        function area = get.pixelArea(obj)
            area = prod(obj.Voxel(1:2)); 
        end
        
        function area = get.sliceArea(obj)
            area = obj.pixelArea*numel(obj.Images{1}); 
        end
        
        function avg = get.averageHeight(obj)
            %avg = sum(sum(obj.Heights)) / numel(obj.Heights);
            avg = sum(obj.HeightDist(:, 1).*obj.HeightDist(:, 2))/...
                  sum(obj.HeightDist(:, 2));
        end
        
        function maxHeight = get.maxHeight(obj)
        % Take the top 5% of heights to compute the average max height.
            % (:) flattens a matrix into a vector
            sorted = sort(obj.Heights(:), 'descend');
            top = sorted(1 : floor(0.05*length(sorted)));
            maxHeight = mean(top);
        end
        
        function ratio = get.surfaceAreaToBiomass(obj)
            ratio = obj.surfaceArea / obj.biomass;
        end
        
        function num = get.numColonies(obj)
            num = length(obj.Colonies);
        end
        
        function avg = get.averageColonySize(obj)
            avg = mean(obj.Colonies);
        end
        
        function adap = get.adaptiveThresholding(obj)
            adap = obj.thresholdSelector.adaptiveThresholding;
        end
        
    end
    
    methods (Hidden)
        
        function filterByConnectedVolume(obj)
        % Goes down the stack filters each image so that it only includes pixel
        % groups that touch a pixel group in the image before it. This removes
        % single pixel noise as well as ensures that the biofilm is a single,
        % connected volume.
            for j = 2 : length(obj.Images)
                % Logical AND gives points of intersection
                InCommon = obj.Images{j - 1} & obj.Images{j}; 
                [R C] = find(InCommon);

                if isempty(R)
                    % No points in common, so the rest of the images will be 
                    % blank
                    obj.Images{j} = zeros(size(obj.Images{j}));
                else
                    % Pick out the pixel groups (ie touching pixels) that are
                    % connected to the previous image.
                    % Yes, C and R are flipped. Because matlab is never consistent
                    obj.Images{j} = bwselect(obj.Images{j}, C, R);
                end
            end
        end
        
        function calculateBiomass(obj)
        % Sets results.biomass to be the biomass in the stack per area (units of
        % L^3 / L^2). The white area of each slice is summed down the whole
        % stack and scaled by the voxel size and the slice area.
            total = 0;
            for j = 1 : length(obj.Images)
                total = total + bwarea(obj.Images{j});
            end
            obj.biomass = total*obj.voxelVolume/obj.sliceArea;
        end
        
        function calculateCoveragePerLayer(obj)
        % Sets results.Coverage to be the percent area that the biofilm covers
        % in each slice.
            for j = 1 : length(obj.Images)
                obj.Coverage(j) = bwarea(obj.Images{j})/numel(obj.Images{j});
            end
        end
        
        function calculateBiofilmHeight(obj)
        % Sets results.Heights to be a matrix of maximum biofilm heights above
        % the substratum for each pixel in the image slice area.
        %
        % Sets results.HeighDist to be a matrix with two columns. Each row
        % contains a height and the number of pixels that reach that height
        % exactly.
        %
        % Sets results.maxHeight to be the average of the top MAX_HEIGHT_PERCENT
        % of heights. Using an average of the greatest heights reduces the
        % variance due to random noise.
        %
        % Sets results.averageHeight to be the average heigh the biofilm reaches
        % per pixel.
        % 
        % NOTE: Ignores pores and voids within the biofilm.
            obj.Heights = zeros(size(obj.Images{1}));
            obj.HeightDist = zeros(length(obj.Images), 2);

            % Loop backwards through the image stack so that the first time we 
            % find a 1 at a given pixel, we can ignore that pixel for the rest 
            % of the loop.
            for j = length(obj.Images) : -1 : 2
                % Find all pixels that are in the current image but that are not
                % yet in the Heights matrix.
                NewColumns = obj.Images{j} & (~obj.Heights);
                n = sum(sum(NewColumns)); % Number of new column peaks found
                height = j*obj.Voxel(3); % Height is how many image slices we 
                                         % are into the stack

                % Merge the heights matrix with the newly found heights
                obj.Heights = obj.Heights + NewColumns*height;

                obj.HeightDist(j, 1) = height;
                obj.HeightDist(j, 2) = n;
            end
        end
        
        function calculateRoughness(obj)
        % Sets results.roughness to be the roughness coefficient as given by:
        %             1    n   | H_n - H_avg |
        %       Ra =  - . SUM  ---------------
        %             n    1        H_avg
        % where n is the total number of peaks in the stack, H_n is the height
        % of the nth peack, and H_avg is the average height.
        %
        % NOTE: Depends on calculateBiofilmHeight
            numPeaks = sum(obj.HeightDist(:, 2));
            avg = obj.averageHeight;

            % Loop over all of the peaks and compute the sum of the abs difference
            % between a peak height and the average height.
            diffsSum = 0;
            for j = 1 : length(obj.HeightDist(:, 1))
                diff = obj.HeightDist(j,1) - avg;
                diffsSum = diffsSum + abs(obj.HeightDist(j,2)*diff);
            end

            if avg ~= 0
                obj.roughness = diffsSum / (numPeaks*avg);
            else
                obj.roughness = 0;
                warning('Average height is 0. Something very wrong happened.');
            end
        end
        
        function calculateSurfaceArea(obj)
        % Sets results.surfaceArea to be the total surface area of the biofilm
        % (including internal pores and voids) normalized by slice area (giving
        % units of L^2 / L^2).
        %
        % Sets results.surfaceAreaToBiomass to be the ratio of surface area to
        % biomass, again normalized by slice area.
        %
        % NOTE: This is computed in a slightly different manner from the COMSTAT 
        % version. This uses a circshift instead of assuming the 4 sides are 
        % solid biomass. (Well, actually, it doesn't look like the current
        % COMSTAT version does that either. TBD) Also, the surfaceArea is NOT
        % normalized in the COMSTAT version.
        %
        % End of the stack is assumed to be bio-free
            obj.Images{end + 1} = zeros(size(obj.Images{1}));

            xy = 0; % Sum of surface area in x-y plane
            xz = 0; % x-z plane
            yz = 0; % y-z plane

            for j = 1 : (length(obj.Images) - 1)
                Im = obj.Images{j};

                % ~= yields 1 when the two matrices differ (ie theres a boundary
                % area between 1 and 0 or between 0 and 1), so we can just add
                % up all of the differences to find the surface area.

                xy = xy + sum(sum(Im ~= obj.Images{j + 1}));
                
                % circshift shifts the whole images in a given direction. If 
                % there is a difference between the original image and the 
                % shifted image, then there's a boundary at the difference 
                % pixel. E.g. a solid white or a solid black image would yield 
                % no differences, while a half black and half white image would 
                % yield a single line of 1's down the middle.
                xz = xz + sum(sum(Im ~= circshift(Im, [0 1])));
                yz = yz + sum(sum(Im ~= circshift(Im, [1 0])));
            end

            % Areas of a single side of a voxel
            areaXY = obj.Voxel(1)*obj.Voxel(2);
            areaXZ = obj.Voxel(1)*obj.Voxel(3);
            areaYZ = obj.Voxel(2)*obj.Voxel(3);

            % normalize with slice area
            obj.surfaceArea = (xy*areaXY + xz*areaXZ + yz*areaYZ)/obj.sliceArea;
        end
        
        function calculateMicrocoloniesAtSubstratum(obj)
        % Sets results.Colonies to be a vector of microcolony sizes (in area).
        % The colonies are searched for on substratum (assumed to be the first 
        % image in the stack).
        %
        % Sets results.numColonies to be the total number of microcolonies found
        % that area of at least MIN_COLONY_SIZE pixels big.
        %
        % Sets results.averageColonySize to be the mean microcolony size.
        %
        % Sets results.minColonySize to the minimum size criterion used for
        % searching for microcolonies. NOTE: this may shrink from the originial
        % constant used if no colonies are found at first.
        %
        % Sets results.ColonyImage to be a black-white image where only the
        % microcolonies at the substratum are included.
        %
        % Applies a series of filters to reduce noise in the image and then uses
        % bwselect to find connected groups of biomass (deemed microcolonies).
        %
        % TODO: make the location where the microcolonies are measured variable
        % (i.e. not restricted to the substratum).
            % Filtration matrix
            M = [1 1 1
                 1 0 1
                 1 1 1];

            % Remove single pixel noise
            Filtered = ordfilt2(obj.Images{1}, 8, M);

            % Use multiple rounds of median / erosion filtering to remove small
            % microcolonies. TODO: How were these constants picked in COMSTAT??

            % Apply median filtering a max of 3 times
            for j = 1 : min([3, floor(obj.minColonySize/50) + 1])
                Filtered = medfilt2(Filtered);
            end

            % Apply erosion filtering a max of 5 times
            for j = 1 : min([5, floor(obj.minColonySize/100) + 1])
                Filtered = ordfilt2(Filtered, 1, M);
            end

            % Expand back into the original image
            [R, C] = find(Filtered);
            Top = bwselect(obj.Images{1}, C, R); % Again, inconsistent with R, C

            % Find connected groups of pixels (those with at least 8 neighbors)
            ConDescription = bwconncomp(Top, 8);
            AllColonies = ConDescription.PixelIdxList;

            % Loop through all of the found groups and filter by size
            ColonyImage = zeros(size(Top));
            k = 1;
            for j = 1 : ConDescription.NumObjects
                colonySize = length(AllColonies{j});
                if colonySize > obj.minColonySize
                    Colonies(k) = pixelArea*colonySize; %#ok<AGROW>
                    k = k + 1;

                    % Put the group in the colony image
                    ColonyImage(AllColonies{j}) = 1;
                end
            end

            if isempty(Colonies)
                % Try shrinking our size criterion
                obj.minColonySize = floor(obj.minColonySize * 0.75);

                if obj.minColonySize < 50
                    % At this point there's no hope / any results will just be noise
                    warning('Couldn''t find any microcolonies.');
                    obj.Colonies = [];
                    obj.ColonyImage = [];
                else
                    warning(['No colonies were detected.', ...
                             'Trying a smaller minimum colony size...']);
                    % Recurse and try the smaller size
                    obj.calculateMicrocoloniesAtSubstratum();
                end

                return
            end

            obj.Colonies = Colonies;
            obj.ColonyImage = ColonyImage;
        end
        
    end
    
end

