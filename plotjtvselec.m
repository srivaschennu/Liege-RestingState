function plotjtvselec

% plotdata(:,1) = [
% .8184
% .8159
% .8235
% .7596
% .7877
% ];

jtdata(:,1) = [
3.47
3.44
3.24
2.68
2.58
4.1
];

numchan = 173;

xticks = {
    num2str(round(numchan));
    num2str(round(numchan/2));
    num2str(round(numchan/4));
    num2str(round(numchan/8));
    num2str(round(numchan/16));
    };

fontname = 'Helvetica';
fontsize = 26;

figure('Color','white');
hold all

plot(1:5,jtdata(1:5),'LineWidth',3);
line(xlim,[jtdata(6) jtdata(6)],'LineWidth',3,'Color','red','LineStyle','--');
set(gca,'FontName',fontname,'FontSize',fontsize,'XTickLabel',xticks);
xlabel('Number of electrodes','FontName',fontname,'FontSize',fontsize);
ylabel('JT statistic','FontName',fontname,'FontSize',fontsize);
box on
legend('Median dwPLI','Frontoparietal dwPLI','Location','SouthWest');
export_fig('figures/plotjtvselec.tiff','-d300','-p0.01');
close(gcf);