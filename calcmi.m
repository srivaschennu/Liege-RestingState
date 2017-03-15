function calcmi(listname,conntype,varargin)

loadpaths

param = finputcheck(varargin, {
    'randratio', 'string', {'on','off'}, 'off'; ...
    });

load(sprintf('%s/%s/graphdata_%s_%s.mat',filepath,conntype,listname,conntype), 'graph');
if strcmp(param.randratio,'on')
    if exist(sprintf('%s/%s/graphdata_%s_rand_%s.mat',filepath,conntype,listname,conntype),'file')
        randgraph = load(sprintf('%s/%s/graphdata_%s_rand_%s.mat',filepath,conntype,listname,conntype));
    else
        error('%s/%s/graphdata_%s_rand_%s.mat not found!');
    end
end

weiorbin = 3;

if any(strcmp('mutual information',graph(:,1)))
    midx = find(strcmp('mutual information',graph(:,1)));
else
    graph{end+1,1} = 'mutual information';
    midx = size(graph,1);
end

modinfo = graph{strcmp('modules',graph(:,1)),weiorbin};
mutinfo = zeros(size(modinfo,1),size(modinfo,1),size(modinfo,2),size(modinfo,3));

for bandidx = 3%1:size(modinfo,2)
    for t = 1:size(modinfo,3)
        for s1 = 1:size(modinfo,1)
            for s2 = 1:size(modinfo,1)
                if s1 < s2
                    mutinfo(s1,s2,bandidx,t) = ...
                        corr(squeeze(modinfo(s1,bandidx,t,:)),squeeze(modinfo(s2,bandidx,t,:)));
%                     [~, mutinfo(s1,s2,bandidx,t)] = ...
%                         partition_distance(squeeze(modinfo(s1,bandidx,t,:)),squeeze(modinfo(s2,bandidx,t,:)));
                elseif s1 > s2
                    mutinfo(s1,s2,bandidx,t) = mutinfo(s2,s1,bandidx,t);
                elseif s1 == s2
                    mutinfo(s1,s2,bandidx,t) = 0;
                end
            end
        end
    end
end

graph{midx,weiorbin} = mutinfo;
fprintf('Appending mutual information to %s/%s/graphdata_%s_%s.mat.\n',filepath,conntype,listname,conntype);
save(sprintf('%s/%s/graphdata_%s_%s.mat',filepath,conntype,listname,conntype), 'graph','-append');

if strcmp(param.randratio,'on')
    randmodinfo = randgraph.graph{strcmp('modules',randgraph.graph(:,1)),weiorbin};
    randmutinfo = zeros(size(randmodinfo,1),size(randmodinfo,1),size(randmodinfo,2),size(randmodinfo,3),size(randmodinfo,5));
    fprintf('Processing %d randomised matrices:',size(randmodinfo,5));
    for r = 1:size(randmodinfo,5)
        fprintf(' %d',r);
        for bandidx = 1:size(randmodinfo,2)
            for t = 1:size(randmodinfo,3)
                for s1 = 1:size(randmodinfo,1)
                    for s2 = 1:size(randmodinfo,1)
                        if s1 < s2
                            [~, randmutinfo(s1,s2,bandidx,t,r)] = ...
                                partition_distance(squeeze(randmodinfo(s1,bandidx,t,:,r)),squeeze(randmodinfo(s2,bandidx,t,:,r)));
                        elseif s1 > s2
                            randmutinfo(s1,s2,bandidx,t,r) = randmutinfo(s2,s1,bandidx,t,r);
                        elseif s1 == s2
                            randmutinfo(s1,s2,bandidx,t,r) = 0;
                        end
                    end
                end
            end
        end
    end
    fprintf('\n');
    randgraph.graph{midx,weiorbin} = randmutinfo;
    fprintf('Appending randomised mutual information to %s/%s/graphdata_%s_rand_%s.mat.\n',filepath,conntype,listname,conntype);
    save(sprintf('%s/%s/graphdata_%s_rand_%s.mat',filepath,conntype,listname,conntype), '-append','-struct','randgraph','graph');
end
