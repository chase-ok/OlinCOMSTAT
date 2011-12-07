classdef RunSettings
    
    properties
        environment % Environment enum
        type % Type enum
        time % days
        folder % 'M.D'
        innoculation % 'M.D'
        seriesNum % corresponds to series number inside of folder
        channelNum % which channel num to use
        skip % number of initial images to skip
        smacking % number of images to smack
        thresholds % instance of ThresholdSelector
        imageSeries
    end
    
    properties (Dependent)
        adaptiveThresholding % bool
    end
    
    methods
        
        function obj = RunSettings(environment, type, time, folder, ...
                                   innoculation, seriesNum, channelNum, ...
                                   skip, smacking)
            if nargin == 0, return, end
            
            obj.environment  = environment;
            obj.type         = type;
            obj.time         = time;
            obj.folder       = folder;
            obj.innoculation = innoculation;
            obj.seriesNum    = seriesNum;
            obj.channelNum   = channelNum;
            obj.skip         = skip;
            obj.smacking     = smacking;
        end
        
        function equal = eq(obj, other)
            equal = isa(other, 'RunSettings') && ...
                    strcmp(obj.folder, other.folder) && ...
                    obj.seriesNum == other.seriesNum && ...
                    obj.channelNum == other.channelNum;
        end
        
        function obj = releaseImages(obj)
            obj.thresholds.releaseImages();
            obj.imageSeries = [];
        end
        
        function h = hash(obj, thresh)
            if nargin == 1
                if obj.adaptiveThresholding
                    thresh = 'adaptive';
                else
                    thresh = 'constant';
                end
            end
            h = [obj.folder '-' num2str(obj.seriesNum) '-', ...
                 num2str(obj.channelNum) '-' thresh];
        end
        
        function adap = get.adaptiveThresholding(obj)
            adap = isempty(obj.thresholds) || ...
                   obj.thresholds.adaptiveThresholding;
        end
        
        function obj = set.environment(obj, environment)
            if ~isa(environment, 'Environment')
                error([char(environment) ' is not an evironment enum.']);
            end
            obj.environment = environment;
        end
        
        function obj = set.type(obj, type)
            if ~isa(type, 'Type')
                error([char(type) ' is not an type enum.']);
            end
            obj.type = type;
        end
        
        function obj = set.time(obj, time)
            if ~RunSettings.isPositiveInt(time)
                error([char(time) ' is not a valid time.']);
            end
            obj.time = time;
        end
        
        function obj = set.folder(obj, folder)
            if ~RunSettings.isValidDate(folder)
                error([char(folder) ' is not a valid folder.']);
            end
            obj.folder = folder;
        end
        
        function obj = set.innoculation(obj, innoculation)
            if ~RunSettings.isValidDate(innoculation)
                error([char(innoculation) ' is not a valid ', ... 
                       'innoculation time.']);
            end
            obj.innoculation = innoculation;
        end
        
        function obj = set.seriesNum(obj, seriesNum) 
            if ~RunSettings.isPositiveInt(seriesNum)
                error([char(seriesNum) ' is not a valid seriesNum.']);
            end
            obj.seriesNum = seriesNum;
        end
        
        function obj = set.channelNum(obj, channelNum)
            if ~RunSettings.isPositiveInt(channelNum)
                error([char(channelNum) ' is not a valid channelNum.']);
            end
            obj.channelNum = channelNum;
        end
        
        function obj = set.skip(obj, skip)
            if ~RunSettings.isPositiveInt(skip)
                error([char(skip) ' is not a valid skip ammount.']);
            end
            obj.skip = skip;
        end
        
        function obj = set.smacking(obj, smacking)
            if ~RunSettings.isPositiveInt(smacking)
                error([char(smacking) ' is not a valid smacking amount.']);
            end
            obj.smacking = smacking;
        end
    end
    
    methods (Static)
        function Settings = fromDataSettings(DataSettings)
            n = 1;
            
            for i = 1:length(DataSettings)
                sampleInfo   = DataSettings(i);
                environment  = sampleInfo.environment;
                type         = sampleInfo.type;
                innoculation = sampleInfo.innoculation;
                
                for j = 1:length(sampleInfo.Days)
                    day    = sampleInfo.Days{j};
                    time   = day{1};
                    folder = day{2};
                    
                    for k = 1:length(day{3})
                        run       = day{3}{k};
                        seriesNum = run{1};
                        skip      = run{2};
                        smacking  = run{3};
                        
                        Settings(n) = RunSettings(environment, type, time, ...
                                folder, innoculation, seriesNum, 0, skip, ...
                                smacking); %#ok<AGROW>
                        n = n + 1;
                    end
                end
            end 
        end
    end
    
    methods (Hidden, Static)
        function valid = isValidDate(date)
            valid = ischar(date) && regexp(date, '[0-9]+\.[0-9]+', 'once');
        end
        
        function ok = isPositiveInt(num)
            ok = round(num) == num && num >= 0;
        end
    end
    
end

