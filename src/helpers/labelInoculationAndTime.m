function label = labelInoculationAndTime(rs)
    if isempty(rs.Results)
        label = '';
        return
    end
    time = num2str(rs.Results(1).settings.time);
    label = [labelInoculation(rs) ' - ' time ' days'];
end

