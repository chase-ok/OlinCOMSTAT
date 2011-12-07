function id = sameSample(results)
    
    MAX_INOC_ID = 1231; % Dec 31, 12.31*100
    MAX_TIME_ID = (MAX_INOC_ID + 1)*100; % 100 days TODO: will it go over?

    settings = results.settings;
    inocF = innoculationDay();
    
    inocId = inocF(results);
    timeId = settings.time;
    setupId = enumsToBitflag({settings.type, settings.environment});
    
    id = inocId + timeId*(MAX_INOC_ID + 1) + setupId*(MAX_TIME_ID + 1);
end