classdef ResultsSet
    
    properties
        Results % Vector of results that are inside this set
    end
    
    properties (Dependent)
        length % number of results inside this set.
    end
    
    methods
        function obj = ResultsSet(Results)
            if nargin == 0, return, end
            
            obj.Results = Results;
        end
        
        function len = get.length(obj)
            len = length(obj.Results);
        end
        
        function obj = filterBy(obj, func)
            % Returns a new results set that contains only the results
            % where func(results) returns true.
            % Usage Example:
            %     resultsSet.filterBy(@adaptiveOnly)
            %     (returns a new set of results that contains only
            %     adaptively thresholded results)
            
            Include = false(1, obj.length);
            for i = 1 : obj.length
                Include(i) = func(obj.Results(i));
            end
            
            obj = ResultsSet(obj.Results(Include));
        end
        
        function obj = sortBy(obj, func)
            % Returns a new results set where the results are sorted by the
            % given function. The function should take 2 arguments (a and
            % b) and return -1 if a < b, 0 if a == b, and 1 if a > b.
            % TODO: make sorting functions (by time, etc.)
            
            Sorted = obj.Results(1);
            for i = 2:obj.length
                current = obj.Results(i);
                
                found = false;
                for j = 1:length(Sorted)
                    if func(current, Sorted(j)) <= 0
                        rest = Sorted(j:end);
                        Sorted(j) = current;
                        Sorted = [Sorted(1:j) rest];
                        
                        found = true;
                        break;
                    end
                end
                
                if ~found, Sorted(end + 1) = current; end
            end
            
            obj = ResultsSet(Sorted);
        end
        
        function Subsets = splitAll(obj)
            Subsets(obj.length) = ResultsSet;
            for i = 1:obj.length
                Subsets(i) = ResultsSet(obj.Results(i));
            end
        end
        
        function Sets = groupBy(obj, groupFunc)
            % Returns a vector of ResultSets where each ResultsSet contains
            % the results that have been grouped together by groupFunc.
            % groupFunc should take Results and return an integer that
            % matches the integers assigned to every other Results in the
            % intended group.
            % Example Usage:
            %    resultsSet.groupBy(@sameSample)
            
            GroupIds = [];
            Groups = {};
            
            for i = 1:obj.length
                results = obj.Results(i);
                id = groupFunc(results);
                
                match = find(GroupIds == id, 1);
                if isempty(match)
                    GroupIds(end + 1) = id;
                    Groups{end + 1} = results;
                else
                    Groups{match} = [Groups{match} results];
                end
            end
            
            for i = 1:length(Groups)
                Sets(i) = ResultsSet(Groups{i});
            end
        end
        
        function [X Y] = mergeXY(obj, xyFunc)
            % Returns a vector of x's and a cell array of vectors of
            % corresponding y values. Func should take results and return
            % an x and y pair. If any there are any pairs that share the
            % same x value, they are merged together such that X(i) will be
            % the common x-value, and Y{i} will contain a vector of two or
            % more y-values. 
            % Usage Example:
            %     resultsSet.mergeBy(timeVs('biomass'))
            %     will return the times of the results as X and the various
            %     biomass values in Y, grouped together by time.
            
            X = [];
            Y = {};
            
            for i = 1:obj.length
                current = obj.Results(i);
                [x y] = xyFunc(current);
                
                found = false;
                for j = 1:length(X)
                    if X(j) == x
                        Y{j} = [Y{j} y];
                        found = true;
                        break
                    end
                end
                
                if ~found
                    X(end + 1) = x;
                    Y{length(X)} = y;
                end
            end
        end
        
        function [X Means StdDevs] = getDistribution(obj, xyFunc)
            % Takes a function that maps the results into x,y pairs and
            % returns the set of unique x-values, and the mean and std.
            % dev. of the y-values that correspond to each x-value.
            % Example Usage
            %    [X Mean StdDev] = resultsSet.getDistribution(timeVs('biomass'));
            %    X will be all of the times, Mean will contain the average
            %    biomass at each time, and StdDev will contain the std.
            %    dev. at each time.
            
            [X Y] = obj.mergeXY(xyFunc);
            
            for i = 1:length(Y)
                Means(i) = mean(Y{i});
                StdDevs(i) = std(Y{i});
            end
        end
        
        function [X Y] = extractXY(obj, xyFunc)
            % Takes a function that maps results into x,y pairs and returns
            % a vector of x-values and a vector of corresponding y-values.
            % NOTE: the x-values might not be unique. See mergeXY
            % Usage Example:
            %    [X Y] = resultsSet.extractXY(timeVs('biomass'))
            
            X = zeros(size(obj.Results));
            Y = zeros(size(obj.Results));
            for i = 1:obj.length
                [x y] = xyFunc(obj.Results(i));
                X(i) = x;
                Y(i) = y;
            end
        end
        
        function h = plotByOrder(obj, func, style)
            % Plots the results set using the order of the results as the
            % x-values (i.e. the first results = 1, second = 2, etc; see
            % orderBy) and using func(results) as the y-value. Style is the
            % drawing style to use (defaults to 'bx').
            % Usage Example:
            %     resultsSet.plotByOrder(@(results) results.biomass)
            
            if nargin == 2, style = 'bx'; end
            
            Y = zeros(size(obj.Results));
            for i = 1 : obj.length
                Y(i) = func(obj.Results(i));
            end
            
            h_ = plot(1:obj.length, Y, style);
            if nargout == 1, h = h_; end
        end
        
        function h = plotByXY(obj, xyFunc, style)
            % Plots the results, using xyFunc to map from results to x,y
            % pairs. Style is the drawing style used (defaults to 'bx').
            % Usage Example:
            %     resultsSet.plotByXY(timeVs('biomass'), 'rx')
            
            if nargin == 2, style = 'bx'; end
            
            [X Y] = obj.extractXY(xyFunc);
            h_ = plot(X, Y, style);
            if nargout == 1, h = h_; end
        end
        
        function h = plotEachByXY(obj, XYFunc, style)
            % Plots a curve for each result inside of the set, using XYFunc
            % to map from a result to an XY curve.
            % Usage Example:
            %     resultsSet.plotEachByXY(@depthVsCoverage)
            
            if nargin == 2, style = 'b'; end
            
            hold on;
            for i = 1:obj.length
                [X Y] = XYFunc(obj.Results(i));
                h_ = plot(X, Y, style);
            end
            if nargout == 1, h = h_; end
        end
        
        function h = plotDistribution(obj, xyFunc, style)
            % Plots the distribution of x,y pairs (using xyFunc to map from
            % results to pairs). For each x value, this plots the mean value 
            % and vertical errorbars reaching +/-1 std deviation. Style is 
            % the drawing style used (defaults to 'r').
            
            if nargin == 2, style = 'r'; end
            
            [X Means StdDevs] = obj.getDistribution(xyFunc);
            h = errorbar(X, Means, StdDevs, style);
            if nargout == 1, h = h_; end
        end
        
        function h = plotAverageCurve(obj, XYFunc, style)
            % Similar to plotEachByXY, except instead of plotting a curve
            % for each of the results, it plots the average of each of the
            % individual curves through x-grouping and interpolation.
            
            if nargin == 2, style = 'b'; end
            
            AllX = {};
            AllY = {};
            
            for i = 1:obj.length
                [X Y] = XYFunc(obj.Results(i));
                AllX{i} = X;
                AllY{i} = Y;
            end
            
            X = [];
            Y = [];
            Indices = ones(1, obj.length);
            Lengths = cellfun(@length, AllX);
            
            while ~all(Indices >= Lengths)
                StillIn = find(Indices <= Lengths);
                HeadX = [];
                for i = 1:length(StillIn)
                    allIndex = StillIn(i);
                    HeadX(i) = AllX{allIndex}(Indices(allIndex));
                end
                
                x = min(HeadX);
                Values = [];

                for i = 1:length(StillIn)
                    allIndex = StillIn(i);
                    
                    if abs(HeadX(i) - x) < 0.000001
                        Values(end + 1) = AllY{allIndex}(Indices(allIndex));
                        Indices(allIndex) = Indices(allIndex) + 1;
                    else
                        Values(end + 1) = ...
                            interp1(AllX{allIndex}, AllY{allIndex}, x, ...
                                    'linear', 'extrap');
                    end
                end

                X(end + 1) = x;
                Y(end + 1) = mean(Values);
            end
            
            h_ = plot(X, Y, style);
            if nargout == 1, h = h_; end
        end
                
        function Settings = getSettings(obj)
            Settings(length(obj.Results)) = RunSettings;
            for i = 1:length(obj.Results)
                Settings(i) = obj.Results(i).settings;
            end
        end
    end
    
    methods (Static)
        
        function H = overlayXY(Sets, XYFunc, legendEntries, Styles)
            % Takes a vector of ResultsSets and does a plotByXY for each
            % using XYFunc and corresponding elements in the Styles cell
            % array. These plots are overlayed on top of a single set of
            % axes. legendEntries can be: (1) unspecified, in which case no
            % legend is displayed, (2) a function that takes a ResultsSet
            % and returns a descriptive string for a legend entry, or (3) a
            % cell array of legend entries that correspond to each of the
            % given sets. Styles can also be unspecified and will default
            % to solid lines of different colors.
            % Optionally returns H, which is a vector of handles to each of
            % the plots.
            % Usage Example:
            %     ResultsSet.overlayXY(rs.groupBy(@sameSample), ...
            %                          timeVs('biomass'));
            
            if nargin < 4, Styles = ResultsSet.getDefaultStyles(); end
            if nargin < 3, legendEntries = []; end
            
            function h = plotFunc(set, style)
                h = set.plotByXY(XYFunc, style);
            end
            
            H_ = ResultsSet.doOverlay(@plotFunc, Sets, legendEntries, Styles);
            if nargout == 1, H = H_; end
        end
        
        function H = overlayEachXY(Sets, XYFunc, legendEntries, Styles)
            % Takes a vector of ResultsSets and does a plotEachByXY for each
            % using XYFunc and corresponding elements in the Styles cell
            % array. These plots are overlayed on top of a single set of
            % axes. legendEntries can be: (1) unspecified, in which case no
            % legend is displayed, (2) a function that takes a ResultsSet
            % and returns a descriptive string for a legend entry, or (3) a
            % cell array of legend entries that correspond to each of the
            % given sets. Styles can also be unspecified and will default
            % to solid lines of different colors.
            % Optionally returns H, which is a vector of handles to each of
            % the plots.
            % Usage Example:
            %     ResultsSet.overlayEachXY(rs.groupBy(@sameSample), ...
            %                              @depthVsCoverage);
            
            if nargin < 4, Styles = ResultsSet.getDefaultStyles(); end
            if nargin < 3, legendEntries = []; end
            
            function h = plotFunc(set, style)
                h = set.plotEachByXY(XYFunc, style);
            end
            
            H_ = ResultsSet.doOverlay(@plotFunc, Sets, legendEntries, Styles);
            if nargout == 1, H = H_; end
        end
        
        function H = overlayAverageCurves(Sets, XYFunc, legendFunc, Styles)
            % Takes a vector of ResultsSets and does a plotAverageCurve for each
            % using XYFunc and corresponding elements in the Styles cell
            % array. These plots are overlayed on top of a single set of
            % axes. legendEntries can be: (1) unspecified, in which case no
            % legend is displayed, (2) a function that takes a ResultsSet
            % and returns a descriptive string for a legend entry, or (3) a
            % cell array of legend entries that correspond to each of the
            % given sets. Styles can also be unspecified and will default
            % to solid lines of different colors.
            % Optionally returns H, which is a vector of handles to each of
            % the plots.
            % Usage Example:
            %     ResultsSet.overlayAverageCurves(rs.groupBy(@sameSample), ...
            %                                     @depthVsCoverage);
            
            if nargin < 4, Styles = ResultsSet.getDefaultStyles(); end
            if nargin < 3, legendFunc = []; end
            
            function h = plotFunc(set, style)
                h = set.plotAverageCurve(XYFunc, style);
            end
            
            H_ = ResultsSet.doOverlay(@plotFunc, Sets, legendFunc, Styles);
            if nargout == 1, H = H_; end
        end
        
    end
    
    methods (Static, Hidden)
        
        function H = doOverlay(plotFunc, Sets, legendEntries, Styles)
            H = [];
            isFunc = isa(legendEntries, 'function_handle');
            if ~isempty(legendEntries) && ~isFunc
                Strings = legendEntries;
            else
                Strings = {};
            end
            
            hold on;
            for i = 1:length(Sets)
                H(i) = plotFunc(Sets(i), Styles{i});
                
                if isFunc
                    Strings{i} = legendEntries(Sets(i));
                end
            end
            
            if ~isempty(Strings)
                legend(H, Strings{:});
            end
        end
        
        function Styles = getDefaultStyles()
            Styles = {'r', 'g', 'b', 'c', 'm', 'y', 'k', ...
                      'r--', 'g--', 'b--', 'c--', 'm--', 'y--', 'k--'};
        end
    end
    
end

