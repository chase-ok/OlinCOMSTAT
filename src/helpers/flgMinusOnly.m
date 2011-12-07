function ok = flgMinusOnly(results)
    % Returns true iff the given results are from a Flg- sample.
    % Example Usage:
    %    resultSet.filterBy(@flgMinusOnly);
    
    ok = results.settings.type == Type.FlgMinus;
end