function plotauc(varargin)

param = finputcheck(varargin, {
    'group', 'string', [], 'crsdiag'; ...
    'groupnames', 'cell', {}, {'UWS','MCS','EMCS','LIS'}; ...
    'alpha', 'real', [], 0.05; ...
    'xlim', 'real', [], []; ...
    'nonsig', 'string', {'on','off'}, 'on'; ...
    'plotcm', 'string', {'on','off'}, 'off'; ...
    'xlabel', 'string', [], ''; ...
    'ylabel', 'string', [], ''; ...
    });

bands = {
    'delta'
    'theta'
    'alpha'
    };

featlist = {
    'ftdwpli'    'power'                  [1]    '\delta'
    'ftdwpli'    'power'                  [2]    'Relative power \theta'
    'ftdwpli'    'power'                  [3]    '\alpha'
    'ftdwpli'    'median'                 [1]    '\delta'
    'ftdwpli'    'median'                 [2]    'Median dwPLI \theta'
    'ftdwpli'    'median'                 [3]    '\alpha'
    'ftdwpli'    'clustering'             [1]    '\delta'
    'ftdwpli'    'clustering'             [2]    'Clustering coeff. \theta'
    'ftdwpli'    'clustering'             [3]    '\alpha'
    'ftdwpli'    'characteristic path length'     [1]    '\delta'
    'ftdwpli'    'characteristic path length'     [2]    'Path length \theta'
    'ftdwpli'    'characteristic path length'     [3]    '\alpha'
    'ftdwpli'    'modularity'             [1]    '\delta'
    'ftdwpli'    'modularity'             [2]    'Modularity \theta'
    'ftdwpli'    'modularity'             [3]    '\alpha'
    'ftdwpli'    'participation coefficient'     [1]    '\delta'
    'ftdwpli'    'participation coefficient'     [2]    'Participation coeff. \theta'
    'ftdwpli'    'participation coefficient'     [3]    '\alpha'
    'ftdwpli'    'modular span'           [1]    '\delta'
    'ftdwpli'    'modular span'           [2]    'Modular span \theta'
    'ftdwpli'    'modular span'           [3]    '\alpha'
    };

groups = 0:length(param.groupnames)-1;
groups = groups(groups < 3);
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
fontsize = 20;

for f = 1:size(featlist,1)
    %     load(sprintf('clsyfyrs/clsyfyr_%s_%s_%s_%s.mat',featlist{f,1},featlist{f,2},bands{featlist{f,3}},param.group));
    %     if exist('clsyfyrs','var')
    %         fnlist = fieldnames(clsyfyr);
    %         for fn = 1:length(fnlist)
    %             if ~isfield(clsyfyrs,fnlist{fn})
    %                 clsyfyr = rmfield(clsyfyr,fnlist{fn});
    %             end
    %         end
    %     end
    %     clsyfyrs(f,:) = clsyfyr;
    [~,~,stats] = plotmeasure('patlist',featlist{f,1},featlist{f,2},featlist{f,3},'noplot','on','group',param.group,'groupnames',param.groupnames);
    clsyfyrs(f,:) = stats;
end

if size(clsyfyrs,2) > 3
    clsyfyrs = clsyfyrs(:,[1 2 4]);
end

if size(clsyfyrs,2) == 1
    colorlist = [
        0 0 0
        ];
    facecolorlist = [
        0.75 0.75 0.75
        ];
end

p_thresh = fdr(cell2mat({clsyfyrs(:).pval}),param.alpha);
p_thresh = 0.05;

figure('Color','white');
figpos = get(gcf,'Position');
figpos(3) = figpos(3)*3;
figpos(4) = figpos(4)*2;
set(gcf,'Position',figpos);

markersizes = [100 275];
hold all
for g = 1:size(clsyfyrs,2)
    grouppairnames{g} = sprintf('%s - %s',param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1});
end

