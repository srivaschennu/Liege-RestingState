function [clust_job,tasks] = runclassifierjob(listname,runmode,varargin)

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

funclist = {
%     'dataimport' 'subjlist(subjidx,1)'
%     'epochdata' 'subjlist(subjidx,1)'
%     'rejartifacts' '{[subjlist{subjidx,1} ''_epochs''] 1 4 0 [] 2000 500}'
%     'computeic' '{[subjlist{subjidx,1} ''_epochs'']}'
%     'rejectic' '{subjlist{subjidx,1} ''prompt'' ''off''}'
%     'rejartifacts' '{[subjlist{subjidx,1} ''_clean''] 2 4 0 [] 500 250}'
%     'rereference' '{subjlist{subjidx,1} 1 1 ''''}'
%     'checktrials' '{subjlist{subjidx,1} 60 ''_clean''}'
%     'calcftspec' 'subjlist(subjidx,1)'
%     'plotftspec' 'subjlist(subjidx,1)'
%     'ftcoherence' 'subjlist(subjidx,1)'
    'multisvm'
%     'calcwsmi' 'subjlist(subjidx,1)'
    };


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


%% -- INITIALISATION

% -- Add current MATLAB path to worker path
curpath = path;
matlabpath = strrep(curpath,';',''';''');
matlabpath = eval(['{''' matlabpath '''}']);
% matlabpath = matlabpath(~cellfun(@isempty,strfind(matlabpath,'M:\MATLAB\')));
workerpath = cat(1,{pwd},matlabpath);

if exist('rawpath','var')
    workerpath = cat(1,{rawpath},workerpath);
end

if exist('filepath','var')
    workerpath = cat(1,{filepath},workerpath);
end

workerpath = strrep(workerpath,'M:\','\\csresws.kent.ac.uk\exports\home\');
workerpath = strrep(workerpath,'U:\','\\unicorn\');

%% -- MAIN SEQUENCE
% -- Step 1: Create a cluster object
disp('Connecting to Cluster.');

if strcmp(runmode,'local')
    clust = parcluster('local');        % Run this on the local desktop
    hostname = get(clust,'Host');
    disp(['Cluster not selected. Job runs on local desktop: ' hostname]);
    
elseif strcmp(runmode,'phoenix')
    hpc_profile = 'HPCServerProfile1'; % The MATLAB Cluster Profile to use
    clust = parcluster(hpc_profile);    % Run on a HPC Cluster
    hostname = get(clust,'Host');
    disp(['Cluster selected: ' hostname]);
end
disp(['No of Workers: ' num2str(clust.NumWorkers)]);

%-- Step 2: Create job and attach any required files
disp('Creating job, attaching files.');
clust_job = createJob(clust,'AdditionalPaths',workerpath');
clust_job.AutoAttachFiles = false;      % Important, this speeds things up

% -- Step 3: Create the input for the tasks
disp('Creating input for tasks.');

% -- Step 4: Create the tasks and add to the job
disp('Creating tasks, adding to job... ');

taskidx = 1;
for f = 1:size(featlist,1)
    fprintf('Feature set: ');
    disp(featlist(f,:));
    conntype = featlist{f,1};
    measure = featlist{f,2};
    bandidx = featlist{f,3};
    
    features = getfeatures(listname,conntype,measure,bandidx);
    features = features(selgroupidx,:,:);
    
    features = permute(features,[1 3 2]);

    for d = 1:size(features,3)
            for funcidx = 1:size(funclist,1)
                tasks(taskidx) = createTask(clust_job, str2func(funclist{funcidx,1}), 1, ...
                    {features(:,:,d), groupvar},'CaptureDiary',true);
                clsyfyrparam(taskidx,1:3) = featlist(f,1:3);
                clsyfyrparam{taskidx,4} = d;
                clsyfyrparam{taskidx,5} = funclist{funcidx};
                taskidx = taskidx + 1;
            end
    end
    %         fprintf('%s vs %s: AUC = %.2f, p = %.5f, Chi2 = %.2f, Chi2 p = %.4f, accu = %d%%.\n',...
    %             param.groupnames{groups(1)+1},param.groupnames{groups(2)+1},...
    %             clsyfyr(f).auc,clsyfyr(f).pval,clsyfyr(f).chi2,clsyfyr(f).chi2pval,clsyfyr(f).accu);
end

groupnames = param.groupnames;

fprintf('created %d tasks.\n',length(tasks(:)));

% -- Step 5: Submit the job to the cluster queue
disp('Submitting job to cluster queue.');
submit(clust_job);

disp('Waiting for tasks to finish.');
wait(clust_job);

disp('Fetching and saving task outputs.');
clsyfyr = fetchOutputs(clust_job);
clsyfyr = cell2mat(clsyfyr);

save(sprintf('clsyfyr_%s.mat',param.group),'clsyfyr','groups','groupnames','clsyfyrparam');
disp('Done.');
