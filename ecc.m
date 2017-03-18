function retlabels = ecc(listname)

loadsubj
subjlist = eval(listname);
crsdiag = cell2mat(subjlist(:,3));

groupvar = crsdiag;
groups = [0 1 2];

selgroupidx = ismember(groupvar,groups);
groupvar = groupvar(selgroupidx);

predlabels = NaN(size(groupvar,1),2);
load('clsyfyr_crsdiag_alphapartcoef.mat');
predlabels(groupvar == 0 | groupvar == 1,1) = clsyfyr.predlabels;
load('clsyfyr_crsdiag_deltapower.mat');
predlabels(groupvar == 1 | groupvar == 2,2) = clsyfyr.predlabels;
predlabels(predlabels == 0) = -1;
predlabels(isnan(predlabels)) = 0;
retlabels = NaN(size(groupvar));
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
     [~,retlabels(g)] = min(runsum);
 end
 
function val = lossfunc(y,s)
val = (1 - sign(y*s))/2;
