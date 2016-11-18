function calccorr(listname,conntype,varargin)

loadpaths

load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype));
load(sprintf('%s/%s/graphdata_%s_%s.mat',filepath,conntype,listname,conntype));

weiorbin = 3;

loadsubj
subjlist = eval(listname);
crsdiag = cell2mat(subjlist(:,3));

if any(strcmp('mutual information',graph(:,1)))
    midx = find(strcmp('mutual information',graph(:,1)));
else
    graph{end+1,1} = 'mutual information';
    midx = size(graph,1);
end

modinfo = graph{strcmp('modules',graph(:,1)),weiorbin};
mutinfo = zeros(size(modinfo,1),size(modinfo,2),size(modinfo,3));

alldeg = zeros(size(allcoh,1),size(allcoh,2),length(tvals),size(allcoh,3));
for bandidx = 1:size(modinfo,2)
    for s = 1:size(modinfo,1)
        matrix = squeeze(allcoh(s,bandidx,:,:));
        for t = 1:length(tvals)
            alldeg(s,bandidx,t,:) = sum(threshold_proportional(matrix,tvals(t)),2)/(size(matrix,2)-1);
        end
    end
end

for bandidx = 1:size(modinfo,2)
    for t = 1:size(modinfo,3)
        meanctrl = squeeze(mean(alldeg(crsdiag == 5,bandidx,t,:),1));
        mutinfo(:,bandidx,t) = corr(squeeze(alldeg(:,bandidx,t,:))',meanctrl,'type','spearman');
    end
end

%         for s1 = 1:size(alldeg,1)
%             for s2 = 1:size(alldeg,1)
%                 if s1 < s2
%                     mutinfo(s1,s2,bandidx,t) = corr(squeeze(alldeg(s1,bandidx,t,:)),squeeze(alldeg(s2,bandidx,t,:)));
%                 elseif s1 > s2
%                     mutinfo(s1,s2,bandidx,t) = mutinfo(s2,s1,bandidx,t);
%                 elseif s1 == s2
%                     mutinfo(s1,s2,bandidx,t) = 0;
%                 end
%             end
%         end
%     end
% end

graph{midx,weiorbin} = mutinfo;
fprintf('Appending mutual information to %s/%s/graphdata_%s_%s.mat.\n',filepath,conntype,listname,conntype);
save(sprintf('%s/%s/graphdata_%s_%s.mat',filepath,conntype,listname,conntype), 'graph','-append');

