function plotcolorbar(clim)

figure('Color','white','Name','colorbar');
set(gca,'Visible','off','FontSize',70);
caxis(clim);
colormap(jet);
colorbar('Location','West');
figname = get(gcf,'Name');
export_fig(gcf,['figures/' figname '.tif'],'-r300');
close(gcf);