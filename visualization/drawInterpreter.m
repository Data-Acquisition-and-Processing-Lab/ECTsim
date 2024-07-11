%% drawInterpreter - Interprets parameters selected by the user for drawing functions.
%
% This function interprets parameters selected by the user, which are used by
% drawMap and drawInvpMap functions.
%
% Usage:
%   sets = drawInterpreter(varargin)
%
% Varargin values can be given by user in any order and are interpreted as follows:
%   sets.mode      - 'mm' or 'px'.
%   sets.part      - 'real' or 'imag', applicable to potential, electric field, and sensitivity matrix.
%   sets.electrode - Number of electrode or pair of electrodes.
%   sets.method    - 'mpr', 'surf', or 'slice' (only for 3D).
%   sets.ix        - Indices of mesh elements to present; 0 indicates the whole matrix will be presented.
%
% Outputs:
%   sets - Structure containing interpreted parameter settings.
%
% Example:
%   % Assume varargin contains {'mm', 'real', 1, 'mpr', 0}
%   sets = drawInterpreter('mm', 'real', 1, 'mpr', 0);
%   % This will interpret the parameters and return a structure with the settings.
%
% See also: drawMap, drawInvpMap
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

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