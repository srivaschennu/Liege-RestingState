function [scores,group,stats,pet] = plotmeasure(listname,conntype,measure,bandidx,varargin)

param = finputcheck(varargin, {
    'group', 'string', [], 'crsdiag'; ...
    'groupnames', 'cell', {}, {'UWS','MCS-','MCS+','EMCS','LIS','CTRL'}; ...
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
    'plot', 'string', {'on','off'}, 'on'; ...
    'plotcm', 'string', {'on','off'}, 'off'; ...
    });

fontname = 'Helvetica';
fontsize = 24;

loadpaths
loadsubj
changroups

load sortedlocs

subjlist = eval(listname);

refdiag = cell2mat(subjlist(:,2));
refaware = double(cell2mat(subjlist(:,2)) > 0);
refaware(isnan(refdiag)) = NaN;
crsdiag = cell2mat(subjlist(:,3));
crsaware = double(cell2mat(subjlist(:,3)) > 0);
petdiag = cell2mat(subjlist(:,4));
tennis = cell2mat(subjlist(:,5));
etiology = cell2mat(subjlist(:,6));
age = cell2mat(subjlist(:,7));
daysonset = cell2mat(subjlist(:,9));
outcome = double(cell2mat(subjlist(:,10)) > 2);
outcome(isnan(cell2mat(subjlist(:,10)))) = NaN;

anoxicoutcome = double(cell2mat(subjlist(:,10)) > 2);
anoxicoutcome(isnan(cell2mat(subjlist(:,10)))) = NaN;
anoxicoutcome(etiology == 1) = NaN;
tbioutcome = double(cell2mat(subjlist(:,10)) > 2);
tbioutcome(isnan(cell2mat(subjlist(:,10)))) = NaN;
tbioutcome(etiology == 0) = NaN;
mcstennis = tennis .* crsdiag;
mcstennis(crsdiag == 0) = NaN;
crs = cell2mat(subjlist(:,11));

admvscrs = NaN(size(refdiag));
admvscrs(refaware == 0) = 0;
admvscrs(refaware == 0 & crsaware == 0) = 0;
admvscrs(refaware > 0 & crsaware > 0) = 1;
admvscrs(refaware == 0 & crsaware > 0) = 2;

etiooutcome = NaN(size(crsdiag));
etiooutcome(etiology == 0 & outcome == 0) = 0;
etiooutcome(etiology == 0 & outcome == 1) = 1;
etiooutcome(etiology == 1 & outcome == 0) = 2;
etiooutcome(etiology == 1 & outcome == 1) = 3;

vsoutcome = outcome;
vsoutcome(crsdiag > 0) = NaN;
mcsoutcome = outcome;
mcsoutcome(crsdiag == 0 & crsdiag > 2) = NaN;

tdcs = NaN(size(crsdiag));

tdcssubj = {
'3'  0
'7'  0
'11',0
'21',0
'22' 0
'39' 0
'41',0
'44' 0
'48',0
'78' 0
'81',0
'86' 0
'50',0
'88',0
'16' 1
'17' 1
'51' 1
'68' 1 %after 2 days of stim
'72' 1
'74' 1 %after 3 days of stim
'NB_20170518',1
'VP_20160922',1
};

for s = 1:size(tdcssubj,1)
    patidx = find(strcmp(tdcssubj{s,1},subjlist(:,1)),1);
    fprintf('%d ', patidx);
    if ~isempty(patidx)
        tdcs(patidx) = tdcssubj{s,2};
    end
end

groupvar = eval(param.group);
groups = unique(groupvar(~isnan(groupvar)));

colorlist = [
    0 0.0 0.5
    0 0.5 0
    0.5 0.5 0
    0   0.5 0.5
    0.5 0   0.5
    0.5 0.5 0
    ];

facecolorlist = [
    0.75  0.75 1
    0.25 1 0.25
    .9    .9 0
    0.75 1 1
    1 0.75 1
    1 1 0.5
    ];

groupnames = param.groupnames;

weiorbin = 3;
plottvals = [];

if strcmpi(measure,'power')
    %     load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype));
    load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype),'bandpower');
    testdata = mean(bandpower(:,bandidx,ismember({sortedlocs.labels},eval(param.changroup))),3) * 100;
elseif strcmpi(measure,'specent')
    %     load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype));
    load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype),'specent');
    testdata = mean(specent(:,ismember({sortedlocs.labels},eval(param.changroup))),2);
elseif strcmpi(measure,'median')
    load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype),'allcoh');
    testdata = median(median(allcoh(:,bandidx,ismember({sortedlocs.labels},eval(param.changroup)),ismember({sortedlocs.labels},eval(param.changroup2))),4),3);
