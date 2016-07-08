function plotmap(listname,conntype,measure,bandidx,varargin)

param = finputcheck(varargin, {
    'group', 'string', [], 'crsdiag'; ...
    'groupnames', 'cell', {}, {'UWS','MCS-','MCS+','EMCS','LIS','CTR'}; ...
    'changroup', 'string', [], 'all'; ...
    'changroup2', 'string', [], 'all'; ...
    'xlabel', 'string', [], ''; ...
    'ylabel', 'string', [], measure; ...
    'xlim', 'real', [], []; ...
    'ylim', 'real', [], []; ...
    'xtick', 'real', [], []; ...
    'ytick', 'real', [], []; ...
    'legend', 'string', {'on','off'}, 'off'; ...
    'legendlocation', 'string', [], 'Best'; ...
    'noplot', 'string', {'on','off'}, 'off'; ...
    'plotcm', 'string', {'on','off'}, 'off'; ...
    });

fontname = 'Helvetica';
fontsize = 22;

loadpaths
loadsubj
changroups

load sortedlocs

subjlist = eval(listname);
refdiag = cell2mat(subjlist(:,2));
crsdiag = cell2mat(subjlist(:,3));
crsaware = double(cell2mat(subjlist(:,3)) > 0);
petdiag = cell2mat(subjlist(:,4));
tennis = cell2mat(subjlist(:,5));
etiology = cell2mat(subjlist(:,6));
daysonset = cell2mat(subjlist(:,9));
outcome = double(cell2mat(subjlist(:,10)) > 2);
outcome(isnan(cell2mat(subjlist(:,10)))) = NaN;
mcstennis = tennis .* crsdiag;
mcstennis(crsdiag == 0) = NaN;
crs = cell2mat(subjlist(:,11));

groupvar = eval(param.group);

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

groupnames = param.groupnames;
weiorbin = 3;

if strcmpi(measure,'power')
    %     load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype));
    load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype),'bandpower');
    testdata = squeeze(bandpower(:,bandidx,:)) * 100;
else
    plotqt = 0.3;
    load(sprintf('%s%s//graphdata_%s_%s.mat',filepath,conntype,listname,conntype),'graph','tvals');
    plotqt = find(abs(tvals - plotqt) == min(abs(tvals - plotqt)),1,'first');
    
    m = find(strcmpi(measure,graph(:,1)));
    if strcmpi(measure,'centrality')
        testdata = squeeze(max(graph{m,weiorbin}(:,bandidx,plotqt,:),[],4));
    elseif strcmpi(measure,'participation coefficient')
        testdata = squeeze(graph{m,weiorbin}(:,bandidx,plotqt,:));
    end
end

bands = {
    'delta'
    'theta'
    'alpha'
    'beta'
    'gamma'
    };

groups = unique(groupvar(~isnan(groupvar)));


% grouplist = {
%     '29'
%     '38'
%     '71'
%     };

for g = 1:length(groups)
    groupmap = squeeze(mean(testdata(groupvar == groups(g),:),1));
    figure; topoplot(groupmap,sortedlocs,'maplimits',[0.4 0.65]); colorbar
    figname = sprintf('figures/map_%s_%s',measure,groupnames{g});
    set(gcf,'Name',figname,'Color','white');
    print(gcf,[figname '.tif'],'-dtiff','-r200');
    close(gcf);
end