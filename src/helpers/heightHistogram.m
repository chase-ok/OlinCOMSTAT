function f = heightHistogram(numBins)
    function [X Y] = func(results)
        [Y X] = hist(results.Heights(:), numBins);
    end
    f = @func;
end