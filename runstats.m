function runstats(listname,varargin)


param = finputcheck(varargin, {
    'group', 'string', [], 'crsdiag'; ...
    'groupnames', 'cell', {}, {'UWS','MCS','EMCS','LIS'}; ...
    'xlabel', 'string', [], 'EEG diagnosis'; ...
    'ylabel', 'string', [], 'CRS-R diagnosis'; ...
    'alpha', 'real', [], 0.05; ...
    });

loadsubj

bands = {
    'delta'
    'theta'
    'alpha'
    };

featlist = {
    'ftdwpli','power',1
    'ftdwpli','power',2
    'ftdwpli','power',3
    'ftdwpli','median',1
    'ftdwpli','median',2
    'ftdwpli','median',3
    'ftdwpli','clustering',1
    'ftdwpli','clustering',2
    'ftdwpli','clustering',3
    'ftdwpli','characteristic path length',1
    'ftdwpli','characteristic path length',2
    'ftdwpli','characteristic path length',3
    'ftdwpli','modularity',1
    'ftdwpli','modularity',2
    'ftdwpli','modularity',3
    'ftdwpli','participation coefficient',1
    'ftdwpli','participation coefficient',2
    'ftdwpli','participation coefficient',3
    'ftdwpli','modular span',1
    'ftdwpli','modular span',2
    'ftdwpli','modular span',3
    };

for f = 1:size(featlist,1)
    [measure,groupvar] = plotmeasure(listname,featlist{f,:},'noplot','on',varargin{:});
    measure = mean(measure(~isnan(groupvar),:),2);
    groupvar = groupvar(~isnan(groupvar),1);
    
    if f == 1
        grouplist = cell(size(groupvar));
        groups = unique(groupvar(~isnan(groupvar)));
        for g = 1:length(groups)
            grouplist(groupvar == groups(g)) = {param.groupnames{g}};
        end
    end
    
    [~,anovatbl] = anova1(measure,grouplist,'off');
    
    fprintf('%s - %s: F(%d) = %.2f, p = %.4f.\n',featlist{f,2},bands{featlist{f,3}},...
        anovatbl{2,3},anovatbl{2,5},anovatbl{2,6});
end

fprintf('\n');
