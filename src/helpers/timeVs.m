function f = timeVs(field)
    % Returns a function that extracts the time of results (in days) as x
    % and the value of a particular property on that day as y. For example,
    % timeVs('biomass') will return time as x and biomass as y. See the
    % properties in Results for measurable properties. 
    % NOTE: This only works with scalar properties (e.g. 'Heights' won't
    % work).
    % NOTE: You can also pass a custom function instead of a property
    % string. That function will then be called on every result and is
    % expected to return a y value (e.g. timeVs(@surfaceCoverage)
    % Example Usage:
    %     resultSet.plotByXY(timeVs('biomass'));
    
    function [x y] = funcField(results)
        x = results.settings.time;
        y = results.(field);
    end

    function [x y] = funcFunc(results)
        x = results.settings.time;
        y = field(results);
    end

    if ischar(field)
        f = @funcField;
    else
        f = @funcFunc;
    end
end