elseif strcmpi(measure,'mean')
    load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype),'allcoh');
    testdata = mean(mean(allcoh(:,bandidx,ismember({sortedlocs.labels},eval(param.changroup)),ismember({sortedlocs.labels},eval(param.changroup2))),4),3);
elseif strcmpi(measure,'refdiag')
    testdata = refdiag;
elseif strcmpi(measure,'crs')
    testdata = crs;
else
    trange = [0.9 0.1];
    load(sprintf('%s%s//graphdata_%s_%s.mat',filepath,conntype,listname,conntype),'graph','tvals');
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
        normaliser = (size(graph{m,weiorbin},4)-1)*(size(graph{m,weiorbin},4)-2);
        testdata = squeeze(std(graph{m,weiorbin}(:,bandidx,trange,:)/normaliser,[],4));
    elseif strcmpi(measure,'mutual information')
        testdata = squeeze(mean(graph{m,weiorbin}(:,crsdiag == 5,bandidx,trange),2));
    elseif strcmpi(measure,'participation coefficient') || strcmpi(measure,'degree')
%         testdata = squeeze(zscore(graph{m,weiorbin}(:,bandidx,trange,:),0,4));
%         testdata = mean(testdata(:,:,ismember({sortedlocs.labels},eval(param.changroup))),3);
        
        testdata = squeeze(std(graph{m,weiorbin}(:,bandidx,trange,ismember({sortedlocs.labels},eval(param.changroup))),[],4));

        %         testdata = squeeze(graph{m,weiorbin}(:,bandidx,trange,:));
        %         testdata = testdata - repmat(quantile(testdata,0.75,3),1,1,size(testdata,3));
        %         testdata(testdata < 0) = NaN;
        %         testdata = nanmean(testdata,3);
%         testdata = squeeze(graph{m,weiorbin}(:,bandidx,trange,:));
    elseif strcmpi(measure,'characteristic path length')
        testdata = round(squeeze(mean(graph{m,weiorbin}(:,bandidx,trange,:),4)));
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

if strcmp(param.plot,'on')
    for g = 1:length(groups)
        plotdata = mean(testdata(groupvar == groups(g),:,:),3);
        groupmean(g,:) = nanmean(plotdata);
        groupste(g,:) = nanstd(plotdata)./sqrt(sum(~isnan(plotdata),1));
    end
    
    if ~isempty(plottvals)
        %% plot graph across connection densities
        
        figure('Color','white');
        hold all
        set(gca,'XDir','reverse');
        for g = 1:length(groups)
            errorbar(plottvals,groupmean(g,:),groupste(g,:),'LineWidth',1,'Color',colorlist(g,:));
        end
        set(gca,'XLim',[plottvals(end)-0.01 plottvals(1)+0.01],'FontName',fontname,'FontSize',fontsize);
        xlabel('Graph connection density','FontName',fontname,'FontSize',fontsize);
        ylabel(param.ylabel,'FontName',fontname,'FontSize',fontsize);
        if ~isempty(param.ylim)
            set(gca,'YLim',param.ylim);
        end
        legend(groupnames,'Location',param.legendlocation);
        export_fig(gcf,sprintf('figures/%s_%s_%s_%s.eps',conntype,measure,bands{bandidx},param.group),'-r300','-p0.01');
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
    thistestdata = testdata(groupvar == grouppairs(g,1) | groupvar == grouppairs(g,2),:,:);
    
    pet(g).confmat = confusionmat(thisgroupvar(~isnan(thispetdiag)),thispetdiag(~isnan(thispetdiag)));
    pet(g).confmat = pet(g).confmat*100 ./ repmat(sum(pet(g).confmat,2),1,2);
    [~,pet(g).chi2,pet(g).chi2pval] = crosstab(thisgroupvar(~isnan(thispetdiag)),thispetdiag(~isnan(thispetdiag)));
    pet(g).accu = round(sum(thisgroupvar(~isnan(thispetdiag))==thispetdiag(~isnan(thispetdiag)))*100/length(thisgroupvar(~isnan(thispetdiag))));
    if strcmp(param.plot,'on')
        fprintf('\nPET: %s vs %s Chi2 = %.2f, Chi2 p = %.1e, accu = %d%%.\n',...
            param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1},...
            pet(g).chi2,pet(g).chi2pval,pet(g).accu);
        
        if strcmp(param.plotcm,'on')
            % plot confusion matrix
            plotconfusionmat(pet(g).confmat,{param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1}});
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
            export_fig(gcf,sprintf('figures/PET_%s_vs_%s_cm.tiff',param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1}),'-r300','-p0.01');
            close(gcf);
        end
    end
    
    for d = 1:size(thistestdata,2)
        thistestdata2 = squeeze(thistestdata(:,d,:));
        
        [x,y,t,auc(g,d)] = perfcurve(thisgroupvar, thistestdata2,1);
        if auc(g,d) < 0.5
            auc(g,d) = 1-auc(g,d);
        end
        
        [~,bestthresh] = max(abs(y + (1-x) - 1));
        %         [~,bestthresh] = min(sqrt((0-x).^2 + (1-y).^2));
        youden(d) = t(bestthresh);
        thisconfmat = confusionmat(thisgroupvar,double(thistestdata(:,d) > t(bestthresh)));
        [~,chi2(g,d),chi2pval(g,d)] = crosstab(thisgroupvar,double(thistestdata(:,d) > t(bestthresh)));
        accu(g,d) = sum(thisgroupvar == double(thistestdata(:,d) > t(bestthresh)))*100/length(thisgroupvar);
        confmat(g,d,:,:) = thisconfmat;
        [pval(g,d),~,stat] = ranksum(thistestdata(thisgroupvar == 0,d),thistestdata(thisgroupvar == 1,d));
        n0 = sum(thisgroupvar == 0); n1 = sum(thisgroupvar == 1);
        U(g,d) = (n0*n1)+(n0*(n0+1))/2-stat.ranksum;
        U(g,d) = min(U(g,d),(n0*n1) - U(g,d));
    end
    
    [~,maxaucidx] = max(auc(g,:));
    stats(g).maxaucidx = maxaucidx;
    stats(g).U = U(g,maxaucidx);
    stats(g).auc = auc(g,maxaucidx);
    stats(g).pval = pval(g,maxaucidx);
    stats(g).confmat = squeeze(confmat(g,maxaucidx,:,:));
    if ~isempty(plottvals)
        stats(g).thresh = plottvals(maxaucidx);
    end
    stats(g).chi2 = chi2(g,maxaucidx);
    stats(g).chi2pval = chi2pval(g,maxaucidx);
    stats(g).accu = accu(g,maxaucidx);
    stats(g).youden = youden(maxaucidx);
    
    if strcmp(param.plot,'on')
        fprintf('%s %s: %s vs %s AUC = %.2f, J = %.2f, p = %.4f.\n',measure,bands{bandidx},...
            param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1},...
            auc(g,maxaucidx),(thisconfmat(2,2) + thisconfmat(1,1))/100 - 1, pval(g,maxaucidx));
        if strcmp(param.plotcm,'on')
            plotconfusionmat(squeeze(confmat(g,maxaucidx,:,:)),{param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1}});
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

