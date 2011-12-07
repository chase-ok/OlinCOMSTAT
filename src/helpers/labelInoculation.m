function label = labelInoculation(rs)
    if isempty(rs.Results)
        label = '';
        return
    end
    
    inoc = rs.Results(1).settings.innoculation;
    split = find(inoc == '.');
    day = inoc((split + 1):end);
    
    switch inoc(1:(split - 1))
        case '1', month = 'Jan';
        case '2', month = 'Feb';
        case '3', month = 'Mar';
        case '4', month = 'Apr';
        case '5', month = 'May';
        case '6', month = 'Jun';
        case '7', month = 'Jul';
        case '8', month = 'Aug';
        case '9', month = 'Sep';
        case '10', month = 'Oct';
        case '11', month = 'Nov';
        case '12', month = 'Dec';
            
        otherwise, error(['Incorrect inoculation day: ' inoc]);
    end
    
    label = [month ' ' day];
end