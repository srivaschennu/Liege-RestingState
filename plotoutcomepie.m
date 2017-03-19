function plotoutcomepie(plotdata,varargin)

param = finputcheck(varargin, {
    'legend', 'string', {'on','off'}, 'off'; ...
    });

fontname = 'Helvetica';
fontsize = 24;

colorlist = [
    0 0.0 0.5
    0 0.5 0
    0.25  0.25  0.25
    ];

facecolorlist = [
    0.25  0.25 1
    0.25 1 0.25
    0.5 0.5 0.5
    ];

figure('Color','none');
figpos = get(gcf,'Position');
figpos(3) = figpos(3) * (2/3);
set(gcf,'Position',figpos);
p_h = pie(plotdata,repmat({' '},1,length(plotdata)));

patches = 1:2:length(p_h);
text = 2:2:length(p_h);
for g = 1:length(patches)
    set(p_h(patches(g)),'LineWidth',1,'FaceColor',facecolorlist(g,:),'EdgeColor',colorlist(g,:));
end

set(gca,'FontName',fontname,'FontSize',fontsize);
if strcmp(param.legend,'on')
    lg_h = legend('Outcome +ve','Outcome -ve','Outcome unknown');
    set(lg_h,'Location','SouthOutside','box','off');
end
set(gca,'Color','none');

export_fig(gcf,'figures/outcomepie.tiff','-r300','-p0.01');
close(gcf);
