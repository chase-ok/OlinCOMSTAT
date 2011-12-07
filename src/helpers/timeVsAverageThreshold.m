function [x y] = timeVsAverageThreshold(results)
    % Returns time as x and the average threshold as y.
    % Example Usage:
    %     resultSet.plotByXY(@timeVsAverageThreshold)
    
    x = results.settings.time;
    y = results.thresholdSelector.averageThreshold;
end