function convert2mohawk(listname,conntype)

loadsubj
loadpaths

load sortedlocs.mat

outpath = '/Users/chennu/Data/MOHAWK/';

subjlist = eval(listname);

for s = 1:size(subjlist,1)
    basename = subjlist{s,1};
    specinfo = load(sprintf('%s%sspectra.mat',filepath,basename));
    [sortedchan,sortidx] = sort({specinfo.chanlocs.labels});
    if ~strcmp(chanlist,cell2mat(sortedchan))
        error('Channel names do not match!');
    end
    specinfo.spectra = specinfo.spectra(sortidx,:);
    specinfo.chanlocs = specinfo.chanlocs(sortidx);
    
    conn = load(sprintf('%s%s/%s%s.mat',filepath,conntype,basename,conntype));
    [sortedchan,sortidx] = sort({conn.chanlocs.labels});
    if ~strcmp(chanlist,cell2mat(sortedchan))
        error('Channel names do not match!');
    end
    conn.bootmat = [];
    conn.matrix = conn.matrix(:,sortidx,sortidx);
    conn.chanlocs = conn.chanlocs(sortidx);
    
    graph = load(sprintf('%s%s/%s%sgraph.mat',filepath,conntype,basename,conntype));
    graph.graphdata = graph.graphdata(:,[1 3]);
    
    save(sprintf('%s%s_mohawk.mat',outpath,basename),'-struct','specinfo');
    save(sprintf('%s%s_mohawk.mat',outpath,basename),'-struct','conn','-append');
    save(sprintf('%s%s_mohawk.mat',outpath,basename),'-struct','graph','-append');
end