function [wnotes, top_retrace, amp_retrace, phase_retrace, ...
    zsens_retrace, top_trace, amp_trace, phase_trace, ...
    zsens_trace] = ibwImp(path)
    
%Importing Igor file
Data = IBWread(path);

%Creating a cell arrayof wave notes. Useful while searching for AFM scan
%variables.
temp = splitlines(Data.WaveNotes);
for i = 1:length(temp)
    temp2{i} = strsplit(temp{i},':');
    wnotes{i,1} = temp2{i}{1};
    wnotes{i,2} = temp2{i}{end};
end

%Splitting AFM images into different matices
images = Data.y;
[~, ~, c] = size(images);
[a, b] = size(squeeze(Data.y(:,:,1)'));
switch c
    case 8  %Trace & Retrace
        top_trace = squeeze(Data.y(:,:,1))';
        top_retrace = squeeze(Data.y(:,:,2))';
        
        amp_trace = squeeze(Data.y(:,:,3))';
        amp_retrace = squeeze(Data.y(:,:,4))';
        
        phase_trace = squeeze(Data.y(:,:,5))';
        phase_retrace = squeeze(Data.y(:,:,6))';
        
        zsens_trace = squeeze(Data.y(:,:,7))';
        zsens_retrace = squeeze(Data.y(:,:,8))';
    case 4  %Retarce only
        top_retrace = squeeze(Data.y(:,:,1))';
        top_trace = zeros(a,b);
        
        amp_retrace = squeeze(Data.y(:,:,2))';
        amp_trace = zeros(a,b);
        
        phase_retrace = squeeze(Data.y(:,:,3))';
        phase_trace = zeros(a,b);
        
        zsens_retrace = squeeze(Data.y(:,:,4))';
        zsens_trace = zeros(a,b);     
    otherwise
        top_trace = zeros(a,b); 
        top_retrace = zeros(a,b); 
        
        amp_trace = zeros(a,b); 
        amp_retrace = zeros(a,b); 
        
        phase_trace = zeros(a,b); 
        phase_retrace = zeros(a,b); 
        
        zsens_trace = zeros(a,b); 
        zsens_retrace = zeros(a,b); 
end

fclose all;

end