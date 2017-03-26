function plotchanloc

load sortedlocs

fontname = 'Helvetica';
fontsize = 12;

figure('Color','none');
figpos = get(gcf,'Position');
figpos(3:4) = figpos(3:4)*2;
set(gcf,'Position',figpos);

scatter3(cell2mat({sortedlocs.Y}),cell2mat({sortedlocs.X}),cell2mat({sortedlocs.Z}),...
    300,[0.0 0.0 0.75],'filled');

% for c = 1:length(sortedlocs)
%     text(sortedlocs(c).Y+.1,sortedlocs(c).X+.1,sortedlocs(c).Z,sortedlocs(c).labels,...
%         'FontName',fontname,'FontSize',fontsize,'FontWeight','bold');
% end
set(gca,'Visible','off');
view(0,90);
axis image
export_fig(gcf,'figures/plotchanloc.eps','-d300','-transparent');
close(gcf);