function features = getfeatures(listname,conntype,measure,bandidx,varargin)

param = finputcheck(varargin, {
    'changroup', 'string', [], 'all'; ...
    'changroup2', 'string', [], 'all'; ...
    });

loadpaths
load sortedlocs

weiorbin = 3;

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
    trange = [0.9 0.1];
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
