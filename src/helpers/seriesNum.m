function f = seriesNum(num)
    % Returns a function that takes results and returns true iff the
    % seriesNum of those results is equal to num.
    % Example Usage:
    %     resultsSet.filterBy(seriesNum(5));
    
    function ok = func(results)
        ok = results.settings.seriesNum == num;
    end
    f = @func;
end