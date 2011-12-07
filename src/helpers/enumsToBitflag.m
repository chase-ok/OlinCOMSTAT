function flag = enumsToBitflag(Enums)
    flag = 0;
    shift = 0;
    
    for i = 1:length(Enums)
        enum = Enums{i};
        meta = metaclass(enum);
        n = length(meta.EnumeratedValues);
        
        name = char(enum);
        for j = 1:n
            if strcmp(meta.EnumeratedValues{j}.Name, name), break, end
        end
        
        flag = bitor(flag, bitshift(1, shift + (j - 1)));
        shift = shift + n;
    end
end