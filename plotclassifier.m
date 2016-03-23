function plotclsyfyr(varargin)

param = finputcheck(varargin, {
    'group', 'string', [], 'crsdiag'; ...
    'groupnames', 'cell', {}, {'UWS','MCS','EMCS','LIS'}; ...
    'alpha', 'real', [], 0.05; ...
    });

featnames = {
    '\delta'
    'Relative power \theta'
    '\alpha'
    '\delta'
    'Median dwPLI \theta'
    '\alpha'
    '\delta'
    'Clustering \theta'
    '\alpha'
    '\delta'
    'Path length \theta'
    '\alpha'
    '\delta'
    'Modularity \theta'
    '\alpha'
    '\delta'
    'Participation coefficient \theta'
    '\alpha'
    '\delta'
    'Modular span \theta'
    '\alpha'
    };

groups = 1:length(param.groupnames);
grouppairs = nchoosek(groups,2);

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
fontsize = 24;

load(sprintf('clsyfyr_%s.mat',param.group));
if size(clsyfyr,2) == 1
    colorlist = [
        0 0 0
        ];
    facecolorlist = [
        0.75 0.75 0.75
        ];
end

p_thresh = fdr(cell2mat({clsyfyr(:).pval}),param.alpha);

figure('Color','white');
figpos = get(gcf,'Position');
figpos(3) = figpos(3)*3;
figpos(4) = figpos(4)*2;
set(gcf,'Position',figpos);

markersizes = [100 300];
hold all
for g = 1:size(clsyfyr,2)
    grouppairnames{g} = sprintf('%s - %s',param.groupnames{grouppairs(g,1)},param.groupnames{grouppairs(g,2)});
end

for f = 1:size(clsyfyr,1)
    legendoff(line([min(cell2mat({clsyfyr(f,:).auc})) max(cell2mat({clsyfyr(f,:).auc}))],[f f],'LineWidth',1,'Color','black'));
    for g = 1:size(clsyfyr,2)
        if clsyfyr(f,g).pval >= p_thresh
            markersize = markersizes(1);
        else
            markersize = markersizes(2);
        end
        if f == 1
            scatter(clsyfyr(f,g).auc,f,markersize,...
                'MarkerFaceColor',facecolorlist(g,:),'MarkerEdgeColor',colorlist(g,:));
        else
            legendoff(scatter(clsyfyr(f,g).auc,f,markersize,...
                'MarkerFaceColor',facecolorlist(g,:),'MarkerEdgeColor',colorlist(g,:)));
        end
    end
end

set(gca,'FontName',fontname,'FontSize',fontsize,'YDir','reverse');
xlim([0.5 1]);
xlabel('AUC','FontName',fontname,'FontSize',fontsize);
ylim([0 size(clsyfyr,1)+1]);
set(gca,'YTick',1:size(clsyfyr,1),'YTickLabel',featnames);

[~,icons] = legend(grouppairnames,'Location','SouthOutside','Orientation','Horizontal','box','off');
for i = 1:length(grouppairnames)
    set(icons(i),'FontName',fontname,'FontSize',fontsize-2);
end
for i = length(grouppairnames)+1:length(icons)
    set(icons(i).Children,'MarkerSize',12);
end
export_fig(sprintf('figures/clsyfyr_%s.tiff',param.group),'-r200');
close(gcf);