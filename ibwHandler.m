function [] = ibwHandler(file,path)
%This functions reads and AFM experiment ibw file; calculates and exports 
%energy dissipation to a folder as 2D graph.


%Creating export folder
mkdir(path);

[wnotes, top_retrace, amp_retrace, phase_retrace, ~, ...
    top_trace, amp_trace, phase_trace, ~] = ibwImp(file);


%Get scan points during experiment
tmp = strfind(wnotes, 'ScanPoints');
tmp = find(~cellfun(@isempty,tmp));
scan.points = str2num(wnotes{tmp(1),2});

%Get scan size of the experiment
tmp = strfind(wnotes, 'Initial ScanSize');
tmp = find(~cellfun(@isempty,tmp));
scan.size = str2num(wnotes{tmp(1),2}) * 10^6; %microns

[a b] = size(phase_trace);

if a > b
    y = linspace(0,scan.size,a);
    x = linspace(0,scan.size*(b/a),b);
elseif b > a
    y = linspace(0,scan.size*(a/b),a);
    x = linspace(0,scan.size,b);
else
    y = linspace(0,scan.size,a);
    x = linspace(0,scan.size,b);
end


%Get InvOLS of the experiment
tmp = strfind(wnotes, 'AmpInvOLS');
tmp = find(~cellfun(@isempty,tmp));
scan.amp_inVOLS = str2num(wnotes{tmp(1),2});


%Get Free oscillation amplitude of the experiment
tmp = strfind(wnotes, 'FreeAirAmplitude');
tmp = find(~cellfun(@isempty,tmp));
scan.freeosc = str2num(wnotes{tmp(1),2}) * scan.amp_inVOLS * (10^-9);

%Get Q factor of the cantilever.
tmp = strfind(wnotes, 'TuneQResult');
tmp = find(~cellfun(@isempty,tmp));
scan.Q = str2num(wnotes{tmp(1),2});

%Get spring constant of the cantilever
tmp = strfind(wnotes, 'SpringConstant');
tmp = find(~cellfun(@isempty,tmp));
scan.k = str2num(wnotes{tmp(1),2});

%Get free oscillation phase
tmp = strfind(wnotes, 'FreeAirPhase');
tmp = find(~cellfun(@isempty,tmp));
scan.freePhase = str2num(wnotes{tmp(1),2});

%Get natural frequency of the cantilever
tmp = strfind(wnotes, 'TuneFreqResult');
tmp = find(~cellfun(@isempty,tmp));
scan.f0 = str2num(wnotes{tmp(1),2});

%Get drive frequency of the experiment
tmp = strfind(wnotes, 'DriveFrequency');
tmp = find(~cellfun(@isempty,tmp));
scan.f = str2num(wnotes{tmp(1),2});





%Here we calculate the dissipated energy.
%   doi: 10.1063/1.122632
%   doi: 10.1063/1.121434


phase_shift_retrace = scan.freePhase - phase_retrace;
phase_shift_trace = scan.freePhase - phase_trace;


E_air_rt = (scan.f / scan.f0) * (amp_retrace / scan.freeosc);
E_dis_rt = (pi * scan.k * scan.freeosc * amp_retrace / scan.Q) .* ...
   (sind(phase_shift_retrace) - E_air_rt);
E_dis_rt = E_dis_rt * 6.242 * (10 ^ 18);


E_air_t = (scan.f / scan.f0) * (amp_trace / scan.freeosc);
E_dis_t = (pi * scan.k * scan.freeosc * amp_trace / scan.Q) .* ...
   (sind(phase_shift_trace) - E_air_t);
E_dis_t = E_dis_t * 6.242 * (10 ^ 18);


%Plotting and exporting figures

top_retrace = top_retrace - mean(mean(top_retrace));
srf(y,x,top_retrace * 10^6);
xlabel('X Position (\mum)','Fontsize',15);
ylabel('Y Position (\mum)','Fontsize',15);
h = colorbar;
ylabel(h, 'Topography(\mum)','Fontsize',15)
t=get(h,'Limits'); t = round(t/0.5)*0.5; caxis(t);
title('Topography (Retrace)','Fontsize',20)
print([path '/topography-retrace'],'-dpng','-r600')

