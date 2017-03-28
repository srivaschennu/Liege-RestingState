function writetable(listname)

loadsubj
subjlist = eval(listname);

fieldnames = {
    'Patient'                   1   @patient
    'Referral diagnosis'        2   @refdiag
    'CRS-R diagnosis'           3   @crsdiag
    'CRS-R score'               11   @nothing
    'PET diagnosis'             4   @petdiag
    'GOS-E score'               10  @nothing
    'GOS-E outcome'             10  @outcome
    'Etiology'                  6   @etiology
    'Age (years)'               7   @nothing
    'Time since injury (days)'  9   @nothing
    };

delim = ',';

fid = fopen('writetable.csv','w');

for f = 1:size(fieldnames,1)
    fprintf(fid,'%s',fieldnames{f,1});
    if f < size(fieldnames,1)
        fprintf(fid,delim);
    end
end
fprintf(fid,'\n');

for s = 1:size(subjlist,1)
    for f = 1:size(fieldnames,1)
        fprintf(fid,'%s',fieldnames{f,3}(subjlist{s,fieldnames{f,2}}));
        if f < size(fieldnames,1)
            fprintf(fid,delim);
        end
    end
    fprintf(fid,'\n');
end
fclose(fid);

function y = patient(x)
y = sprintf('P%s',x);

function y = nothing(x)
if isnan(x)
    y = '-';
else
    y = num2str(x);
end

function y = refdiag(x)
diaglist = {'UWS','MCS','MCS','EMCS','LIS','CTRL'};
if isnan(x)
    y = '-';
else
    y = diaglist{x+1};
end

function y = crsdiag(x)
diaglist = {'UWS','MCS-','MCS+','EMCS','LIS','CTRL'};
y = diaglist{x+1};

function y = petdiag(x)
diaglist = {'Negative','Positive'};
if isnan(x)
    y = '-';
else
    y = diaglist{x+1};
end

function y = etiology(x)
etiolist = {'Non-traumatic','Traumatic'};
if isnan(x)
    y = '-';
else
    y = etiolist{x+1};
end

function y = outcome(x)
outcomelist = {'Negative','Positive'};
if isnan(x)
    y = '-';
else
    y = outcomelist{(x > 2) + 1};
end