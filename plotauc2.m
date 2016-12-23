function plotauc2(varargin)

param = finputcheck(varargin, {
    'group', 'string', [], 'crsdiag'; ...
    'groupnames', 'cell', {}, {'UWS','MCS-','MCS+','EMCS','LIS','CTRL'}; ...
    'pairlist' 'real', [], [1 6]; ...
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
        ];
else
    grouppairs = param.grouppairs;
end

% colorlist = [
%     0 0.0 0.5
%     0 0.5 0
%     0.5 0.0 0
%     0   0.5 0.5
%     0.5 0   0.5
%     0.5 0.5 0
%     ];
% 
% facecolorlist = [
%     0.75  0.75 1
%     0.25 1 0.25
%     1 0.75 0.75
%     0.75 1 1
%     1 0.75 1
%     1 1 0.75
%     ];

fontname = 'Helvetica';
fontsize = 20;

load(sprintf('stats_%s%s.mat',param.prefix,param.group),'stats','featlist');

featlist = {
    'ftdwpli'    'power'                  [1]    'Rel. power \delta'
    'ftdwpli'    'power'                  [2]    'Rel. power \theta'
    'ftdwpli'    'power'                  [3]    'Rel. power \alpha'
    'ftdwpli'    'median'                 [1]    'Med. dwPLI \delta'
    'ftdwpli'    'median'                 [2]    'Med. dwPLI \theta'
    'ftdwpli'    'median'                 [3]    'Med. dwPLI \alpha'
    'ftdwpli'    'clustering'             [1]    'Local eff. \delta'
    'ftdwpli'    'clustering'             [2]    'Local eff. \theta'
    'ftdwpli'    'clustering'             [3]    'Local eff. \alpha'
    'ftdwpli'    'characteristic path length'     [1]    'Global eff. \delta'
    'ftdwpli'    'characteristic path length'     [2]    'Global eff. \theta'
    'ftdwpli'    'characteristic path length'     [3]    'Global eff. \alpha'
    'ftdwpli'    'modularity'             [1]    'Modularity \delta'
    'ftdwpli'    'modularity'             [2]    'Modularity \theta'
    'ftdwpli'    'modularity'             [3]    'Modularity \alpha'
    'ftdwpli'    'participation coefficient'     [1]    'Hub idx. \delta'
    'ftdwpli'    'participation coefficient'     [2]    'Hub idx. \theta'
    'ftdwpli'    'participation coefficient'     [3]    'Hub idx. \alpha'
    'ftdwpli'    'modular span'           [1]    'Mod. span \delta'
    'ftdwpli'    'modular span'           [2]    'Mod. span \theta'
    'ftdwpli'    'modular span'           [3]    'Mod. span \alpha'
    };

if size(stats,2) > 2
    stats = stats(:,param.pairlist);
end


colorlist = [
    0 0 0
    ];
facecolorlist = [
    0.75 0.75 0.75
    ];

p_thresh = fdr(cell2mat({stats.pval}),param.alpha);
% p_thresh = 0.05;

markersizes = [150 300];

for g = 1:size(stats,2)
    
    figure('Color','white');
    figpos = get(gcf,'Position');
    figpos(3) = figpos(3)*2;
    figpos(4) = figpos(4)*2/3;
    set(gcf,'Position',figpos);
    
    hold all
        
    [~,sortidx] = sort(cell2mat({stats(:,g).auc}),'descend');
    yticklabels = {};
    for f = 1:length(sortidx)
        if stats(sortidx(f),g).pval < p_thresh
            markersize = markersizes(2);
        elseif stats(sortidx(f),g).pval < param.alpha
            markersize = markersizes(1);
        else
            continue;
        end
        
        legendoff(line([0.5 max(cell2mat({stats(sortidx(f),g).auc}))],[f f],'LineWidth',0.5,'Color',[0.5 0.5 0.5]));
        if f == 1
            sc_h(f,g) = scatter(stats(sortidx(f),g).auc,f,markersize,...
                'MarkerFaceColor',facecolorlist,'MarkerEdgeColor',colorlist,'LineWidth',1.5);
        else
            sc_h(f,g) = legendoff(scatter(stats(sortidx(f),g).auc,f,markersize,...
                'MarkerFaceColor',facecolorlist,'MarkerEdgeColor',colorlist,'LineWidth',1.5));
        end

        yticklabels = cat(1,yticklabels,featlist{sortidx(f),4});
    end
    
    set(gca,'FontName',fontname,'FontSize',fontsize,'YDir','reverse');
    if isempty(param.xlim)
        xlim([0.5 0.9]);
    else
        xlim(param.xlim);
    end
    ylimits = ylim;
    ylim([ylimits(1)-0.5 ylimits(end)+0.5]);
    grouppairnames = sprintf('%s vs. %s',param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1});
    xlabel(grouppairnames,'FontName',fontname,'FontSize',fontsize);
    set(gca,'YTick',1:size(stats,1),'YTickLabel',yticklabels);
        
    export_fig(sprintf('figures/auc_%s%s_%d.tiff',param.prefix,param.group,g),'-r200','-p0.01');
    close(gcf);
end

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