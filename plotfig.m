function plotfig(basename)

loadpaths

load([filepath 'ftdwpli/' basename 'ftdwplifdr.mat']);
load sortedlocs.mat

chanlist = {sortedlocs.labels}';
[sortedchan,sortidx] = sort({chanlocs.labels});
if ~strcmp(chanlist,sortedchan')
    error('Channel names do not match!');
end
matrix = matrix(:,sortidx,sortidx);

plotgraph3d(squeeze(matrix(3,:,:)),'sortedlocs.spl','escale',[0 1],'vscale',[0 0.1],'plotqt',0.8);

camva(8);
camtarget([-9.7975  -28.8277   41.8981]);
campos([-1.7547    1.7161    1.4666]*1000);
set(gcf,'InvertHardCopy','off');
print(gcf,sprintf('figures/%s_topograph.tif',basename),'-dtiff','-r400');
close(gcf);
