function plotftspec(basename,freqlist)

loadpaths

bands = {
    'delta'
    'theta'
    'alpha'
    'beta'
    'gamma'
    };

fontname = 'Helvetica';
fontsize = 28;
xlim = [0.01 40];
ylim = [-30 15];

if exist('freqlist','var') && ~isempty(freqlist)
    save([filepath basename 'spectra.mat'],'freqlist','-append');
else
    specinfo = load([filepath basename 'spectra.mat']);
    fprintf('freqlist = %s\n',mat2str(specinfo.freqlist));
end

specinfo = load([filepath basename 'spectra.mat']);
figure('Name',basename,'Color','white'); hold all
plot(specinfo.freqs,10*log10(specinfo.spectra'),'LineWidth',1);
set(gca,'XLim',xlim,'YLim',ylim,'FontSize',fontsize,'FontName',fontname);
xlabel('Frequency (Hz)','FontSize',fontsize,'FontName',fontname);
ylabel('Power (dB)','FontSize',fontsize,'FontName',fontname);
ylimits = ylim;
for f = 1:size(specinfo.freqlist,1)
    line([specinfo.freqlist(f,1) specinfo.freqlist(f,1)],ylim,'LineWidth',1,...
        'LineStyle','-.','Color','black');
    line([specinfo.freqlist(f,2) specinfo.freqlist(f,2)],ylim,'LineWidth',1,...
        'LineStyle','-.','Color','black');
    text(specinfo.freqlist(f,1),ylimits(2),...
        sprintf('\\%s',bands{f}),'FontName',fontname,'FontSize',fontsize);
end
box on

export_fig(gcf,sprintf('figures/%s_spec.eps',basename));
close(gcf);