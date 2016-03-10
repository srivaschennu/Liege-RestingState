function groupgraph(listname,conntype,varargin)

loadpaths
loadsubj

param = finputcheck(varargin, {
    'randomise', 'string', {'on','off'}, 'off'; ...
    'latticise', 'string', {'on','off'}, 'off'; ...
    });

subjlist = eval(listname);

if strcmp(param.randomise,'on')
    savename = sprintf('%s/%s/graphdata_%s_rand_%s.mat',filepath,conntype,listname,conntype);
    filesuffix = 'randgraph';
elseif strcmp(param.latticise,'on')
    savename = sprintf('%s/%s/graphdata_%s_latt_%s.mat',filepath,conntype,listname,conntype);
    filesuffix = 'lattgraph';
else
    savename = sprintf('%s/%s/graphdata_%s_%s.mat',filepath,conntype,listname,conntype);
    filesuffix = 'graph';
end

for s = 1:size(subjlist,1)
    basename = subjlist{s,1};
    grp(s,1) = subjlist{s,3};
    
    fprintf('Processing %s.\n',basename);
    
    loadname = sprintf('%s/%s/%s%s%s.mat',filepath,conntype,basename,conntype,filesuffix);
    load(loadname);
    if strcmp(param.randomise,'on')
        for m = 1:size(graphdata,1)
            graphdata{m,2} = mean(graphdata{m,2},ndims(graphdata{m,2}));
            graphdata{m,3} = mean(graphdata{m,3},ndims(graphdata{m,3}));
        end
    end
    
    if s == 1
        graph = graphdata(:,1);
        for m = 1:size(graph,1)
            graph{m,2} = zeros([size(subjlist,1) size(graphdata{m,2})]);
            graph{m,3} = zeros([size(subjlist,1) size(graphdata{m,3})]);
        end
    end
    
    for m = 1:size(graph,1)
        graph{m,2}(s,:) = graphdata{m,2}(:);
        graph{m,3}(s,:) = graphdata{m,3}(:);
    end
end

save(savename, 'graph', 'grp', 'tvals', 'subjlist');