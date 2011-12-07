function f = measurementDay(day)
    % Returns a function that returns true iff the given results were measured 
    % on the given day. Day should be formatted as 'M.D' (February 23rd -> 
    % '2.23'). This is the same thing as sorting by folder.
    % Example Usage:
    %     resultsSet.filterBy(measurmentDay('2.23'));
    
    function ok = func(results)
        ok = strcmp(results.settings.folder, day);
    end
    f = @func;
end