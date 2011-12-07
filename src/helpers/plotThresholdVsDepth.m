function plotThresholdVsDepth(results)
    % Opens a new figure and plots the thresholds of the given results with
    % depth on the x-axis and the threshold on the y-axis.
    
    figure, xlabel('Depth (Slices)'), ylabel('Threshold');
    results.thresholdSelector.plot('r-');
end