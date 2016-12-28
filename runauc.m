function runauc(varargin)

listname = 'allsubj';

param = finputcheck(varargin, {
    'group', 'string', [], 'crsdiag'; ...
    'groupnames', 'cell', {}, {'UWS','MCS-','MCS+','EMCS','LIS','CTRL'}; ...
    });

featlist = {
    'ftdwpli'    'power'                  [1]    '\delta'
    'ftdwpli'    'power'                  [2]    'Relative power \theta'
    'ftdwpli'    'power'                  [3]    '\alpha'
    'ftdwpli'    'median'                 [1]    '\delta'
    'ftdwpli'    'median'                 [2]    'Median dwPLI \theta'
    'ftdwpli'    'median'                 [3]    '\alpha'
    'ftdwpli'    'clustering'             [1]    '\delta'
    'ftdwpli'    'clustering'             [2]    'Clustering coeff. \theta'
    'ftdwpli'    'clustering'             [3]    '\alpha'
    'ftdwpli'    'characteristic path length'     [1]    '\delta'
    'ftdwpli'    'characteristic path length'     [2]    'Path length \theta'
    'ftdwpli'    'characteristic path length'     [3]    '\alpha'
    'ftdwpli'    'modularity'             [1]    '\delta'
    'ftdwpli'    'modularity'             [2]    'Modularity \theta'
    'ftdwpli'    'modularity'             [3]    '\alpha'
    'ftdwpli'    'participation coefficient'     [1]    '\delta'
    'ftdwpli'    'participation coefficient'     [2]    '\sigma(Participation coeff.) \theta'
    'ftdwpli'    'participation coefficient'     [3]    '\alpha'
    'ftdwpli'    'modular span'           [1]    '\delta'
    'ftdwpli'    'modular span'           [2]    'Modular span \theta'
    'ftdwpli'    'modular span'           [3]    '\alpha'
    };

for f = 1:size(featlist,1)
    %     load(sprintf('clsyfyr/clsyfyr_%s_%s_%s_%s.mat',featlist{f,1},featlist{f,2},bands{featlist{f,3}},param.group));
    %     if exist('clsyfyr','var')
    %         fnlist = fieldnames(clsyfyr);
    %         for fn = 1:length(fnlist)
    %             if ~isfield(clsyfyr,fnlist{fn})
    %                 clsyfyr = rmfield(clsyfyr,fnlist{fn});
    %             end
    %         end
    %     end
    %     clsyfyr(f,:) = clsyfyr;
    [~,~,statdata] = plotmeasure(listname,featlist{f,1},featlist{f,2},featlist{f,3},'noplot','on','group',param.group,'groupnames',param.groupnames);
    stats(f,:) = statdata;
end

save(sprintf('stats_%s.mat',param.group),'stats','featlist');