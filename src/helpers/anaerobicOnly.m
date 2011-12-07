function ok = anaerobicOnly(results)
    % Returns true iff the given results were measured from an anaerobic
    % sample.
    % Example Usage:
    %    resultsSet.filterBy(@anaerobicOnly)
    
    ok = results.settings.environment == Environment.Anaerobic;
end