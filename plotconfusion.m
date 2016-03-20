function plotconfusion(confmat,groupnames)

fontname = 'Helvetica';
fontsize = 24;

figure('Color','white');
imshow(confmat,'InitialMagnification',5000);

figpos = get(gcf,'Position');
figpos(3:4) = 1000;
set(gcf,'Position',figpos);

colormap(jet);
caxis([0 100]);

set(gca,'YDir','normal','Visible','on',...
    'XTick',[1 2],'XTickLabel',groupnames,...
    'YTick',[1 2],'YTickLabel',groupnames);
for c1 = 1:size(confmat,1)
    for c2 = 1:size(confmat,2)
        h_txt = text(c2-0.07,c1,sprintf('%d%%',round(confmat(c1,c2))),'FontName',fontname,'FontSize',fontsize);
        if confmat(c1,c2) > 30 && confmat(c1,c2) < 70
            set(h_txt,'Color','black');
        else
            set(h_txt,'Color','white');
        end
    end
end
line([1.5 1.5],[0.5 2.5],'LineWidth',1,'Color','black');
line([0.5 2.5],[1.5 1.5],'LineWidth',1,'Color','black');