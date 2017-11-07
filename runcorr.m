function runcorr(listname,conntype,bandidx,varargin)

loadpaths
loadsubj

bands = {
    'delta'
    'theta'
    'alpha'
    'beta'
    'gamma'
    };

nperm = 2000;
rng('
subjlist = eval(listname);

crs = cell2mat(subjlist(:,11));
patwithcrs = ~isnan(crs);
crs = crs(patwithcrs);

load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype));

nedges = ((size(allcoh,3)*size(allcoh,4)) - size(allcoh,3)) / 2;

allcorr = zeros(nperm+1,nedges);
allp = zeros(nperm+1,nedges);
ind_upper = find(triu(ones(size(allcoh,3),size(allcoh,4)),1))';

for n = 1:nperm+1
    if n > 1
        randcrs = crs(randperm(randstr,length(crs)));
        if mod(n,50) == 0
            fprintf('..%d',n);
        end
    else
        fprintf('Starting');
        randcrs = crs;
    end
    [allcorr(n,:), allp(n,:)] = corr(randcrs,squeeze(allcoh(patwithcrs,bandidx,ind_upper)),'type','spearman');
end
fprintf('\n');

save(sprintf('%s%s/%s_%s_corr.mat',filepath,conntype,listname,bands{bandidx}),'allcorr','allp');

