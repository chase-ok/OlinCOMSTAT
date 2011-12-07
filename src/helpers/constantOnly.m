function ok = constantOnly(results)
    % Returns true iff constant (ie 1 threshold for the whole stack)
    % thresholding was used for these results.
    % Example Usage
    %     resultSet.filterBy(@adaptiveOnly)
    
    ok = ~adaptiveOnly(results);
end