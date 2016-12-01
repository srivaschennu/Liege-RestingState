function runclassifier(listname,varargin)

param = finputcheck(varargin, {
    'changroup', 'string', [], 'all'; ...
    'changroup2', 'string', [], 'all'; ...
    'group', 'string', [], 'crsdiag'; ...
    'groups', 'real', [], []; ...
    'groupnames', 'cell', {}, {'UWS','MCS'}; ...
    'runpca', 'string', {'true','false'}, 'false'; ...
    });

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
    %     'ftdwpli','power',1
    %     'ftdwpli','power',2
    %     'ftdwpli','power',3
    %     'ftdwpli','median',1
    %     'ftdwpli','median',2
    %     'ftdwpli','median',3
    %     'ftdwpli','clustering',1
    %     'ftdwpli','clustering',2
    %     'ftdwpli','clustering',3
    %     'ftdwpli','characteristic path length',1
    %     'ftdwpli','characteristic path length',2
    %     'ftdwpli','characteristic path length',3
    %     'ftdwpli','modularity',1
    %     'ftdwpli','modularity',2
    %     'ftdwpli','modularity',3
    %     'ftdwpli','participation coefficient',1
    %     'ftdwpli','participation coefficient',2
    'ftdwpli','participation coefficient',3
    %     'ftdwpli','modular span',1
    %     'ftdwpli','modular span',2
    %     'ftdwpli','modular span',3
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

for f = 1:size(featlist,1)
    fprintf('Feature set: ');
    disp(featlist(f,:));
    conntype = featlist{f,1};
    measure = featlist{f,2};
    bandidx = featlist{f,3};
    
    features = getfeatures(listname,conntype,measure,bandidx);
    features = features(selgroupidx,:,:);
    
    clsyfyr(f) = buildmultisvm(features,groupvar,'runpca','false');
    
    %         fprintf('%s vs %s: AUC = %.2f, p = %.5f, Chi2 = %.2f, Chi2 p = %.4f, accu = %d%%.\n',...
    %             param.groupnames{groups(1)+1},param.groupnames{groups(2)+1},...
    %             clsyfyr(f).auc,clsyfyr(f).pval,clsyfyr(f).chi2,clsyfyr(f).chi2pval,clsyfyr(f).accu);
end

groupnames = param.groupnames;
save(sprintf('clsyfyr_%s.mat',param.group),'clsyfyr','groups','groupnames','featlist');
end

