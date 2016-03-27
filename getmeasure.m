function testdata = getmeasure(listname,conntype,measure,bandidx,sortedlocs,param)

loadpaths
changroups

weiorbin = 3;

if strcmpi(measure,'power')
    %     load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype));
    load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype),'bandpower');
    testdata = mean(bandpower(:,bandidx,ismember({sortedlocs.labels},eval(param.changroup))),3) * 100;
elseif strcmpi(measure,'specent')
    %     load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype));
    load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype),'specent');
    testdata = mean(specent(:,ismember({sortedlocs.labels},eval(param.changroup))),2);
elseif strcmpi(measure,'median')
    load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype),'allcoh');
    testdata = median(median(allcoh(:,bandidx,ismember({sortedlocs.labels},eval(param.changroup)),ismember({sortedlocs.labels},eval(param.changroup2))),4),3);
elseif strcmpi(measure,'mean')
    load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype),'allcoh');
    testdata = mean(mean(allcoh(:,bandidx,ismember({sortedlocs.labels},eval(param.changroup)),ismember({sortedlocs.labels},eval(param.changroup2))),4),3);
elseif strcmpi(measure,'refdiag')
    testdata = refdiag;
else
    trange = [0.8 0.1];
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
    if strcmpi(measure,'modules')
        testdata = squeeze(max(graph{m,weiorbin}(:,bandidx,trange,:),[],4));
    elseif strcmpi(measure,'centrality')
        testdata = squeeze(max(graph{m,weiorbin}(:,bandidx,trange,:),[],4));
    elseif strcmpi(measure,'mutual information')
        testdata = squeeze(mean(graph{m,weiorbin}(:,:,bandidx,trange),4));
    elseif strcmpi(measure,'participation coefficient')
        testdata = squeeze(std(graph{m,weiorbin}(:,bandidx,trange,:),[],4));
        %         testdata = squeeze(graph{m,weiorbin}(:,bandidx,trange,:));
        %         testdata = testdata - repmat(quantile(testdata,0.75,3),1,1,size(testdata,3));
        %         testdata(testdata < 0) = NaN;
        %         testdata = nanmean(testdata,3);
    else
        testdata = squeeze(mean(graph{m,weiorbin}(:,bandidx,trange,:),4));
    end
end
end
