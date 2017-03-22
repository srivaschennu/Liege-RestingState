function plotmi(listname,conntype,bandidx,varargin)

loadpaths

measure = 'mutual information';

param = finputcheck(varargin, {
    'group', 'string', [], 'crsdiag'; ...
    'groupnames', 'cell', {}, {'UWS','MCS-','MCS+','EMCS','LIS','CTRL'}; ...
    'renderer', 'string', {'painters','opengl'}, 'painters'; ...
    'colorbar', 'string', {'on','off'}, 'on'; ...
    'clim', 'real', [], []; ...
    'xlabel', 'string', [], ''; ...
    'ylabel', 'string', [], measure; ...    
    'ylim', 'real', [], []; ...
    'ytick', 'real', [], []; ...    
    'legend', 'string', {'on','off'}, 'off'; ...    
    });

fontname = 'Helvetica';
fontsize = 20;


colorlist = [
    0 0.0 0.5
    0 0.5 0
    0.5 0.0 0
    0   0.5 0.5
    0.5 0   0.5
    0.5 0.5 0
    ];

facecolorlist = [
    0.75  0.75 1
    0.25 1 0.25
    1 0.75 0.75
    0.75 1 1
    1 0.75 1
    1 1 0.5
    ];

load(sprintf('%s/%s/graphdata_%s_%s.mat',filepath,conntype,listname,conntype));

loadsubj
subjlist = eval(listname);

refdiag = cell2mat(subjlist(:,2));
refaware = double(cell2mat(subjlist(:,2)) > 0);
refaware(isnan(refdiag)) = NaN;
crsdiag = cell2mat(subjlist(:,3));
crsaware = double(cell2mat(subjlist(:,3)) > 0);
petdiag = cell2mat(subjlist(:,4));
tennis = cell2mat(subjlist(:,5));
etiology = cell2mat(subjlist(:,6));
daysonset = cell2mat(subjlist(:,9));
outcome = double(cell2mat(subjlist(:,10)) > 2);
outcome(isnan(cell2mat(subjlist(:,10)))) = NaN;
vsoutcome = double(cell2mat(subjlist(:,10)) > 2);
vsoutcome(isnan(cell2mat(subjlist(:,10)))) = NaN;
vsoutcome(crsaware > 0) = NaN;
mcsoutcome = double(cell2mat(subjlist(:,10)) > 2);
mcsoutcome(isnan(cell2mat(subjlist(:,10)))) = NaN;
mcsoutcome(crsaware == 0) = NaN;
mcstennis = tennis .* crsdiag;
mcstennis(crsdiag == 0) = NaN;
crs = cell2mat(subjlist(:,11));

admvscrs = NaN(size(refdiag));
admvscrs(refaware == 0) = 0;
admvscrs(refaware == 0 & crsaware == 0) = 0;
admvscrs(refaware > 0 & crsaware > 0) = 1;
admvscrs(refaware == 0 & crsaware > 0) = 2;

groupvar = eval(param.group);
groups = unique(groupvar(~isnan(groupvar)));

weiorbin = 3;
trange = [0.9 0.1];
trange = (tvals <= trange(1) & tvals >= trange(2));
groupnames = param.groupnames;

bands = {
    'Delta'
    'Theta'
    'Alpha'
    'Beta'
    'Gamma'
    };


mutinfo = graph{strcmpi('mutual information',graph(:,1)),weiorbin};

mutinfo(mutinfo <= 0) = NaN;
plotdata = nanmean(mutinfo(:,:,bandidx,trange),4);
[groupvar, sortidx] = sort(groupvar);
plotdata = plotdata(sortidx,sortidx);

testdata = [];
for g = 1:length(groups)
    testdata = cat(1,testdata,nanmean(plotdata(groupvar == groups(g),groupvar == groups(g)),2));
end

figure('Color','white');
figpos = get(gcf,'Position');
if length(groups) == 2
    figpos(3) = figpos(3)*1/2;
elseif length(groups) == 3
    figpos(3) = figpos(3)*2/3;
end
set(gcf,'Position',figpos);

hold all

boxh = notBoxPlot(nanmean(testdata,2),groupvar+1,0.5,'patch',ones(size(testdata,1),1));

for h = 1:length(boxh)
    set(boxh(h).data,'Color',colorlist(h,:),'MarkerFaceColor',facecolorlist(h,:))
