function plotcolorbar(clim)

figure('Color','white','Name','colorbar');
set(gca,'Visible','off','FontSize',75);
caxis(clim);
colormap(jet);
cb_h = colorbar('Location','West');
figname = get(gcf,'Name');
export_fig(gcf,['figures/' figname '.tif'],'-r300');
close(gcf);