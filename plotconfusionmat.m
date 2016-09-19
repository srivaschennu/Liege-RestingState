function plotconfusionmat(confmat,groupnames,varargin)

param = finputcheck(varargin, {
    'xlabel', 'string', [], ''; ...
    'ylabel', 'string', [], ''; ...
    });

fontname = 'Helvetica';
fontsize = 32;

confmat = confmat*100 ./ repmat(sum(confmat,2),1,size(confmat,2));

figure('Color','white');
imshow(confmat,'InitialMagnification',5000);

figpos = get(gcf,'Position');
figpos(3:4) = 1000;
set(gcf,'Position',figpos);

colormap(jet);
caxis([0 100]);

set(gca,'YDir','normal','Visible','on',...
    'XTick',1:size(confmat,2),'XTickLabel',groupnames,...
    'YTick',1:size(confmat,1),'YTickLabel',groupnames,...
    'FontName',fontname,'FontSize',fontsize-6);
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

for s = 1:size(confmat,1)-1
    line(s+[0.5 0.5],[0.5 size(confmat,1)+0.5],'LineWidth',1,'Color','black');
    line([0.5 size(confmat,2)+0.5],s+[0.5 0.5],[1.5 1.5],'LineWidth',1,'Color','black');
end

if ~isempty(param.xlabel)
    xlabel(param.xlabel,'FontName',fontname,'FontSize',fontsize-6);
else
    xlabel('EEG prediction','FontName',fontname,'FontSize',fontsize-6);
end
if ~isempty(param.ylabel)
    ylabel(param.ylabel,'FontName',fontname,'FontSize',fontsize-6);
else
    ylabel('CRS-R diagnosis','FontName',fontname,'FontSize',fontsize-6);
end