end

set(gca,'XLim',[0.5 length(groups)+0.5],'XTick',1:length(groups),...
    'XTickLabel',groupnames','FontName',fontname,'FontSize',fontsize);
ylabel(param.ylabel,'FontName',fontname,'FontSize',fontsize);
if ~isempty(param.ylim)
    set(gca,'YLim',param.ylim);
end
if ~isempty(param.ytick)
    set(gca,'YTick',param.ytick);
end
set(gcf,'Color','white');
if ~isempty(param.ylim)
    ylim(param.ylim);
end
if strcmp(param.legend,'off')
    legend('hide');
end
box off
export_fig(gcf,sprintf('figures/%s_avg_%s_%s_%s.tiff',conntype,measure,bands{bandidx},param.group),'-r300','-p0.01');
close(gcf);

if length(groups) > 2
    jttestdata = nanmean(testdata(groupvar < 5,:),2);
    jtgroupvar = groupvar(groupvar < 5) + 1;
    [jtgroupvar,sortidx] = sort(jtgroupvar);
    jttestdata = jttestdata(sortidx);
    [~,JT,pval] = evalc('jttrend([jttestdata jtgroupvar])');
    if pval < 0.0001
        fprintf('\nJonckheere-Terpstra JT = %.2f, p = %.1e.\n',JT,pval);
    else
        fprintf('\nJonckheere-Terpstra JT = %.2f, p = %.4f.\n',JT,pval);
    end
end

figure('Color','white'); hold all
imagesc(plotdata); axis square
colormap(jet);

groups = unique(groupvar);

for g = 1:length(groups)-1
    groupedge(g) = find(groupvar == groups(g),1,'last');
    line([groupedge(g)+0.5 groupedge(g)+0.5],ylim,'Color','magenta','LineWidth',1.5);
    line(xlim,[groupedge(g)+0.5 groupedge(g)+0.5],'Color','magenta','LineWidth',1.5);
end
groupedge = [0 groupedge size(plotdata,1)];
% for g = 1:length(groupedge)-1
%     line([groupedge(g)+0.5 groupedge(g)+0.5],[groupedge(g)+0.5 groupedge(g+1)+0.5],'Color','red','LineWidth',6);
%     line([groupedge(g)+0.5 groupedge(g+1)+0.5],[groupedge(g+1)+0.5 groupedge(g+1)+0.5],'Color','red','LineWidth',6);
%    line([groupedge(g+1)+0.5 groupedge(g+1)+0.5],[groupedge(g)+0.5 groupedge(g+1)+0.5],'Color','red','LineWidth',6);
%    line([groupedge(g)+0.5 groupedge(g+1)+0.5],[groupedge(g)+0.5 groupedge(g)+0.5],'Color','red','LineWidth',6);

%    line([groupedge(g)+0.5 groupedge(g+1)+0.5],[groupedge(g)+0.5 groupedge(g+1)+0.5],'Color','red','LineWidth',6);
    
%     if bandidx == 3 && g < 3
%         line([groupedge(g)+0.5 groupedge(g+1)+0.5],[groupedge(end)+0.5 groupedge(end)+0.5],'Color','magenta','LineWidth',6);
%         line([groupedge(g)+0.5 groupedge(g+1)+0.5],[groupedge(end-1)+0.5 groupedge(end-1)+0.5],'Color','magenta','LineWidth',6);
%         line([groupedge(g)+0.5 groupedge(g)+0.5],[groupedge(end-1)+0.5 groupedge(end)+0.5],'Color','magenta','LineWidth',6);
%         line([groupedge(g+1)+0.5 groupedge(g+1)+0.5],[groupedge(end-1)+0.5 groupedge(end)+0.5],'Color','magenta','LineWidth',6);
%     end
% end

if ~isempty(param.clim)
    caxis(param.clim);
end

if strcmp(param.colorbar,'on')
    colorbar('NorthOutside','FontName',fontname,'FontSize',fontsize);
end

set(gca,'FontName',fontname,'FontSize',fontsize,'XTick',[],'YTick',[],...
    'XLim',[0.5 size(plotdata,1)+0.5],'YLim',[0.5 size(plotdata,2)+0.5],'YDir','reverse');

export_fig(gcf,sprintf('figures/NMImap_%s.eps',bands{bandidx}),sprintf('-%s',param.renderer));

close(gcf);