function runclassifier(listname,varargin)

param = finputcheck(varargin, {
    'group', 'string', [], 'crsdiag'; ...
    'groupnames', 'cell', {}, {'UWS','MCS','EMCS','LIS'}; ...
    'xlabel', 'string', [], 'EEG diagnosis'; ...
    'ylabel', 'string', [], 'CRS-R diagnosis'; ...
    });
loadsubj

bands = {
    'delta'
    'theta'
    'alpha'
    };

featlist = {
    %     'ftdwpli','power',1
    %     'ftdwpli','power',2
    %     'ftdwpli','power',3
%     'ftdwpli','median',1
%     'ftdwpli','median',2
%     'ftdwpli','median',3
    %     'ftdwpli','global efficiency',1
    %     'ftdwpli','global efficiency',2
    %     'ftdwpli','global efficiency',3
        'ftdwpli','participation coefficient',1
        'ftdwpli','participation coefficient',2
        'ftdwpli','participation coefficient',3
    %     'ftdwpli','centrality',1
    %     'ftdwpli','centrality',2
    %     'ftdwpli','centrality',3
    %     'ftdwpli','modularity',1
    %     'ftdwpli','modularity',2
    %     'ftdwpli','modularity',3
    %     'ftdwpli','clustering',1
    %     'ftdwpli','clustering',2
    %     'ftdwpli','clustering',3
    %     'ftdwpli','modular span',1
    %     'ftdwpli','modular span',2
    %     'ftdwpli','modular span',3
    };

subjlist = eval(listname);

features = [];
featnames = cell(1,size(featlist,1));
for f = 1:size(featlist,1)
    [thisfeat,groupvar,~,] = plotmeasure(listname,featlist{f,:},varargin{:});
    features = cat(2,features,thisfeat);
    %     featnames{f} = repmat(strrep(strrep(sprintf('%s_%s',featlist{f,2},bands{featlist{f,3}}),' ','_'),'-','_'),1,size(thisfeat,1));
end

groups = unique(groupvar(~isnan(groupvar)));
grouppairs = nchoosek(groups,2);

fontname = 'Helvetica';
fontsize = 24;

fprintf('\n');
for g = 1:size(grouppairs,1)
    feattable = array2table(features(groupvar == grouppairs(g,1) | groupvar == grouppairs(g,2),:));
    grouptable = array2table(groupvar(groupvar == grouppairs(g,1) | groupvar == grouppairs(g,2)),'VariableNames',{'group'});
    datatable = horzcat(feattable,grouptable);
    svmmodel = fitcsvm(datatable,'group',...
        'LeaveOut','on',...
        'KernelScale','auto','Standardize',true,'KernelFunction','RBF');
    fprintf('%s vs. %s accuracy = %.2f%%.\n',param.groupnames{grouppairs(g,1)+1},...
        param.groupnames{grouppairs(g,2)+1}, (1-kfoldLoss(svmmodel))*100);
    
    confmat = confusionmat(table2array(grouptable),kfoldPredict(svmmodel));
    confmat = confmat*100 ./ repmat(sum(confmat,2),1,2);
    
    figure('Color','white');
    imshow(confmat,'InitialMagnification',20000);
    figpos = get(gcf,'Position');
    figpos(3:4) = 1000;
    set(gcf,'Position',figpos);

    colormap(jet);
    caxis([0 100]);

    set(gca,'YDir','normal','Visible','on','FontName',fontname,'FontSize',fontsize,...
        'XTick',[1 2],'XTickLabel',{param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1}},...
        'YTick',[1 2],'YTickLabel',{param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1}});
    xlabel(param.xlabel,'FontName',fontname,'FontSize',fontsize);
    ylabel(param.ylabel,'FontName',fontname,'FontSize',fontsize);
    for c1 = 1:size(confmat,1)
        for c2 = 1:size(confmat,2)
            h_txt = text(c2-0.07,c1,sprintf('%d%%',round(confmat(c1,c2))),'FontName',fontname,'FontSize',fontsize);
            if confmat(c1,c2) < 50
                set(h_txt,'Color','white');
            else
                set(h_txt,'Color','black');
            end
        end
    end
    line([1.5 1.5],[0.5 2.5],'LineWidth',1,'Color','black');
    line([0.5 2.5],[1.5 1.5],'LineWidth',1,'Color','black');
    export_fig(gcf,sprintf('figures/%s_vs_%s_cm.tiff',param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1}));
    close(gcf);
end

