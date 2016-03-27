function plotdiag(listname)

loadsubj

colorlist = [
    0 0.25   0
    0.25 0   0
    ];

facecolorlist = [
    0 0.6 0
    0.75 0 0
    ];

subjlist = eval(listname);

fontname = 'Helvetica';
fontsize = 20;

admdiag = cell2mat(subjlist(:,2));
crsdiag = cell2mat(subjlist(:,3));

load('combclsyfyr_crsdiag.mat');
eegdiag = zeros(size(crsdiag,1),1);
eegdiag(crsdiag == 0 | crsdiag == 1) = clsyfyr(1).predlabels;
eegdiag(crsdiag == 0 | crsdiag == 2) = eegdiag(crsdiag == 0 | crsdiag == 2) | clsyfyr(2).predlabels;

correct_admdiag = logical(admdiag(~isnan(admdiag))) == logical(crsdiag(~isnan(admdiag)));
correct_admdiag_plus_eeg = (logical(admdiag(~isnan(admdiag))) | logical(eegdiag(~isnan(admdiag)))) == logical(crsdiag(~isnan(admdiag)));
diaginfo = [
    sum(correct_admdiag == 1) sum(correct_admdiag == 0); ...
    sum(correct_admdiag_plus_eeg == 1) sum(correct_admdiag_plus_eeg == 0)
    ];

figure('Color','white');
p_h = pie(diaginfo(1,:));
patches = [1 3];
text = [2 4];
for g = 1:length(patches)
    set(p_h(patches(g)),'LineWidth',1,'FaceColor',facecolorlist(g,:),'EdgeColor',colorlist(g,:));
    textpos = get(p_h(text(g)),'Position');
    if g == 1
        textpos(1) = textpos(1) + 0.5;
        textpos(2) = textpos(2) + 0.5;
    else
        textpos(1) = textpos(1) - 0.5;
        textpos(2) = textpos(2) - 0.5;
    end
    set(p_h(text(g)),'FontName',fontname,'FontSize',fontsize,'Color','white','Position',textpos);
end
set(gca,'FontName',fontname,'FontSize',fontsize);
lg_h = legend('Accurate clinical diagnosis','Misdiagnosed');
set(lg_h,'Location','SouthOutside','box','off');
export_fig(gcf,'figures/pie_admdiag.tiff','-r200');
close(gcf);

figure('Color','white');
p_h = pie(diaginfo(2,:));
patches = [1 3];
text = [2 4];
for g = 1:length(patches)
    set(p_h(patches(g)),'LineWidth',1,'FaceColor',facecolorlist(g,:),'EdgeColor',colorlist(g,:));
    textpos = get(p_h(text(g)),'Position');
    if g == 1
        textpos(1) = textpos(1) + 0.5;
        textpos(2) = textpos(2) + 0.5;
    else
        textpos(1) = textpos(1) - 0.2;
        textpos(2) = textpos(2) - 0.5;
    end
    set(p_h(text(g)),'FontName',fontname,'FontSize',fontsize,'Color','white','Position',textpos);
end
set(gca,'FontName',fontname,'FontSize',fontsize);
lg_h = legend('Accurate clinical or EEG diagnosis','Misdiagnosed');
set(lg_h,'Location','SouthOutside','box','off');
export_fig(gcf,'figures/pie_admeegdiag.tiff','-r200');
close(gcf);

[~,pval,stats] = fishertest(diaginfo');
fprintf('Fisher''s exact test odds ratio = %.2f, p = %.4f.\n',stats.OddsRatio,pval);
