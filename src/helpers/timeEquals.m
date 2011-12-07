function f = timeEquals(days)
    % Returns a function that takes results and returns true iff the number
    % of days past its innoculation is equal to days.
    % Example Usage:
    %     resultsSet.filterBy(timeEquals(8));
    
    function ok = func(results)
        ok = results.settings.time == days;
    end
    f = @func;
end