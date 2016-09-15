function minfo = plotgraph3d(matrix,chanlocs,splinefile,varargin)

% matrix - NxN symmetric connectivity matrix, where N is the number of channels
% chanlocs - 1xN EEGLAB chanlocs structure specifying channel locations

% OPTIONAL ARGUMENTS
% plotqt - proportion of strongest edges to plot
% minfo - 1xN module affiliation vector. Will be calculated if unspecified
% legend - whether or not to plot legend with max and min edge weights
% plotinter - whether or not to plot inter-modular edges

param = finputcheck(varargin, {
    'plotqt', 'real', [], 0.7; ...
    'minfo', 'integer', [], []; ...
    'plotinter', 'string', {'on','off'}, 'off'; ...
    'escale', 'real', [], []; ...
    'vscale', 'real', [], []; ...
    'view', 'real', [], []; ...
    'cshift', 'real', [], 0; ...
    'numcolors', 'real', [], 5; ...
    });

%%%%% VISUAL FEATURES

% range of line heights
lhfactor = 1;


%%%%%%

matrix(isnan(matrix)) = 0;

load sortedlocs
[sortedchan,sortidx] = sort({chanlocs.labels});
if ~strcmp(chanlist,cell2mat(sortedchan))
    error('Channel names do not match!');
end
matrix = matrix(sortidx,sortidx);

%keep only top <plotqt>% of weights
matrix = threshold_proportional(matrix,1-param.plotqt);

for c = 1:size(matrix,1)
    vsize(c) = sum(matrix(c,:))/(size(matrix,2)-1);
end

% calculate modules after thresholding edges
if isempty(param.minfo)
    minfo = community_louvain(matrix);
else
    minfo = param.minfo;
end

% rescale weights
if isempty(param.escale)
    param.escale(1) = min(matrix(logical(triu(matrix,1))));
    param.escale(2) = max(matrix(logical(triu(matrix,1))));
end
matrix = (matrix - param.escale(1))/(param.escale(2) - param.escale(1));
matrix(matrix < 0) = 0;

% rescale degrees
if isempty(param.vscale)
    param.vscale(1) = min(vsize);
    param.vscale(2) = max(vsize);
end
vsize = (vsize - param.vscale(1))/(param.vscale(2) - param.vscale(1));
vsize(vsize < 0) = 0;

% assign all modules with only one vertex the same colour
modsize = hist(minfo,unique(minfo));
num_mod = sum(modsize > 1);
modidx = 1;
newminfo = zeros(size(minfo));
for i = 1:length(newminfo)
    if newminfo(i) == 0
        if modsize(minfo(i)) == 1
            newminfo(i) = num_mod + 1;
        else
            newminfo(minfo == minfo(i)) = modidx;
            modidx = modidx + 1;
        end
    end
end
minfo = newminfo;
num_mod = length(unique(minfo));

figure('Color','black','Name',mfilename);
figpos = get(gcf,'Position');
set(gcf,'Position',[figpos(1) figpos(2) figpos(3)*1.5 figpos(4)*2],'Color','black');
cmap = jet;
colorlist = cmap(round(linspace(1,size(cmap,1),param.numcolors)),:);
colorlist = circshift(colorlist,4,1);

hold all

if isempty(param.view)
    param.view = 'frontleft';
end
[~,chanlocs3d] = headplot(vsize,splinefile,'electrodes','off','maplimits',[0 1]-param.cshift,'view',param.view);

xlim('auto'); ylim('auto'); zlim('auto');

for r = 1:size(matrix,1)
    for c = 1:size(matrix,2)
        if r < c && matrix(r,c) > 0
            eheight = (matrix(r,c)*lhfactor)+1;
            if minfo(r) == minfo(c)
                ecol = colorlist(minfo(r),:);
                hLine = plotarc3d(chanlocs3d([r,c],:),eheight,ecol,0.5);
                %                 set(hLine,'Color',ecol,'LineWidth',0.1);
            elseif strcmp(param.plotinter,'on')
                hLine = plotarc3d(chanlocs3d([r,c],:),eheight);
                ecol = [0 0 0];
                set(hLine,'Color',ecol,'LineWidth',0.1);
            end
        end
    end
end