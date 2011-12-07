function ok = CyanoWTTypeOnly(results)
    % Returns true iff the given results are from a wild type sample.
    % Example Usage:
    %     resultsSet.filterBy(@wildTypeOnly);
    
    ok = results.settings.type == Type.CyanoWT;
end