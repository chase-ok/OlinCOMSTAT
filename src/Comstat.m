classdef Comstat < handle

    properties (Constant)
        RESULTS_DIR = '..\Palustris results';
    end
    
    methods (Static)
        
        function Settings = computeThresholds(DataSettings, ExistingSettings, overrideExisting)
            if nargin < 3, overrideExisting = false; end
            
            BaseSettings = RunSettings.fromDataSettings(DataSettings);
            Settings(2*length(BaseSettings)) = RunSettings;
            
            index = 0;
            for i = 1:length(ExistingSettings)
                if isempty(ExistingSettings(i).environment)
                    index = i;
                    break
                end
            end
            
            
            if index ~= 0
                disp(['Resuming at run #', num2str(index + 1)]);
                Settings(1:index) = ExistingSettings(1:index);
            end
            
            for i = ((index + 1)/2):length(BaseSettings)
                disp(['Run #', num2str(i)]);
                
                settings = BaseSettings(i);
                
                if ~overrideExisting && Comstat.alreadyExists(settings)
                    [adap const] = Comstat.loadIndivThresholds(settings);
                else
                    [adap const] = Comstat.computeIndivThresholds(settings);
                end
                
                Settings(2*i - 1) = adap;
                Settings(2*i) = const;
                save('TempSettings.mat', 'Settings');
            end
        end
        
        function rs = compute(Settings)
            AllResults(length(Settings)) = Results;
            for i = 1:length(Settings)
                AllResults(i) = Comstat.computeResults(Settings(i));
            end
            rs = ResultsSet(AllResults);
        end
        
        function computeAndSave(Settings)
            for i = 1:length(Settings)
                Comstat.saveResults(Comstat.computeResults(Settings(i)));
            end
        end
        
        function save(rs)
            for i = 1:rs.length
                Comstat.saveResults(rs.Results(i));
            end
        end
        
        function rs = load()
            FileDescripts = dir([Comstat.RESULTS_DIR '\*.comstat']);
            Files = { FileDescripts.name };
            AllResults(length(Files)) = Results;
            
            for i = 1:length(Files)
                s = load([Comstat.RESULTS_DIR '\' Files{i}], '-mat', 'results');
                s.results.releaseImages();
                AllResults(i) = s.results;
            end
            
            rs = ResultsSet(AllResults);
        end
        
        function clearImages()
            FileDescripts = dir([Comstat.RESULTS_DIR '\*.comstat']);
            Files = { FileDescripts.name };
            
            for i = 1:length(Files)
                i
                s = load([Comstat.RESULTS_DIR '\' Files{i}], '-mat', 'results');
                s.results.releaseImages();
                Comstat.saveResults(s.results);
                clear s;
            end
            
        end
        
    end
    
    methods (Hidden, Static)
        function [adap const] = computeIndivThresholds(settings)
            imageSeries = Comstat.loadImageSeries(settings);
            
            adaptiveThresholds = ThresholdSelector();
            adaptiveThresholds.selectManually(imageSeries);
            adaptiveThresholds.releaseImages();
            
            constThresholds = ThresholdSelector();
            constThresholds.selectAverage(imageSeries, adaptiveThresholds);
            constThresholds.releaseImages();
            
            adap = settings;
            adap.thresholds = adaptiveThresholds;
            
            const = settings;
            const.thresholds = constThresholds;
        end
        
        function [adap const] = loadIndivThresholds(settings)
            s = load(Comstat.getResultsPath(settings, 'adaptive'), '-mat', ...
                     'results');
            adap = s.results.settings;
            
            s = load(Comstat.getResultsPath(settings, 'constant'), '-mat', ...
                     'results');
            const = s.results.settings;
        end
        
        function results = computeResults(settings)
            settings.imageSeries = Comstat.loadImageSeries(settings);
            
            results = Results();
            results.compute(settings);
            results.releaseImages();
        end
        
        function imageSeries = loadImageSeries(settings)
            imageSeries = ImageSeries(settings.folder, settings.seriesNum, 1); 
            imageSeries.load();
            imageSeries.skip(settings.skip);
        end
        
        function exists = alreadyExists(settings)
            path = Comstat.getResultsPath(settings, 'adaptive');
            exists = exist(path, 'file');
        end
        
        function saveResults(results)
            save(Comstat.getResultsPath(results.settings), 'results');
        end
        
        function path = getResultsPath(settings, thresh)
            if nargin == 1
                hash = settings.hash();
            else
                hash = settings.hash(thresh);
            end
            path = [Comstat.RESULTS_DIR '\' hash '.comstat'];
        end
    end
    
end

