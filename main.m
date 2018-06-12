%Define folder that we keep experiment data
path = 'IbwFiles';
directory = dir(path);

count = 0;
for i = 1:length(directory)
    f_name = directory(i).name;
        if directory(i).isdir
        %do nothing
        elseif strcmp(f_name(end-3:end),'.ibw')
            count = count + 1;
            sloc = sprintf('Images\\%s',f_name(1:end-4));
            ibwHandler([path '/' f_name],sloc);
        end
end