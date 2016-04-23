function plotmeangraph(listname,conntype,bandidx)

loadpaths

load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype));
load sortedlocs

loadsubj
subjlist = eval(listname);

grp = cell2mat(subjlist(:,2:end));

bands = {
    'delta'
    'theta'
    'alpha'
    'beta'
    'gamma'
    };

plotqt = 0.7;

grouplist = {
    'UWS'
    'MCS'
    'EMCS'
    'LIS'
    };

for g = 1:length(grouplist)
    groupcoh(g,:,:) = squeeze(mean(allcoh(grp(:,2) == g-1,bandidx,:,:),1));
    threshcoh(g,:,:) = threshold_proportional(squeeze(groupcoh(g,:,:)),1-plotqt);
    for c = 1:size(threshcoh,2)
        groupdeg(g,c) = sum(threshcoh(g,c,:))/(size(threshcoh,2)-1);
    end
end

erange = [min(nonzeros(threshcoh(:))) max(threshcoh(:))];
vrange = [min(nonzeros(groupdeg(:))) max(groupdeg(:))];

for g = 1:length(grouplist)
    while true
        minfo(g,:) = plotgraph3d(squeeze(groupcoh(g,:,:)),sortedlocs,'sortedlocs.spl','plotqt',plotqt,'escale',erange,'vscale',vrange,'cshift',0.35,'numcolors',5);
        if strcmp(questdlg('Save figure?',mfilename,'Yes','No','Yes'), 'Yes')
            break
        end
        close(gcf);
    end
    
    camva(8);
    camtarget([-9.7975  -28.8277   41.8981]);
    campos([-1.7547    1.7161    1.4666]*1000);
    fprintf('%s %s - number of modules: %d\n',grouplist{g},bands{bandidx},length(unique(minfo(g,:))));
    set(gcf,'Name',sprintf('%s %s',grouplist{g},bands{bandidx}));
    set(gcf,'InvertHardCopy','off');
    print(gcf,sprintf('figures/meangraph_%s_%s.tif',grouplist{g},bands{bandidx}),'-dtiff','-r100');
%     saveas(gcf,sprintf('figures/meangraph_%s_%s.fig',grouplist{g},bands{bandidx}));
    close(gcf);
end