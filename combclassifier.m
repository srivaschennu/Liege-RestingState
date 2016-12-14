function combclassifier(listname,varargin)

param = finputcheck(varargin, {
    'changroup', 'string', [], 'all'; ...
    'changroup2', 'string', [], 'all'; ...
    'group', 'string', [], 'crsdiag'; ...
    'groups', 'real', [], []; ...
    'groupnames', 'cell', {}, {'UWS','MCS'}; ...
    'runpca', 'string', {'true','false'}, 'false'; ...
    });

% runmode = serial, local or phoenix
loadpaths
loadsubj

subjlist = eval(listname);

refdiag = cell2mat(subjlist(:,2));
refaware = double(cell2mat(subjlist(:,2)) > 0);
refaware(isnan(refdiag)) = NaN;
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

admvscrs = NaN(size(refdiag));
admvscrs(refaware == 0) = 0;
admvscrs(refaware == 0 & crsaware == 0) = 0;
admvscrs(refaware > 0 & crsaware > 0) = 1;
admvscrs(refaware == 0 & crsaware > 0) = 2;

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

if isempty(param.groups)
    groups = [0 1];
else
    groups = param.groups;
end

selgroupidx = ismember(groupvar,groups);
groupvar = groupvar(selgroupidx);
[~,~,groupvar] = unique(groupvar);
groupvar = groupvar-1;


load(sprintf('clsyfyr_%s.mat',param.group));

for c = 1:length(clsyfyr)
    clsyfyr(c).cm = confusionmat(groupvar,clsyfyr(c).predlabels) + 0.5;
    clsyfyr(c).cm = clsyfyr(c).cm ./ repmat(sum(clsyfyr(c).cm,1),size(clsyfyr(c).cm,1),1);
    clsyfyr(c).predlabels = clsyfyr(c).predlabels+1;
end

bel = zeros(length(clsyfyr(1).predlabels),length(groups));
for x = 1:length(clsyfyr(1).predlabels)
    for g = 1:length(groups)
        bel(x,g) = clsyfyr(1).cm(g,clsyfyr(1).predlabels(x));
        for k = 2:length(clsyfyr)
            bel(x,g) = bel(x,g) * clsyfyr(k).cm(g,clsyfyr(k).predlabels(x));
        end
    end
end

bel = bel ./ repmat(sum(bel,2),1,size(bel,2));
