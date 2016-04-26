function batchjob(listname)

loadsubj
loadpaths

subjlist = eval(listname);

curpath = path;
matlabpath = strrep(curpath,':',''';''');
matlabpath = eval(['{''' matlabpath '''}']);
workerpath = cat(1,{pwd},matlabpath(1:end-1));
jobspath = [filepath 'Jobs/'];

if exist(jobspath,'dir')
    fprintf('Deleting existing Jobs directory.\n');
    rmdir(jobspath,'s');
end

jobqueue = 'compute';
numworkers = size(subjlist,1);
memory = 32;
walltime = 3600*4;

tasklist = {
%     'dataimport' 'subjlist(subjidx,1)'
%     'epochdata' 'subjlist(subjidx,1)'
%     'rejartifacts' '{[subjlist{subjidx,1} ''_epochs''] 1 4 0 [] 2000 500}'
%     'computeic' '{[subjlist{subjidx,1} ''_epochs'']}'
    'rejectic' '{subjlist{subjidx,1} ''prompt'' ''off''}'
%     'rejartifacts' '{[subjlist{subjidx,1} ''_clean''] 2 4 0 [] 200 100}'
%     'rereference' '{subjlist{subjidx,1} 5 1}'
%     'checktrials' '{subjlist{subjidx,1} 60 ''_epochs''}'
%     'calcftspec' 'subjlist(subjidx,1)'
%     'plotftspec' 'subjlist(subjidx,1)'
%     'ftcoherence' 'subjlist(subjidx,1)'
%     'calcgraph' '{subjlist{subjidx,1} ''ftdwpli''}'
%     'calcwsmi' 'subjlist(subjidx,1)'
    };

j = 1;
for subjidx = 1:size(subjlist,1)
    for t = 1:size(tasklist,1)
        jobs(j).task = str2func(tasklist{t,1});
        jobs(j).input_args = eval(tasklist{t,2});
        jobs(j).n_return_values = 0;
        jobs(j).depends_on = 0;
        j = j+1;
    end
end

% %% run in serial order
for j = 1:length(jobs)
    disp(jobs(j));
    jobs(j).task(jobs(j).input_args{:});
end

% %% CBU parallel pool
% P=cbupool(24);
% P.ResourceTemplate='-l nodes=^N^,mem=12GB,walltime=4:00:00';
% matlabpool(P);

% %% local parallel pool
% if isempty(gcp('nocreate'))
%     parpool('local');
% end
% parfor j = 1:length(jobs)
%     jobs(j).task(jobs(j).input_args{:});
% end

% %% CBU distributed computing
% scheduler = cbu_scheduler('custom',{jobqueue,numworkers,memory,walltime,jobspath});
% cbu_qsub(jobs,scheduler,workerpath);