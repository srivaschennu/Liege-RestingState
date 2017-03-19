function ecclabels = testeccsvm(listname,varargin)

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

load('clsyfyr_crsdiag_alphapartcoef.mat');
for f = 1:size(featlist,1)
    disp(featlist(f,:));
    features = getfeatures(listname,featlist{f,1:3});
    [~,postProb] = predict(fitSVMPosterior(clsyfyr.model),squeeze(features(:,clsyfyr.D,:)));
    predlabels(:,1) = double(postProb(:,2) >= clsyfyr.bestthresh);
end

load('clsyfyr_crsdiag_deltapower.mat');
for f = 1:size(featlist,1)
    disp(featlist(f,:));
    features = getfeatures(listname,featlist{f,1:3});
    [~,postProb] = predict(fitSVMPosterior(clsyfyr.model),squeeze(features(:,clsyfyr.D,:)));
    predlabels(:,2) = double(postProb(:,2) >= clsyfyr.bestthresh);
end
predlabels(predlabels == 0) = -1;

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

function val = lossfunc(y,s)
val = (1 - sign(y*s))/2;