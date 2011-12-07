function ok = CyanoMOTTypeOnly(results)
    % Returns true iff the given results are from a wild type sample.
    % Example Usage:
    %     resultsSet.filterBy(@wildTypeOnly);
    
    ok = results.settings.type == Type.CyanoMotile;
end