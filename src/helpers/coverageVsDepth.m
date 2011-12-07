function [X Y] = coverageVsDepth(results)
    X = results.Coverage;
    Y = 1:length(results.Coverage);
end