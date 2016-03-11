function [dataout,grpout,roc] = plotmeasure(listname,conntype,measure,bandidx,varargin)

param = finputcheck(varargin, {
    'group', 'string', [], 'crsdiag'; ...
    'groupnames', 'cell', {}, {'UWS','MCS','EMCS','LIS'}; ...
    'changroup', 'string', [], 'all'; ...
    'changroup2', 'string', [], 'all'; ...
    'ylabel', 'string', [], measure; ...
    'xlim', 'real', [], []; ...
    'ylim', 'real', [], []; ...
    'xtick', 'real', [], []; ...
    'ytick', 'real', [], []; ...
    'legend', 'string', {'on','off'}, 'off'; ...
    'legendlocation', 'string', [], 'Best'; ...
    'noplot', 'string', {'on','off'}, 'off'; ...
    });

fontname = 'Helvetica';
fontsize = 18;

loadpaths
loadsubj
changroups

load sortedlocs

subjlist = eval(listname);
refdiag = cell2mat(subjlist(:,2));
crsdiag = cell2mat(subjlist(:,3));
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
    ];
facecolorlist = [
    0.75  0.75 1
    0.25 1 0.25
    1 0.75 0.75
    0.75 1 1
    ];

groupnames = param.groupnames;

weiorbin = 3;

if strcmpi(measure,'power')
    load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype));
    power = load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype));
    testdata = mean(power.bandpower(:,bandidx,ismember({sortedlocs.labels},eval(param.changroup))),3) * 100;
elseif strcmpi(measure,'median')
    load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype));
    testdata = median(median(allcoh(:,bandidx,ismember({sortedlocs.labels},eval(param.changroup)),ismember({sortedlocs.labels},eval(param.changroup2))),4),3);
elseif strcmpi(measure,'mean')
    load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype));
    testdata = mean(mean(allcoh(:,bandidx,ismember({sortedlocs.labels},eval(param.changroup)),ismember({sortedlocs.labels},eval(param.changroup2))),4),3);
elseif strcmpi(measure,'refdiag')
    testdata = refdiag;
else
    trange = [0.5 0.1];
    load(sprintf('%s%s//graphdata_%s_%s.mat',filepath,conntype,listname,conntype));
    trange = (tvals <= trange(1) & tvals >= trange(2));
    plottvals = tvals(trange);
    
    if strcmpi(measure,'small-worldness')
        randgraph = load(sprintf('%s/%s/graphdata_%s_rand_%s.mat',filepath,conntype,listname,conntype));
        graph{end+1,1} = 'small-worldness';
        graph{end,2} = ( mean(graph{1,2},4) ./ mean(randgraph.graph{1,2},4) ) ./ ( graph{2,2} ./ randgraph.graph{2,2} ) ;
        graph{end,3} = ( mean(graph{1,3},4) ./ mean(randgraph.graph{1,3},4) ) ./ ( graph{2,3} ./ randgraph.graph{2,3} ) ;
    end
    
%     if ~strcmpi(measure,'small-worldness')
%         m = find(strcmpi(measure,graph(:,1)));
%         graph{m,2} = graph{m,2} ./ randgraph.graph{m,2};
%         graph{m,3} = graph{m,3} ./ randgraph.graph{m,3};
%     end
    
    m = find(strcmpi(measure,graph(:,1)));
    if strcmpi(measure,'modules')
        testdata = squeeze(max(graph{m,weiorbin}(:,bandidx,trange,:),[],4));
    elseif strcmpi(measure,'centrality')
        testdata = squeeze(max(graph{m,weiorbin}(:,bandidx,trange,:),[],4));
    elseif strcmpi(measure,'mutual information')
        testdata = squeeze(mean(graph{m,weiorbin}(:,:,bandidx,trange),4));
    elseif strcmpi(measure,'participation coefficient')
        testdata = squeeze(std(graph{m,weiorbin}(:,bandidx,trange,:),[],4));
%         testdata = squeeze(graph{m,weiorbin}(:,bandidx,trange,:));
%         testdata = testdata - repmat(quantile(testdata,0.9,3),1,1,size(testdata,3));
%         testdata(testdata < 0) = NaN;
%         testdata = nanmean(testdata,3);
    else
        testdata = squeeze(mean(graph{m,weiorbin}(:,bandidx,trange,:),4));
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

if strcmp(param.noplot,'off')
    for g = 1:length(groups)
        plotdata = testdata(groupvar == groups(g),:);
        groupmean(g,:) = nanmean(plotdata);
        groupste(g,:) = nanstd(plotdata)/sqrt(length(plotdata));
    end
    
    if exist('plottvals','var')
        %% plot graph across connection densities
        
        figure('Color','white');
        hold all
        set(gca,'XDir','reverse');
        for g = 1:length(groups)
            errorbar(plottvals,groupmean(g,:),groupste(g,:),'LineWidth',1,'Color',colorlist(g,:));
        end
        set(gca,'XLim',[plottvals(end) plottvals(1)],'FontName',fontname,'FontSize',fontsize);
        xlabel('Graph connection density','FontName',fontname,'FontSize',fontsize);
        ylabel(param.ylabel,'FontName',fontname,'FontSize',fontsize);
        if ~isempty(param.ylim)
            set(gca,'YLim',param.ylim);
        end
        legend(groupnames,'Location',param.legendlocation);
        export_fig(gcf,sprintf('figures/%s_%s_%s_%s.eps',conntype,measure,bands{bandidx},param.group));
        close(gcf);
    end
