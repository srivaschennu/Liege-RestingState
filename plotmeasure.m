function [scores,group,stats,pet] = plotmeasure(listname,conntype,measure,bandidx,varargin)

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

testdata = getmeasure(listname,conntype,measure,bandidx,sortedlocs,param);

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
        export_fig(gcf,sprintf('figures/%s_%s_%s_%s.eps',conntype,measure,bands{bandidx},param.group),'-r200');
        close(gcf);
    end
end

groups = unique(groupvar(~isnan(groupvar)));
grouppairs = nchoosek(groups,2);

for g = 1:size(grouppairs,1)
    grouppairnames{g} = sprintf('%s-%s',groupnames{groups == grouppairs(g,1)},groupnames{groups == grouppairs(g,2)});
    thisgroupvar = groupvar(groupvar == grouppairs(g,1) | groupvar == grouppairs(g,2));
    [~,~,thisgroupvar] = unique(thisgroupvar);
    thisgroupvar = thisgroupvar-1;
    thispetdiag = petdiag(groupvar == grouppairs(g,1) | groupvar == grouppairs(g,2));
    thistestdata = testdata(groupvar == grouppairs(g,1) | groupvar == grouppairs(g,2),:);
    
    pet(g).confmat = confusionmat(thisgroupvar(~isnan(thispetdiag)),thispetdiag(~isnan(thispetdiag)));
    pet(g).confmat = pet(g).confmat*100 ./ repmat(sum(pet(g).confmat,2),1,2);
    [~,pet(g).chi2,pet(g).chi2pval] = crosstab(thisgroupvar(~isnan(thispetdiag)),thispetdiag(~isnan(thispetdiag)));
    
    if strcmp(param.noplot,'off')
        fprintf('\nPET: %s vs %s Chi2 = %.2f, Chi2 p = %.4f, accu = %d%%.\n',...
            param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1},...
            pet(g).chi2,pet(g).chi2pval,...
            round(sum(thisgroupvar(~isnan(thispetdiag))==thispetdiag(~isnan(thispetdiag)))*100/length(thisgroupvar(~isnan(thispetdiag)))));
        
        if strcmp(param.plotcm,'on')
            % plot confusion matrix
            plotconfusion(pet(g).confmat,{param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1}});
            set(gca,'FontName',fontname,'FontSize',fontsize);
            if ~isempty(param.xlabel)
                xlabel(param.xlabel,'FontName',fontname,'FontSize',fontsize);
            else
                xlabel('PET diagnosis','FontName',fontname,'FontSize',fontsize);
            end
            if ~strcmp(param.ylabel,measure)
                ylabel(param.ylabel,'FontName',fontname,'FontSize',fontsize);
            else
                ylabel('CRS-R diagnosis','FontName',fontname,'FontSize',fontsize);
            end
            export_fig(gcf,sprintf('figures/PET_%s_vs_%s_cm.tiff',param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1}));
            close(gcf);
        end
    end
    
    for d = 1:size(thistestdata,2)
        [x,y,t,auc(g,d)] = perfcurve(thisgroupvar, thistestdata(:,d),1);
        [~,bestthresh] = max(abs(y + (1-x) - 1));
        %         [~,bestthresh] = min(sqrt((0-x).^2 + (1-y).^2));
        thisconfmat = confusionmat(thisgroupvar,double(thistestdata(:,d) > t(bestthresh)));
        thisconfmat = thisconfmat*100 ./ repmat(sum(thisconfmat,2),1,2);
        confmat(g,d,:,:) = thisconfmat;
        [pval(g,d),~,stat] = ranksum(thistestdata(thisgroupvar == 0,d),thistestdata(thisgroupvar == 1,d));
        n0 = sum(thisgroupvar == 0); n1 = sum(thisgroupvar == 1);
        U(g,d) = (n0*n1)+(n0*(n0+1))/2-stat.ranksum;
        U(g,d) = min(U(g,d),(n0*n1) - U(g,d));
    end
    
    [~,maxaucidx] = max(auc(g,:));
    stats(g).U = U(g,maxaucidx);
    stats(g).auc = auc(g,maxaucidx);
    stats(g).pval = pval(g,maxaucidx);
    stats(g).confmat = squeeze(confmat(g,maxaucidx,:,:));
    stats(g).maxaucidx = maxaucidx;
    
    if strcmp(param.noplot,'off')
        fprintf('%s %s: %s vs %s AUC = %.2f, J = %.2f, p = %.4f.\n',measure,bands{bandidx},...
            param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1},...
            auc(g,maxaucidx),(thisconfmat(2,2) + thisconfmat(1,1))/100 - 1, pval(g,maxaucidx));
        if strcmp(param.plotcm,'on')
            plotconfusion(squeeze(confmat(g,maxaucidx,:,:)),{param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1}});
            set(gca,'FontName',fontname,'FontSize',fontsize);
            if ~isempty(param.xlabel)
                xlabel(param.xlabel,'FontName',fontname,'FontSize',fontsize);
            else
                xlabel('EEG diagnosis','FontName',fontname,'FontSize',fontsize);
            end
            if ~strcmp(param.ylabel,measure)
                ylabel(param.ylabel,'FontName',fontname,'FontSize',fontsize);
            else
                ylabel('CRS-R diagnosis','FontName',fontname,'FontSize',fontsize);
            end
            export_fig(gcf,sprintf('figures/%s_vs_%s_%s_cm.tiff',param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1},measure));
            close(gcf);
        end
    end
