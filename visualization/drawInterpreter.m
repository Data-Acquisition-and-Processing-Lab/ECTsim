%% drawInterpreter
% Draws maps od selected parameter for all excitations;
%
% *usage:* |drawMap(model,parameter,mode,part,electrode)|
%
% * _model_   - structure with a numerical model description
% * _mode_  - mm, px
% * _part_  - real, imag
% * _electrode_    
%
% footer$

function sets = drawInterpreter(varargin)
sets.mode = 'px';
sets.part = 'real';
sets.electrode = 1;
sets.method = 'mpr';
sets.ix = 0;

vec = varargin{1};
for i=1:numel(vec)
    if (strcmp(vec{i},'px') || strcmp(vec{i},'mm'))
        sets.mode = vec{i};
    elseif (strcmp(vec{i},'real') || strcmp(vec{i},'imag'))
        sets.part = vec{i};
    elseif (strcmp(vec{i},'mpr') || strcmp(vec{i},'slice') || strcmp(vec{i},'surf'))
        sets.method = vec{i};
    elseif isnumeric(vec{i})
        if isscalar(vec{i})
            sets.electrode = vec{i};
        elseif isvector(vec{i})
            if numel(vec{i}) == 2
                sets.electrode = vec{i};
            else
                sets.ix = vec{i};
            end
        end
    else
        disp(['Unknown option: ', vec{i}, ' for draw map']);
    end
end

end