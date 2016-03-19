function [dataout,grpout,testauc,petaccu] = plotmeasure(listname,conntype,measure,bandidx,varargin)

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
    0.5 0   0.5
    0.5 0.5 0
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
%         testdata = testdata - repmat(quantile(testdata,0.75,3),1,1,size(testdata,3));
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

groups = unique(groupvar(~isnan(groupvar)));
grouppairs = nchoosek(groups,2);

for g = 1:size(grouppairs,1)
    grouppairnames{g} = sprintf('%s-%s',groupnames{groups == grouppairs(g,1)},groupnames{groups == grouppairs(g,2)});
    thisgroupvar = groupvar(groupvar == grouppairs(g,1) | groupvar == grouppairs(g,2));
    thispetdiag = petdiag(groupvar == grouppairs(g,1) | groupvar == grouppairs(g,2));
    
    petaccu(g,1) = sum( logical(thisgroupvar(~isnan(thispetdiag))) == logical(thispetdiag(~isnan(thispetdiag))) ) * 100 / ...
        length( thisgroupvar(~isnan(thispetdiag)) );

    for d = 1:size(testdata,2)
        testauc(g,d) = fastAUC( thisgroupvar , ...
            testdata(groupvar == grouppairs(g,1) | groupvar == grouppairs(g,2),d),grouppairs(g,2) );
    end
end

testauc(testauc < 0.5) = 1-testauc(testauc < 0.5);

if strcmp(param.noplot,'off')
    clear plotdata
    for g = 1:length(groups)
        plotdata{g} = mean(testdata(groupvar == groups(g),:),2);
    end

    %% plot mean graph
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
    
    %% plot auc
    figure('Color','white');
    hold all
    if exist('plottvals','var')
        set(gca,'XDir','reverse');
        for g = 1:size(grouppairs,1)
            plot(plottvals,testauc(g,:),'LineWidth',2,'Color',colorlist(g,:));
        end
        set(gca,'XLim',[plottvals(end) plottvals(1)]);
        xlabel('Graph connection density','FontName',fontname,'FontSize',fontsize);
        legend(grouppairnames,'Location',param.legendlocation);
        ylabel('AUC','FontName',fontname,'FontSize',fontsize);
        if ~isempty(param.ylim)
            set(gca,'YLim',param.ylim);
        else
            set(gca,'YLim',[0.5 1]);
        end
    else
        barh(testauc);
        ylim([0.5 length(testauc)+0.5]);
        set(gca,'YTick',1:length(grouppairnames),'YTickLabels',grouppairnames);
        if ~isempty(param.xlim)
            set(gca,'XLim',param.ylim);
        else
            set(gca,'XLim',[0.5 1]);
        end
        xlabel('AUC','FontName',fontname,'FontSize',fontsize);
        xlimits = xlim;
        set(gca,'XTick',xlimits(1):0.05:xlimits(2),'YDir','reverse');
    end
    set(gca,'FontName',fontname,'FontSize',fontsize);

    export_fig(gcf,sprintf('figures/%s_auc_%s_%s_%s.eps',conntype,measure,bands{bandidx},param.group));
    close(gcf);

end



% %% correlate with days since onset
% [rho,pval] = corr(testdata(~isnan(daysonset)),daysonset(~isnan(daysonset)),'type','Spearman');
% fprintf('Correlation with days since onset = %.2f, p = %.4f.\n',rho,pval);
% 
dataout = testdata;
grpout = groupvar;