function plotpie

loadsubj
subjlist = patlist;

fontname = 'Helvetica';
fontsize = 24;

colorlist = [
    0 0.0 0.5
    0 0.5 0
    0.5 0.0 0
    ];

facecolorlist = [
    0.25  0.25 1
    0.25 1 0.25
    1 0.25 0.25
    ];

refdiag = cell2mat(subjlist(:,2));
refaware = double(cell2mat(subjlist(:,2)) > 0);
refaware(isnan(refdiag)) = NaN;

crsdiag = cell2mat(subjlist(:,3));
crsaware = double(cell2mat(subjlist(:,3)) > 0);

plotdata(1) = sum(refaware == 0 & crsaware == 0);
plotdata(2) = sum(refaware > 0 & crsaware > 0);
plotdata(3) = sum(refaware == 0 & crsaware > 0);

explode = [1 0 1];

figure('Color','white');
p_h = pie(plotdata,explode,mat2cell(num2str(plotdata'),[1 1 1],2)');

patches = 1:2:length(p_h);
text = 2:2:length(p_h);
textpos = [
    -.45 .55
    0 -.5
    .5 .5
    ];
    
for g = 1:length(patches)
    set(p_h(patches(g)),'LineWidth',1,'FaceColor',facecolorlist(g,:),'EdgeColor',colorlist(g,:));
    set(p_h(text(g)),'FontName',fontname,'FontSize',fontsize,'Color','white','Position',textpos(g,:));
end

set(gca,'FontName',fontname,'FontSize',fontsize);
lg_h = legend('Accurate UWS diagnosis','Accurate MCS diagnosis','Misdiagnosed as UWS');
set(lg_h,'Location','SouthOutside','box','off');
export_fig(gcf,'figures/piediag.tiff','-r300','-p0.01');
close(gcf);

