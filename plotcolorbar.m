function plotcolorbar(clim)

figure('Color','white','Name','colorbar');
set(gca,'Visible','off','FontSize',50);
caxis(clim);

cmap = jet;
cmap = cmap(size(cmap,1)/2:end,:);

cmap = lines;
cmap = cmap([3 1 4],:);

colormap(cmap);
cb_h = colorbar('Location','West');
figname = get(gcf,'Name');

set(gcf,'Color','black');
set(cb_h,'YColor',[1 1 1])
set(cb_h,'YTick',[0 1],'YTickLabel',{'Low','High'})

set(cb_h,'YTick',[]);

export_fig(gcf,['figures/' figname '.tif'],'-r300');
close(gcf);