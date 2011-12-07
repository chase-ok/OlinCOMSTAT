function ok = aerobicOnly(results)
    % Returns true iff the given results were measured from an   aerobic
    % sample.
    % Example Usage:
    %    resultsSet.filterBy(@aerobicOnly)
    
    ok = results.settings.environment == Environment.Aerobic;
end