top_trace = top_trace - mean(mean(top_trace));
srf(y,x,top_trace * 10^6);
xlabel('X Position (\mum)','Fontsize',15);
ylabel('Y Position (\mum)','Fontsize',15);
h = colorbar;
ylabel(h, 'Topography(\mum)','Fontsize',15)
t=get(h,'Limits'); t = round(t/0.5)*0.5; caxis(t);
title('Topography (Trace)','Fontsize',20)
print([path '/topography-trace'],'-dpng','-r600')

srf(y,x,E_dis_rt);
xlabel('X Position (\mum)','Fontsize',15);
ylabel('Y Position (\mum)','Fontsize',15);
h = colorbar;
ylabel(h, 'Dissipation(eV)','Fontsize',15)
caxis([mean(mean(E_dis_rt))-std2(E_dis_rt)*2 ...
    mean(mean(E_dis_rt))+std2(E_dis_rt)*2]);
t=get(h,'Limits'); t = round(t/0.5)*0.5; caxis(t);
title('Dissipation (Retrace)','Fontsize',20)
print([path '/dissipation-retrace'],'-dpng','-r600')
savefig([path '/dissipation-retrace'])

srf(y,x,E_dis_t);
xlabel('X Position (\mum)','Fontsize',15);
ylabel('Y Position (\mum)','Fontsize',15);
h = colorbar;
ylabel(h, 'Dissipation(eV)','Fontsize',15)
caxis([mean(mean(E_dis_t))-std2(E_dis_t)*2 ...
    mean(mean(E_dis_t))+std2(E_dis_t)*2]);
t=get(h,'Limits'); t = round(t/0.5)*0.5; caxis(t);
title('Dissipation (Trace)','Fontsize',20)
print([path '/dissipation-trace'],'-dpng','-r600')
savefig([path '/dissipation-trace'])

srf(y,x,amp_retrace * 10^9);
xlabel('X Position (\mum)','Fontsize',15);
ylabel('Y Position (\mum)','Fontsize',15);
h = colorbar;
ylabel(h, 'Amplitude(nm)','Fontsize',15)
caxis([mean(mean(amp_retrace))-std2(amp_retrace)*2 ...
    mean(mean(amp_retrace))+std2(amp_retrace)*2]*(10^9));
t=get(h,'Limits'); t = round(t/0.5)*0.5; caxis(t);
title('Amplitude (Retrace)','Fontsize',20)
print([path '/amplitude-retrace'],'-dpng','-r600')


srf(y,x,amp_trace * 10^9);
xlabel('X Position (\mum)','Fontsize',15);
ylabel('Y Position (\mum)','Fontsize',15);
h = colorbar;
ylabel(h, 'Amplitude(nm)','Fontsize',15)
caxis([mean(mean(amp_trace))-std2(amp_trace)*2 ...
    mean(mean(amp_trace))+std2(amp_trace)*2]*(10^9));
t=get(h,'Limits'); t = round(t/0.5)*0.5; caxis(t);
title('Amplitude (Trace)','Fontsize',20)
print([path '/amplitude-trace'],'-dpng','-r600')


srf(y,x,phase_retrace);
xlabel('X Position (\mum)','Fontsize',15);
ylabel('Y Position (\mum)','Fontsize',15);
h = colorbar;
ylabel(h, 'Phase(nm)','Fontsize',15)
caxis([mean(mean(phase_retrace))-std2(phase_retrace)*1.5 ...
    mean(mean(phase_retrace))+std2(phase_retrace)*1.5]);
t=get(h,'Limits'); t = round(t/0.5)*0.5; caxis(t);
title('Phase (Retrace)','Fontsize',20)
print([path '/phase-retrace'],'-dpng','-r600')


srf(y,x,phase_trace);
xlabel('X Position (\mum)','Fontsize',15);
ylabel('Y Position (\mum)','Fontsize',15);
h = colorbar;
ylabel(h, 'Phase(nm)','Fontsize',15)
caxis([mean(mean(phase_trace))-std2(phase_trace)*1.5 ...
    mean(mean(phase_trace))+std2(phase_trace)*1.5]);
t=get(h,'Limits'); t = round(t/0.5)*0.5; caxis(t);
title('Phase (Trace)','Fontsize',20)
print([path '/phase-trace'],'-dpng','-r600')

%Saving data
save([path '/data'])

end


