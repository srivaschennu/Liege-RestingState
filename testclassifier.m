function testclassifier(listname,varargin)

param = finputcheck(varargin, {
    'group', 'string', [], 'crsdiag'; ...
    'groups', 'real', [], []; ...
    'groupnames', 'cell', {}, {'UWS','MCS'}; ...
    });

loadsubj
changroups

bands = {
    'delta'
    'theta'
    'alpha'
    };

fontname = 'Helvetica';
fontsize = 22;

load sortedlocs.mat
load(sprintf('clsyfyr_%s.mat',param.group),'clsyfyr','featlist');

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

fprintf('Feature set: ');
features = [];
for f = 1:size(featlist,1)
    disp(featlist(f,:));
    features = getfeatures(listname,featlist{f,1:3});
    results(f) = testmultisvm(clsyfyr(f),features,groupvar,'runpca','false');
end

save(sprintf('testres_%s.mat',param.group),'results','clsyfyr','featlist');

end
