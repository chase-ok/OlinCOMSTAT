function id = sampleSample(results)
    
    MAX_INOC_ID = 1231; % Dec 31, 12.31*100
    MAX_TIME_ID = (MAX_INOC_ID + 1)*100; % 100 days TODO: will it go over?

    f = innoculationDay();
    inocId = f(results);
    
    if results.settings.type == Type.WT, tFlag = 0; else tFlag = 1; end
    if results.settings.environemnt == Environment.Aerobic, eFlag = 2; else eFlag = 4; end
    
    id = inocId + results.settings.time*(MAX_INOC_ID + 1);
end