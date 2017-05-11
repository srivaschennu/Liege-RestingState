function clsyfyr = ecc(listname)

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

groupvar = crsdiag;
groups = [0 1 2];

selgroupidx = ismember(groupvar,groups);
groupvar = groupvar(selgroupidx);

predlabels = NaN(size(groupvar,1),2);
load('clsyfyr_crsdiag_alphapartcoef.mat','clsyfyr');
predlabels(groupvar == 0 | groupvar == 1,1) = clsyfyr.predlabels;
load('clsyfyr_crsdiag_deltapower.mat','clsyfyr');
predlabels(groupvar == 1 | groupvar == 2,2) = clsyfyr.predlabels;
% load('clsyfyr_crsdiag_alphapartcoef2.mat');
% predlabels(groupvar == 0 | groupvar == 2,3) = clsyfyr.predlabels;

predlabels(predlabels == 0) = -1;
predlabels(isnan(predlabels)) = 0;
ecclabels = NaN(size(groupvar));

% code = [
%     1   0   1
%    -1   1   0
%     0  -1  -1
%     ];


code = [
    1   0
   -1   1
    0  -1
    ];
for g = 1:size(groupvar,1)
    for k = 1:size(code,1)
        runsum(k) = 0;
        for j = 1:size(code,2)
            if code(k,j) ~= 0
                runsum(k) = runsum(k) + lossfunc(code(k,j),predlabels(g,j));
            end
        end
    end
    [~,ecclabels(g)] = min(runsum/sum(code(k,:)));
end

ecclabels = ecclabels - 1;

clear clsyfyr
clsyfyr.predlabels = ecclabels;
[clsyfyr.confmat,clsyfyr.chi2,clsyfyr.chi2pval] = crosstab(groupvar,ecclabels);
save('clsyfyr_ecc.mat','clsyfyr', 'groups');

function val = lossfunc(y,s)
val = (1 - sign(y*s))/2;