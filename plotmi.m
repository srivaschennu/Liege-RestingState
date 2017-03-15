function plotmi(listname,conntype,bandidx,varargin)

loadpaths

param = finputcheck(varargin, {
    'group', 'string', [], 'crsdiag'; ...
    'groupnames', 'cell', {}, {'UWS','MCS-','MCS+','EMCS','LIS','CTRL'}; ...
    'clim', 'real', [], []; ...
    'renderer', 'string', {'painters','opengl'}, 'painters'; ...
    'colorbar', 'string', {'on','off'}, 'on'; ...
    });

fontname = 'Helvetica';
fontsize = 28;

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

weiorbin = 3;
trange = [0.9 0.1];
trange = (tvals <= trange(1) & tvals >= trange(2));

bands = {
    'Delta'
    'Theta'
    'Alpha'
    'Beta'
    'Gamma'
    };

mutinfo = graph{strcmpi('mutual information',graph(:,1)),weiorbin};

groups = unique(groupvar);

figure('Color','white'); hold all
plotdata = mean(mutinfo(:,:,bandidx,trange),4);
imagesc(plotdata);
colormap(jet);
[groupvar, sortidx] = sort(groupvar);
plotdata = plotdata(sortidx,sortidx);

if ~isempty(param.clim)
    caxis(param.clim);
end

for g = 1:length(groups)-1
    groupedge(g) = find(groupvar == groups(g),1,'last');
    line([groupedge(g)+0.5 groupedge(g)+0.5],ylim,'Color','black','LineWidth',3);
    line(xlim,[groupedge(g)+0.5 groupedge(g)+0.5],'Color','black','LineWidth',3);
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

if strcmp(param.colorbar,'on')
    colorbar
end

set(gca,'FontName',fontname,'FontSize',fontsize,'XTick',[],'YTick',[],...
    'XLim',[0.5 size(plotdata,1)+0.5],'YLim',[0.5 size(plotdata,2)+0.5],'YDir','reverse');

export_fig(gcf,sprintf('figures/NMImap_%s.eps',bands{bandidx}),sprintf('-%s',param.renderer));

close(gcf);