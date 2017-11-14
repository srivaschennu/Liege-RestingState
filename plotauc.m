function plotauc(varargin)

param = finputcheck(varargin, {
    'group', 'string', [], 'crsdiag'; ...
    'groupnames', 'cell', {}, {'UWS','MCS-','MCS+','EMCS','LIS','CTRL'}; ...
    'pairlist' 'real', [], [1 6 10]; ...
    'grouppairs' 'real', [], []; ...
    'xlim', 'real', [], []; ...
    'nonsig', 'string', {'on','off'}, 'on'; ...
    'plotcm', 'string', {'on','off'}, 'off'; ...
    'xlabel', 'string', [], ''; ...
    'ylabel', 'string', [], ''; ...
    'alpha', 'real', [], 0.05; ...
    'prefix', 'string', {'anoxic_','tbi_',''}, ''; ...
    });

if ~isstruct(param)
    error('Incorrect parameters specified.');
end

bands = {
    'delta'
    'theta'
    'alpha'
    };

groups = 0:length(param.groupnames)-1;
if isempty(param.grouppairs)
    grouppairs = [
        0 1
        1 2
        2 3
        ];
else
    grouppairs = param.grouppairs;
end

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
    1 1 0.75
    ];

fontname = 'Helvetica';
fontsize = 20;

load(sprintf('stats_%s%s.mat',param.prefix,param.group),'stats','featlist');

if size(stats,2) > 2
    stats = stats(:,param.pairlist);
end

if size(stats,2) == 1
    colorlist = [
        0 0 0
        ];
    facecolorlist = [
        0.75 0.75 0.75
        ];
end

p_thresh = fdr(cell2mat({stats.pval}),param.alpha);
p_thresh = 0.05;

figure('Color','white');
figpos = get(gcf,'Position');
figpos(3) = figpos(3)*2;
figpos(4) = figpos(4)*2;
set(gcf,'Position',figpos);

markersizes = [100 275];
hold all
for g = 1:size(stats,2)
    grouppairnames{g} = sprintf('%s / %s',param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1});
end

for f = 1:size(stats,1)
    if strcmp(param.nonsig,'on')
        legendoff(line([0.5 max(cell2mat({stats(f,:).auc}))],[f f],'LineWidth',0.5,'Color',[0.5 0.5 0.5]));
    elseif  strcmp(param.nonsig,'off') && sum(cell2mat({stats(f,:).pval}) < p_thresh) > 0
        legendoff(line([0.5 max(cell2mat({stats(f,cell2mat({stats(f,:).pval}) < p_thresh).auc}))],[f f],'LineWidth',0.5,'Color',[0.5 0.5 0.5]));
    end
    for g = 1:size(stats,2)
        if stats(f,g).pval >= p_thresh
            markersize = markersizes(1);
        else
            markersize = markersizes(2);
        end
        if f == 1
            sc_h(f,g) = scatter(stats(f,g).auc,f,markersize,...
                'MarkerFaceColor',facecolorlist(g,:),'MarkerEdgeColor',colorlist(g,:),'LineWidth',1.5);
        else
            sc_h(f,g) = legendoff(scatter(stats(f,g).auc,f,markersize,...
                'MarkerFaceColor',facecolorlist(g,:),'MarkerEdgeColor',colorlist(g,:),'LineWidth',1.5));
        end
    end
end

set(gca,'FontName',fontname,'FontSize',fontsize,'YDir','reverse');
if isempty(param.xlim)
    xlim([0.5 1]);
else
    xlim(param.xlim);
end
xlabel('Area Under the Curve','FontName',fontname,'FontSize',fontsize);
ylim([0 size(stats,1)+1]);
set(gca,'YTick',1:size(stats,1),'YTickLabel',featlist(:,end));

if strcmp(param.nonsig,'off')
    for f = 1:size(stats,1)
        for g = 1:size(stats,2)
            if stats(f,g).pval >= p_thresh
                set(sc_h(f,g),'MarkerFaceColor','none','MarkerEdgeColor','none');
            end
        end
    end
end

[~,icons] = legend(grouppairnames,'Location','SouthOutside','Orientation','Horizontal','box','off');
for g = 1:size(stats,2)
    set(icons(g),'FontName',fontname,'FontSize',fontsize-2);
end
for g = 1:size(stats,2)
    set(icons(g+size(stats,2)).Children,'MarkerSize',14,'MarkerFaceColor',facecolorlist(g,:),'MarkerEdgeColor',colorlist(g,:));
end

export_fig(sprintf('figures/auc_%s%s.tiff',param.prefix,param.group),'-r200','-p0.01');
close(gcf);

%% plot confusion matrix of best classifier

if strcmp(param.plotcm,'on')
    fontsize = fontsize + 10;
    for g = 1:size(stats,2)
        [~,bestauc] = max(cell2mat({stats(:,g).auc}));
        
        fprintf('%s %s - %s vs %s: AUC = %.2f, p = %.5f, Chi2 = %.2f, Chi2 p = %.1e, accu = %d%%.\n',...
            featlist{bestauc,2},bands{featlist{bestauc,3}},param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1},...
            stats(bestauc,g).auc,stats(bestauc,g).pval,stats(bestauc,g).chi2,stats(bestauc,g).chi2pval,round(stats(bestauc,g).accu));
        
        plotconfusionmat(stats(bestauc,g).confmat,{param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1}});
        set(gca,'FontName',fontname,'FontSize',fontsize+4);
        if ~isempty(param.xlabel)
            xlabel(param.xlabel,'FontName',fontname,'FontSize',fontsize);
        else
            xlabel('EEG prediction','FontName',fontname,'FontSize',fontsize);
        end
        if ~isempty(param.ylabel)
            ylabel(param.ylabel,'FontName',fontname,'FontSize',fontsize);
        else
            ylabel('CRS-R diagnosis','FontName',fontname,'FontSize',fontsize);
        end
        
        export_fig(gcf,sprintf('figures/clsyfyr_%s%s_%s_vs_%s_cm.tiff',param.prefix,param.group,param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1}),'-p0.01');
        close(gcf);
    end
end