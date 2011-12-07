function f = innoculationDay(day)
    % If no arguments are passed, it returns a function that returns a
    % unique id for each innoculation day for use with resultsSet.groupBy.
    % Otherwise, it returns a function that returns true iff the given
    % results measure a sample that was innoculated on the given day. Day
    % should be formatted as 'M.D' (February 23rd -> '2.23').
    % Example Usage:
    %     resultsSet.filterBy(innoculationDay('2.23'));
    
    function id = idFunc(results)
        id = round(str2double(results.settings.innoculation)*100);
    end

    function ok = compFunc(results)
        ok = strcmp(results.settings.innoculation, day);
    end
    
    if nargin == 0, f = @idFunc; else f = @compFunc; end
end