end

testdata = mean(testdata,2);

clear plotdata
for g = 1:length(groups)
    plotdata{g} = testdata(groupvar == groups(g));
end

%% plot mean graph
if strcmp(param.noplot,'off')
    figure('Color','white');
    figpos = get(gcf,'Position');
    figpos(3) = figpos(3)*1/2;
    % figpos(4) = figpos(4)*3/4;
    set(gcf,'Position',figpos);
    
    hold all
    [~,lg_h] = violin(plotdata,'edgecolor',colorlist(1:length(groups),:),'facecolor',facecolorlist(1:length(groups),:),'facealpha',1,'mc',[]);
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
    export_fig(gcf,sprintf('figures/%s_avg_%s_%s_%s.eps',conntype,measure,bands{bandidx},param.group));
    close(gcf);
end

[rocpet.x,rocpet.y,rocpet.t,rocpet.auc] = perfcurve(groupvar(groupvar == 0 | groupvar == 1),petdiag(groupvar == 0 | groupvar == 1),1);
[~, bestidx] = min(sqrt((0-rocpet.x).^2 + (1-rocpet.y).^2));
rocpet.bestpnt = [rocpet.x(bestidx) rocpet.y(bestidx)];
rocpet.sens = rocpet.bestpnt(2)*100;
rocpet.spec = (1-rocpet.bestpnt(1))*100;
rocpet.accu = sum(petdiag == groupvar) * 100/length(groupvar);
rocpet.ppv  = 100 * sum((petdiag == 1) & (groupvar == 1)) ./ (sum((petdiag == 1) & (groupvar == 1)) + sum((petdiag == 1) & (groupvar == 0)));
rocpet.npv  = 100 * sum((petdiag == 0) & (groupvar == 0)) ./ (sum((petdiag == 0) & (groupvar == 0)) + sum((petdiag == 0) & (groupvar == 1)));

fprintf('\nPET: AUC %.2f, Sens. %.1f%%, Spec. %.1f%%, Accu %.1f%%, PPV %.1f%%, NPV %.1f%%.\n', ...
    rocpet.auc, rocpet.sens, rocpet.spec, rocpet.accu, rocpet.ppv, rocpet.npv);

[roc.x,roc.y,roc.t,roc.auc] = perfcurve(groupvar(groupvar == 0 | groupvar == 1),testdata(groupvar == 0 | groupvar == 1),1);
[~, bestidx] = min(sqrt((0-roc.x).^2 + (1-roc.y).^2));
roc.bestpnt = [roc.x(bestidx) roc.y(bestidx)];
roc.bestthresh = roc.t(roc.x == roc.bestpnt(1) & roc.y == roc.bestpnt(2));
roc.sens = roc.bestpnt(2)*100;
roc.spec = (1-roc.bestpnt(1))*100;
testdiag = (testdata >= roc.bestthresh);
roc.accu = sum(testdiag == groupvar) * 100/length(groupvar);
roc.ppv  = 100 * sum((testdiag == 1) & (groupvar == 1)) ./ (sum((testdiag == 1) & (groupvar == 1)) + sum((testdiag == 1) & (groupvar == 0)));
roc.npv  = 100 * sum((testdiag == 0) & (groupvar == 0)) ./ (sum((testdiag == 0) & (groupvar == 0)) + sum((testdiag == 0) & (groupvar == 1)));

fprintf('%s %s: AUC %.2f, Sens. %.1f%%, Spec. %.1f%%, Accu %.1f%%, PPV %.1f%% NPV %.1f%%.\n', ...
    bands{bandidx}, measure, roc.auc, roc.sens, roc.spec, roc.accu, roc.ppv, roc.npv);

