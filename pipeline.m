function pipeline(basename)

% dataimport(basename);
% epochdata(basename);
% rejartifacts([basename '_epochs'],1,4);
% computeic([basename '_epochs']);
% rejectic(basename,'prompt','off');
% rejartifacts([basename '_clean'],2,4,0);
% rereference(basename);
checktrials(basename,60,'');
calcftspec(basename);
ftcoherence(basename);
% plothead(basename,3);
% plotmetric(basename,'median',3);