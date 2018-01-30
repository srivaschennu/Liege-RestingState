function plotpower(listname,conntype,varargin)

loadpaths
loadsubj

loadsubj
subjlist = eval(listname);

param = finputcheck(varargin, {
    'group', 'string', [], 'crsdiag'; ...
    'groupnames', 'cell', {}, {'UWS','MCS-','MCS+','EMCS','LIS','CTRL'}; ...
    'changroup', 'string', [], 'all'; ...
    'changroup2', 'string', [], 'all'; ...
    'xlabel', 'string', {'on','off'}, 'on'; ...
    'ylabel', 'string', {'on','off'}, 'on'; ...
    'xlim', 'real', [], []; ...
    'ylim', 'real', [], []; ...
    'xtick', 'real', [], []; ...
    'ytick', 'real', [], []; ...
    'legend', 'string', {'on','off'}, 'off'; ...
    'legendlocation', 'string', [], 'Best'; ...
    'noplot', 'string', {'on','off'}, 'off'; ...
    'plotcm', 'string', {'on','off'}, 'off'; ...
    });

refdiag = cell2mat(subjlist(:,2));
refaware = double(cell2mat(subjlist(:,2)) > 0);
refaware(isnan(refdiag)) = NaN;
crsdiag = cell2mat(subjlist(:,3));
crsaware = double(cell2mat(subjlist(:,3)) > 0);
petdiag = cell2mat(subjlist(:,4));
tennis = cell2mat(subjlist(:,5));
etiology = cell2mat(subjlist(:,6));
age = cell2mat(subjlist(:,7));
daysonset = cell2mat(subjlist(:,9));
outcome = double(cell2mat(subjlist(:,10)) > 2);
outcome(isnan(cell2mat(subjlist(:,10)))) = NaN;
anoxicoutcome = double(cell2mat(subjlist(:,10)) > 2);
anoxicoutcome(isnan(cell2mat(subjlist(:,10)))) = NaN;
anoxicoutcome(etiology == 1) = NaN;
tbioutcome = double(cell2mat(subjlist(:,10)) > 2);
tbioutcome(isnan(cell2mat(subjlist(:,10)))) = NaN;
tbioutcome(etiology == 0) = NaN;
mcstennis = tennis .* crsdiag;
mcstennis(crsdiag == 0) = NaN;
crs = cell2mat(subjlist(:,11));

admvscrs = NaN(size(refdiag));
admvscrs(refaware == 0) = 0;
admvscrs(refaware == 0 & crsaware == 0) = 0;
admvscrs(refaware > 0 & crsaware > 0) = 1;
admvscrs(refaware == 0 & crsaware > 0) = 2;

etiooutcome = NaN(size(crsdiag));
etiooutcome(etiology == 0 & outcome == 0) = 0;
etiooutcome(etiology == 0 & outcome == 1) = 1;
etiooutcome(etiology == 1 & outcome == 0) = 2;
etiooutcome(etiology == 1 & outcome == 1) = 3;

tdcs = NaN(size(crsdiag));
tdcssubj = {
'3'  0
'7'  0
'22' 0
'39' 0
'44' 0
'78' 0
'86' 0
'4', 0
'11',0
'21',0
'32',0
'41',0
'48',0
'81',0
'16' 1
'17' 1
'51' 1
'72' 1
'69' 1
'74' 1
'NB_20170518' 1
'VP_20160922' 1
};
for s = 1:size(tdcssubj,1)
    patidx = find(strcmp(tdcssubj{s,1},subjlist(:,1)),1);
    if ~isempty(patidx)
        tdcs(patidx) = tdcssubj{s,2};
    end
end

load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype));
load freqlist

fontname = 'Helvetica';
fontsize = 28;

bands = {
    'Delta'
    'Theta'
    'Alpha'
    'Beta'
    'Gamma'
    };

groupvar = eval(param.group);
groups = unique(groupvar(~isnan(groupvar)));

for g = 1:length(groups)
    %     subplot(1,length(groups),p);
    figure('Color','white');
    plot(freqbins,10*log10(squeeze(mean(spectra(groupvar == groups(g),:,:),1))),'LineWidth',2);
    set(gca,'XLim',[0 40],'YLim',[-25 25],'FontName',fontname,'FontSize',fontsize);
    if strcmp(param.xlabel,'on')
        xlabel('Frequency (Hz)','FontName',fontname,'FontSize',fontsize);
    else
        xlabel(' ','FontName',fontname,'FontSize',fontsize);
        set(gca,'XTick',[]);
    end
    if strcmp(param.ylabel,'on')
        ylabel('Power (dB)','FontName',fontname,'FontSize',fontsize);
    else
        ylabel(' ','FontName',fontname,'FontSize',fontsize);
        set(gca,'YTick',[]);
    end
    if ~isempty(param.xlim)
        xlim(param.xlim);
    end
    if ~isempty(param.ylim)
        ylim(param.ylim);
    end
    for f = 1:4
        line([freqlist(f,1) freqlist(f,1)],ylim,'LineWidth',1,'LineStyle','--','Color','black');
    end
    
    export_fig(gcf,sprintf('figures/%s_spec.tiff',param.groupnames{g}),'-d300','-p0.01');
    close(gcf);
end
