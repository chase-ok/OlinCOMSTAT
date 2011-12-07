function ok = adaptiveOnly(results)
    ts = results.settings.thresholds;
    
    if isempty(ts.adaptiveThresholding)
        ok = any(abs(ts.Thresholds - ts.averageThreshold) > 0.01);
    else
        ok = ts.adaptiveThresholding;
    end
end