if strcmp(param.plot,'on')
    %% plot mean graph
    figure('Color','white');
        figpos = get(gcf,'Position');
    if length(groups) == 2
        figpos(3) = figpos(3)*1/2;
    elseif length(groups) == 3
        figpos(3) = figpos(3)*2/3;
    end
    set(gcf,'Position',figpos);
    
    hold all
    
    boxh = notBoxPlot(nanmean(testdata,2),groupvar+1,0.5,'patch',ones(size(testdata,1),1));
    
    if length(groups) > 2
        jttestdata = nanmean(testdata(groupvar < 5,:),2);
        jtgroupvar = groupvar(groupvar < 5) + 1;
        [jtgroupvar,sortidx] = sort(jtgroupvar);
        jttestdata = jttestdata(sortidx);
        [~,JT,pval] = evalc('jttrend([jttestdata jtgroupvar])');
        if pval < 0.0001
            fprintf('\nJonckheere-Terpstra JT = %.2f, p = %.1e.\n',JT,pval);
        else
            fprintf('\nJonckheere-Terpstra JT = %.2f, p = %.4f.\n',JT,pval);
        end
    end
    
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
    if strcmp(param.legend,'off')
        legend('hide');
    end
    box off
    print(gcf,sprintf('figures/%s_avg_%s_%s_%s.tiff',conntype,measure,bands{bandidx},param.group),'-dtiff','-r300');
    close(gcf);
    
    %% plot auc
    figure('Color','white');
    hold all
    if ~isempty(plottvals)
        set(gca,'XDir','reverse');
        for g = 1:size(grouppairs,1)
            plot(plottvals,auc(g,:),'LineWidth',2);
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
    
    export_fig(gcf,sprintf('figures/%s_auc_%s_%s_%s.tiff',conntype,measure,bands{bandidx},param.group),'-r300','-p0.01');
    close(gcf);
    
end

% %% correlate with days since onset
% [rho,pval] = corr(testdata(~isnan(daysonset)),daysonset(~isnan(daysonset)),'type','Spearman');
% fprintf('Correlation with days since onset = %.2f, p = %.4f.\n',rho,pval);
%
scores = testdata;
group = groupvar;