for f = 1:size(clsyfyrs,1)
    if strcmp(param.nonsig,'on')
        legendoff(line([0.5 max(cell2mat({clsyfyrs(f,:).auc}))],[f f],'LineWidth',0.5,'Color',[0.5 0.5 0.5]));
    elseif  strcmp(param.nonsig,'off') && sum(cell2mat({clsyfyrs(f,:).pval}) < p_thresh) > 0
        legendoff(line([0.5 max(cell2mat({clsyfyrs(f,cell2mat({clsyfyrs(f,:).pval}) < p_thresh).auc}))],[f f],'LineWidth',0.5,'Color',[0.5 0.5 0.5]));
    end
    for g = 1:size(clsyfyrs,2)
        if clsyfyrs(f,g).pval >= p_thresh
            markersize = markersizes(1);
        else
            markersize = markersizes(2);
        end
        if f == 1
            sc_h(f,g) = scatter(clsyfyrs(f,g).auc,f,markersize,...
                'MarkerFaceColor',facecolorlist(g,:),'MarkerEdgeColor',colorlist(g,:),'LineWidth',1.5);
        else
            sc_h(f,g) = legendoff(scatter(clsyfyrs(f,g).auc,f,markersize,...
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
ylim([0 size(clsyfyrs,1)+1]);
set(gca,'YTick',1:size(clsyfyrs,1),'YTickLabel',featlist(:,end));

if strcmp(param.nonsig,'off')
    for f = 1:size(clsyfyrs,1)
        for g = 1:size(clsyfyrs,2)
            if clsyfyrs(f,g).pval >= p_thresh
                set(sc_h(f,g),'MarkerFaceColor','none','MarkerEdgeColor','none');
            end
        end
    end
end

[~,icons] = legend(grouppairnames,'Location','SouthOutside','Orientation','Horizontal','box','off');
for g = 1:size(clsyfyrs,2)
    set(icons(g),'FontName',fontname,'FontSize',fontsize-2);
end
for g = 1:size(clsyfyrs,2)
    set(icons(g+size(clsyfyrs,2)).Children,'MarkerSize',14,'MarkerFaceColor',facecolorlist(g,:),'MarkerEdgeColor',colorlist(g,:));
end

export_fig(sprintf('figures/auc_%s.tiff',param.group),'-r200');
close(gcf);

save(sprintf('stats_%s.mat',param.group),'clsyfyrs','featlist');

%% plot confusion matrix of best classifier

if strcmp(param.plotcm,'on')
    for g = 1:size(clsyfyrs,2)
        [~,bestauc] = max(cell2mat({clsyfyrs(:,g).auc}));
        
        fprintf('%s %s - %s vs %s: AUC = %.2f, p = %.5f, Chi2 = %.2f, Chi2 p = %.4f, accu = %d%%.\n',...
            featlist{bestauc,2},bands{featlist{bestauc,3}},param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1},...
            clsyfyrs(bestauc,g).auc,clsyfyrs(bestauc,g).pval,clsyfyrs(bestauc,g).chi2,clsyfyrs(bestauc,g).chi2pval,clsyfyrs(bestauc,g).accu);
        
        plotconfusion(clsyfyrs(bestauc,g).confmat,{param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1}});
        set(gca,'FontName',fontname,'FontSize',fontsize);
        if ~isempty(param.xlabel)
            xlabel(param.xlabel,'FontName',fontname,'FontSize',fontsize);
        else
            xlabel('EEG diagnosis','FontName',fontname,'FontSize',fontsize);
        end
        if ~isempty(param.ylabel)
            ylabel(param.ylabel,'FontName',fontname,'FontSize',fontsize);
        else
            ylabel('CRS-R diagnosis','FontName',fontname,'FontSize',fontsize);
        end
        
        export_fig(gcf,sprintf('figures/clsyfyr_%s_vs_%s_cm.tiff',param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1}));
        close(gcf);
    end
end