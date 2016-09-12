function plotcorr(listname,conntype,bandidx,varargin)

param = finputcheck(varargin, {
    'xlim', 'real', [], []; ...
    'ylim', 'real', [], []; ...
    'legendlocation', 'string', [], 'Best'; ...
    });

fontname = 'Helvetica';
fontsize = 28;

loadpaths
loadsubj

bands = {
    'delta'
    'theta'
    'alpha'
    'beta'
    'gamma'
    };

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

load sortedlocs

load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype));
load(sprintf('%s%s/%s_%s_corr.mat',filepath,conntype,listname,bands{bandidx}));
subjlist = eval(listname);

poscorr = allcorr;
poscorr(allcorr < 0) = 0;
posp = allp;
posp(allcorr < 0) = 1;

stats.alpha = 0.05;
stats.N = size(allcoh,3);
stats.size = 'extent';
stats.thresh = min(poscorr(1,posp(1,:)<stats.alpha));
stats.test_stat = poscorr;

[~,n_nets,netmask,netpval] = evalc('NBSstats(stats)');
corrmat = zeros(size(allcoh,3),size(allcoh,4));
ind_upper = find(triu(ones(size(allcoh,3),size(allcoh,4)),1))';
corrmat(ind_upper) = poscorr(1,:);
corrmat(~netmask{1}) = 0;
meancorr = mean(corrmat(logical(netmask{1})));
corrmat = triu(corrmat,1)+triu(corrmat,1)';

corrp = zeros(size(allcoh,3),size(allcoh,4));
corrp(ind_upper) = posp(1,:);
corrp = triu(corrp,1)+triu(corrp,1)';

%% plot 3d graph
plotgraph3d(corrmat,sortedlocs,'sortedlocs.spl','plotqt',0,'vscale',[0 0.12]);

set(gcf,'Name',sprintf('group %s: %s band',listname,bands{bandidx}));
camva(8);
camtarget([-9.7975  -28.8277   41.8981]);
campos([-1.7547    1.7161    1.4666]*1000);
camzoom(1.2);
set(gcf,'InvertHardCopy','off');
print(gcf,sprintf('figures/crscorr3d_%s_%s.tif',listname,bands{bandidx}),'-dtiff','-r200');
close(gcf);

%% correlate with CRS-R
crs = cell2mat(subjlist(:,11));
testdata = median(allcoh(:,bandidx,logical(netmask{1})),3);
tennis = cell2mat(subjlist(:,5));
crsdiag = cell2mat(subjlist(:,3));

datatable = sortrows(cat(2,crs,testdata,tennis,crsdiag),2);
% mdl = fitlm(datatable(:,2),datatable(:,1),'RobustOpts','on');
pointsize = 50;
figure('Color','white');
hold all

groups = unique(crsdiag);
for g = 1:length(groups)
    legendoff(scatter(datatable(datatable(:,4) == groups(g),2), ...
        datatable(datatable(:,4) == groups(g),1),pointsize,...
        colorlist(g,:),'MarkerFaceColor',facecolorlist(g,:)));
end

% b = mdl.Coefficients.Estimate;
% plot(datatable(:,2),b(1)+b(2)*datatable(:,2),'--','Color','black','LineWidth',1, ...
%     'Display',sprintf('\\rho = %.1f, p = %.3f',meancorr,netpval));

fprintf('Mean rho = %.3f, p = %.3f.\n',meancorr,netpval);

set(gca,'FontName',fontname,'FontSize',fontsize);
if ~isempty(param.ylim)
    set(gca,'YLim',param.ylim);
end
if ~isempty(param.xlim)
    set(gca,'XLim',param.xlim);
end

xlabel('Median dwPLI','FontName',fontname,'FontSize',fontsize);
ylabel('CRS-R score','FontName',fontname,'FontSize',fontsize);

leg_h = legend('show');
set(leg_h,'Location',param.legendlocation);
txt_h = findobj(leg_h,'type','text');
set(txt_h,'FontSize',fontsize-4)
legend('boxoff');

export_fig(gcf,sprintf('figures/%s_crscorr_%s_dwPLI.eps',conntype,bands{bandidx}));
close(gcf);