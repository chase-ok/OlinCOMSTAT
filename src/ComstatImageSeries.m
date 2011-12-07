classdef ComstatImageSeries < handle
    
    properties
        ImageFiles % Cell array of file paths
        Images % Cell array of images
        Voxel % [x, y, z] voxel sizes
        dayFolder % 'M.D'
        seriesNum
        channelNum
        numImages
    end
    
    properties (Constant)
        COMSTAT_PY_PATH = '..\code\comstat\comstat.py';
        DATA_DIR        = '..\data';
    end
    
    methods
        function obj = ComstatImageSeries(dayFolder, seriesNum, channelNum)
            if nargin == 0, return, end
            
            obj.dayFolder = dayFolder;
            obj.seriesNum = seriesNum;
            obj.channelNum = channelNum;
        end
        
        function load(obj)
            obj.moveComstatPy();
            obj.parseComstatPyOutput();
            obj.loadImages();
        end
        
        function skip(obj, num)
            obj.ImageFiles = obj.ImageFiles((num + 1):end);
            obj.Images = obj.Images((num + 1): end);
        end
        
        function numImages = get.numImages(obj)
            numImages = length(obj.Images);
        end
    end
        
    methods (Hidden)
        function moveComstatPy(obj)
        % Copy the comstat.py script from the code directory for easier 
        % access.
        
            status = system(['copy "', obj.COMSTAT_PY_PATH, '" ', pwd()]);
            if status ~= 0
                error('Could not copy comstat.py from code dir');
            end
        end
        
        function parseComstatPyOutput(obj)
        % Use the comstat.py script to parse basic information about a series,
        % copy the images over into the test directory and extract a list of
        % image file names.
            [status, dataStr] = system(['python comstat.py "', ...
                                        obj.DATA_DIR '\' obj.dayFolder '" ', ...
                                        int2str(obj.seriesNum) ' ', ...
                                        int2str(obj.channelNum)
                                       ]);
            if status ~= 0
                error(['comstat.py failed: ', dataStr]);
            end

            % First three lines of the comstat output are the voxel sizes 
            % (x, y, z)
            Lines = regexp(dataStr, '\n', 'split');
            for j = 1 : 3
                obj.Voxel(j) = str2double(Lines(j));
            end

            % The result of the lines (minus the last blank one) are image files
            %(in order)
            obj.ImageFiles = Lines(4:end-1); % pull off the last blank str
        end
        
        function loadImages(obj)
            obj.Images = cell(1, length(obj.ImageFiles));
            for j = 1 : length(obj.ImageFiles)
                obj.Images{j} = imread(obj.ImageFiles{j});
            end
        end
            
    end
    
end

