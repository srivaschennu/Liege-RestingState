function runclassifier(listname,varargin)

param = finputcheck(varargin, {
    'changroup', 'string', [], 'all'; ...
    'changroup2', 'string', [], 'all'; ...
    'group', 'string', [], 'crsdiag'; ...
    'grouppair', 'real', [], []; ...
    'groupnames', 'cell', {}, {'UWS','MCS'}; ...
    'runpca', 'string', {'true','false'}, 'false'; ...
    'train', 'string', {'true','false'}, 'false'; ...
    });

loadpaths
loadsubj
changroups
weiorbin = 3;
plottvals = [];
load sortedlocs

subjlist = eval(listname);
refdiag = cell2mat(subjlist(:,2));
crsdiag = cell2mat(subjlist(:,3));
crsaware = double(cell2mat(subjlist(:,3)) > 0);
petdiag = cell2mat(subjlist(:,4));
tennis = cell2mat(subjlist(:,5));
etiology = cell2mat(subjlist(:,6));
daysonset = cell2mat(subjlist(:,9));
outcome = double(cell2mat(subjlist(:,10)) > 2);
outcome(isnan(cell2mat(subjlist(:,10)))) = NaN;
mcstennis = tennis .* crsdiag;
mcstennis(crsdiag == 0) = NaN;
crs = cell2mat(subjlist(:,11));

groupvar = eval(param.group);

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

if isempty(param.grouppair)
    grouppair = [0 1];
else
    grouppair = param.grouppair;
end

groupvar = groupvar(groupvar == grouppair(1) | groupvar == grouppair(2));
[~,~,groupvar] = unique(groupvar);
groupvar = groupvar-1;

for f = 1:size(featlist,1)
    if f ~= 18
        continue;
    end
    fprintf('Feature set: ');
    disp(featlist(f,:));
    conntype = featlist{f,1};
    measure = featlist{f,2};
    bandidx = featlist{f,3};
    
    if strcmpi(measure,'power')
        %     load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype));
        load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype),'bandpower');
        features = squeeze(bandpower(:,bandidx,ismember({sortedlocs.labels},eval(param.changroup))) * 100);
    elseif strcmpi(measure,'specent')
        %     load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype));
        load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype),'specent');
        features = squeeze(specent(:,ismember({sortedlocs.labels},eval(param.changroup))));
    elseif strcmpi(measure,'median')
        load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype),'allcoh');
        features = median(allcoh(:,bandidx,ismember({sortedlocs.labels},eval(param.changroup)),ismember({sortedlocs.labels},eval(param.changroup2))),4);
    elseif strcmpi(measure,'mean')
        load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype),'allcoh');
        features = mean(allcoh(:,bandidx,ismember({sortedlocs.labels},eval(param.changroup)),ismember({sortedlocs.labels},eval(param.changroup2))),4);
    elseif strcmpi(measure,'refdiag')
        features = refdiag;
    else
        trange = [0.5 0.1];
        load(sprintf('%s%s//graphdata_%s_%s.mat',filepath,conntype,listname,conntype),'graph','tvals');
        trange = (tvals <= trange(1) & tvals >= trange(2));
        plottvals = tvals(trange);
        
        if strcmpi(measure,'small-worldness')
            randgraph = load(sprintf('%s/%s/graphdata_%s_rand_%s.mat',filepath,conntype,listname,conntype));
            graph{end+1,1} = 'small-worldness';
            graph{end,2} = ( mean(graph{1,2},4) ./ mean(randgraph.graph{1,2},4) ) ./ ( graph{2,2} ./ randgraph.graph{2,2} ) ;
            graph{end,3} = ( mean(graph{1,3},4) ./ mean(randgraph.graph{1,3},4) ) ./ ( graph{2,3} ./ randgraph.graph{2,3} ) ;
        end
        
        %     if ~strcmpi(measure,'small-worldness')
        %         m = find(strcmpi(measure,graph(:,1)));
        %         graph{m,2} = graph{m,2} ./ randgraph.graph{m,2};
        %         graph{m,3} = graph{m,3} ./ randgraph.graph{m,3};
        %     end
        
        m = find(strcmpi(measure,graph(:,1)));
        features = squeeze(graph{m,weiorbin}(:,bandidx,trange,:));
    end
    
    features = features(groupvar == grouppair(1) | groupvar == grouppair(2),:,:);
    
    if strcmp(param.train,'true')
        clsyfyr(f) = buildsvm(features,groupvar,'train','true');
    else
        clsyfyr(f) = buildsvm(features,groupvar,'runpca','false');
        
        fprintf('%s vs %s: AUC = %.2f, p = %.5f, Chi2 = %.2f, Chi2 p = %.4f, accu = %d%%.\n',...
            param.groupnames{grouppair(1)+1},param.groupnames{grouppair(2)+1},...
            clsyfyr(f).auc,clsyfyr(f).pval,clsyfyr(f).chi2,clsyfyr(f).chi2pval,clsyfyr(f).accu);
    end
    
    groupnames = param.groupnames;
    if strcmp(param.train,'true')
        save(sprintf('clsyfyr_%s_train.mat',param.group),'clsyfyr','grouppair','groupnames','featlist');
    else
        save(sprintf('clsyfyr_%s.mat',param.group),'clsyfyr','grouppair','groupnames','featlist');
    end
end

