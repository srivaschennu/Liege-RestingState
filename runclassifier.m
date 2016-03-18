function runclassifier(listname,varargin)

param = finputcheck(varargin, {
    'group', 'string', [], 'crsdiag'; ...
    'groupnames', 'cell', {}, {'UWS','MCS','EMCS','LIS'}; ...
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
    'ftdwpli','median',1
    'ftdwpli','median',2
    'ftdwpli','median',3
%     'ftdwpli','participation coefficient',1
%     'ftdwpli','participation coefficient',2
%     'ftdwpli','participation coefficient',3
%     'ftdwpli','small-worldness',1
%     'ftdwpli','small-worldness',2
%     'ftdwpli','small-worldness',3
%     'ftdwpli','centrality',1
%     'ftdwpli','centrality',2
%     'ftdwpli','centrality',3
%     'ftdwpli','modular span',1
%     'ftdwpli','modular span',2
%     'ftdwpli','modular span',3
    };
subjlist = eval(listname);

features = zeros(size(subjlist,1),size(featlist,1));
featnames = cell(1,size(featlist,1));
for f = 1:size(featlist,1)
    [features(:,f),groupvar] = plotmeasure(listname,featlist{f,:},'noplot','on',varargin{:});
    featnames{f} = strrep(strrep(sprintf('%s_%s',featlist{f,2},bands{featlist{f,3}}),' ','_'),'-','_');
end

groups = unique(groupvar(~isnan(groupvar)));
grouppairs = nchoosek(groups,2);

fprintf('\n');
for g = 1:size(grouppairs,1)
    feattable = array2table(features(groupvar == grouppairs(g,1) | groupvar == grouppairs(g,2),:),'VariableNames',featnames);
    grouptable = array2table(groupvar(groupvar == grouppairs(g,1) | groupvar == grouppairs(g,2)),'VariableNames',{'group'});
    datatable = horzcat(feattable,grouptable);
    svmmodel = fitcsvm(datatable,'group',...
        'LeaveOut','on',...
        'KernelScale','auto','Standardize',true,'KernelFunction','RBF');
    fprintf('%s vs. %s accuracy = %.2f%%.\n',param.groupnames{grouppairs(g,1)+1},...
        param.groupnames{grouppairs(g,2)+1}, (1-kfoldLoss(svmmodel))*100);
end