%% plot roc analysis
if strcmp(param.noplot,'off')
    figure('Color','white');
    hold all
    
    plot(rocpet.x*100,rocpet.y*100,'LineWidth',2);
    plot(roc.x*100,roc.y*100,'LineWidth',2);
    plot([0 100],[0 100],'LineWidth',1','Color','black','LineStyle','--');
    
    set(gca,'FontName',fontname,'FontSize',fontsize);
    xlabel('False positive rate','FontName',fontname,'FontSize',fontsize);
    ylabel('True positive rate','FontName',fontname,'FontSize',fontsize);
    legend('PET diagnosis',param.ylabel,'Location','SouthEast');
    
    scatter(rocpet.bestpnt(1)*100,rocpet.bestpnt(2)*100,100,'red','filled','LineWidth',1);
    scatter(roc.bestpnt(1)*100,roc.bestpnt(2)*100,100,'red','filled','LineWidth',1);
    box on
    
    export_fig(gcf,sprintf('figures/%s_roc_%s_%s_%s.eps',conntype,measure,bands{bandidx},param.group));
    close(gcf);
end

% %% correlate with CRS-R
% 
% datatable = sortrows(cat(2,crs,testdata,tennis,groupvar),2);
% mdl = fitlm(datatable(:,2),datatable(:,1),'RobustOpts','on');
% fprintf('%s %s: R2 = %.2f, p = %.3f.\n',bands{bandidx},measure,mdl.Rsquared.Adjusted,doftest(mdl));
% % exmdl = fitlm(datatable(:,2),datatable(:,1),'RobustOpts','on','Exclude',find(datatable(:,4) == 0));
% % fprintf('%s %s (excl): R2 = %.2f, p = %.3f.\n',bands{bandidx},measure,exmdl.Rsquared.Adjusted,doftest(exmdl));
% 
% % test with power covariate
% % exmdl = LinearModel.fit(datatable(:,[2 5]),datatable(:,1),'RobustOpts','on','Exclude',find(datatable(:,4) == 0 & datatable(:,3) == 1))
% % fprintf('%s %s (excl with power): R2 = %.2f, p = %.3f.\n',bands{bandidx},measure,exmdl.Rsquared.Adjusted,doftest(exmdl));
% 
% [rho, pval] = corr(datatable(:,1),datatable(:,2),'type','spearman');
% fprintf('Spearman rho = %.2f, p = %.3f.\n',rho,pval);
% 
% figure('Color','white');
% hold all
% %VS
% legendoff(scatter(datatable(datatable(:,4) == 0 & datatable(:,3) == 0,2), ...
%     datatable(datatable(:,4) == 0 & datatable(:,3) == 0,1),'red'));
% legendoff(scatter(datatable(datatable(:,4) == 0 & datatable(:,3) == 1,2), ...
%     datatable(datatable(:,4) == 0 & datatable(:,3) == 1,1),'red','filled'));
% % legendoff(scatter(datatable(datatable(:,4) == 0,2),datatable(datatable(:,4) == 0,1),'red','filled'));
% %MCS
% legendoff(scatter(datatable(datatable(:,4) == 1 & datatable(:,3) == 0,2), ...
%     datatable(datatable(:,4) == 1 & datatable(:,3) == 0,1),'blue'));
% legendoff(scatter(datatable(datatable(:,4) == 1 & datatable(:,3) == 1,2), ...
%     datatable(datatable(:,4) == 1 & datatable(:,3) == 1,1),'blue','filled'));
% % legendoff(scatter(datatable(datatable(:,4) == 1,2),datatable(datatable(:,4) == 1,1),'blue','filled'));
% 
% b = mdl.Coefficients.Estimate;
% plot(datatable(:,2),b(1)+b(2)*datatable(:,2),'-','Color','black',...
%     'Display',sprintf('R^2 = %.2f, p = %.3f',mdl.Rsquared.Adjusted,doftest(mdl)));
% % b = exmdl.Coefficients.Estimate;
% % plot(datatable(datatable(:,4) == 1,2),b(1)+b(2)*datatable(datatable(:,4) == 1,2),'--','Color','black',...
% %     'Display',sprintf('R^2 = %.2f, p = %.3f',exmdl.Rsquared.Adjusted,doftest(exmdl)));
% 
% set(gca,'FontName',fontname,'FontSize',fontsize);
% if ~isempty(param.ylim)
%     set(gca,'YLim',param.ylim);
% end
% if ~isempty(param.xlim)
%     set(gca,'XLim',param.xlim);
% end
% 
% xlabel(param.ylabel,'FontName',fontname,'FontSize',fontsize);
% % if strcmp(param.plotinfo,'on')
%     ylabel('CRS-R score','FontName',fontname,'FontSize',fontsize);
% % else
% %     ylabel(' ','FontName',fontname,'FontSize',fontsize);
% % end
% 
% % if strcmp(param.legend,'on')
%     leg_h = legend('show');
%     if isempty(param.legendlocation)
%         set(leg_h,'Location','Best');
%     else
%         set(leg_h,'Location',param.legendlocation);
%     end
%     txt_h = findobj(leg_h,'type','text');
%     set(txt_h,'FontSize',fontsize-6,'FontWeight','bold')
%     legend('boxoff');
% % end
% 
% export_fig(gcf,sprintf('figures/%s_crscorr_%s_%s_%s.eps',conntype,measure,bands{bandidx},param.group));
% close(gcf);

%% correlate with days since onset
[rho,pval] = corr(testdata(~isnan(daysonset)),daysonset(~isnan(daysonset)),'type','Spearman');
fprintf('Correlation with days since onset = %.2f, p = %.4f.\n',rho,pval);

dataout = testdata;
grpout = groupvar;