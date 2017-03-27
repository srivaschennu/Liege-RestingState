function plotchanloc

loadpaths

chanlocmat = 'GSN-HydroCel-257.mat';

load sortedlocs

fontname = 'Helvetica';
fontsize = 32;

figure('Color','none');
figpos = get(gcf,'Position');
figpos(3:4) = figpos(3:4)*2;
set(gcf,'Position',figpos);

scatter3(cell2mat({sortedlocs.Y}),cell2mat({sortedlocs.X}),cell2mat({sortedlocs.Z}),...
    300,[0.0 0.0 0.75],'filled');

load([chanlocpath chanlocmat]);
for c = 1:length(name1020)
    chanidx = find(strcmp(channame{idx1020(c)},{sortedlocs.labels}));
    text(sortedlocs(chanidx).Y+.2,sortedlocs(chanidx).X- (.2 * sign(sortedlocs(chanidx).X)),sortedlocs(chanidx).Z,name1020{c},...
        'FontName',fontname,'FontSize',fontsize,'FontWeight','bold');
end
set(gca,'Visible','off');
view(0,90);
axis image
export_fig(gcf,'figures/plotchanloc.eps','-d300','-transparent');
close(gcf);