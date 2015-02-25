function [penalities, n_orders, n_plans_recycled] = read_output(map, sizer, sizec)
    
    % data
    data = zeros(sizer,sizec);

    fid = fopen(sprintf('%i_output.txt',map));
    tline = fgetl(fid);
    
    r = 1;
    while ischar(tline)
        comm = strfind(tline, '//');
        if ((~isempty(comm) && comm == 1) || isempty(tline))

        else
            split = strsplit(tline,':');
            for col=1:6
                val = split(col);
                doub = str2double(val{1});
                data(r,col) = doub;
            end
            r = r+1;
        end
        tline = fgetl(fid);
    end

    fclose(fid);
    
    n_orders = data(:,5);
    n_plans_recycled = data(:,6);
    penalities = data(:,1:4);

end