end

% auc(auc < 0.5) = 1-auc(auc < 0.5);

if strcmp(param.noplot,'off')
%     clear plotdata
%     for g = 1:length(groups)
%         plotdata{g} = mean(testdata(groupvar == groups(g),:),2);
%     end
    
    %% plot mean graph
    figure('Color','white');
    figpos = get(gcf,'Position');
%     figpos(3) = figpos(3)*2/3;
    % figpos(4) = figpos(4)*3/4;
    set(gcf,'Position',figpos);
    
    hold all
%     violin(plotdata,'edgecolor',colorlist(1:length(groups),:),'facecolor',facecolorlist(1:length(groups),:),'facealpha',1,'medc',[]);
    boxh = notBoxPlot(testdata,groupvar+1,0.5,'patch',ones(size(testdata,1),1));
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
    export_fig(gcf,sprintf('figures/%s_avg_%s_%s_%s.tiff',conntype,measure,bands{bandidx},param.group),'-r200');
    close(gcf);
    
    %% plot auc
    figure('Color','white');
    hold all
    if exist('plottvals','var')
        set(gca,'XDir','reverse');
        for g = 1:size(grouppairs,1)
            plot(plottvals,auc(g,:),'LineWidth',2,'Color',colorlist(g,:));
        end
        set(gca,'XLim',[plottvals(end) plottvals(1)]);
        xlabel('Graph connection density','FontName',fontname,'FontSize',fontsize);
        legend(grouppairnames,'Location',param.legendlocation);
        ylabel('AUC','FontName',fontname,'FontSize',fontsize);
        if ~isempty(param.ylim)
            set(gca,'YLim',param.ylim);
        else
            set(gca,'YLim',[0 1]);
        end
    else
        barh(auc(:,maxaucidx));
        ylim([0.5 size(auc,1)+0.5]);
        set(gca,'YTick',1:length(grouppairnames),'YTickLabels',grouppairnames);
        if ~isempty(param.xlim)
            set(gca,'XLim',param.ylim);
        else
            set(gca,'XLim',[0 1]);
        end
        xlabel('AUC','FontName',fontname,'FontSize',fontsize);
        xlimits = xlim;
        set(gca,'XTick',xlimits(1):0.1:xlimits(2),'YDir','reverse');
    end
    set(gca,'FontName',fontname,'FontSize',fontsize);
    
    export_fig(gcf,sprintf('figures/%s_auc_%s_%s_%s.tiff',conntype,measure,bands{bandidx},param.group),'-r200');
    close(gcf);
    
end

% %% correlate with days since onset
% [rho,pval] = corr(testdata(~isnan(daysonset)),daysonset(~isnan(daysonset)),'type','Spearman');
% fprintf('Correlation with days since onset = %.2f, p = %.4f.\n',rho,pval);
%
scores = testdata;
group = groupvar;