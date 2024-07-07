%% newComplexElement 
% Creates a new complex element by combining 
% already existing elements. The element is added to the 'Elements' 
% cell array in the Numerical model.
%
% *usage:* |[model] = newComplexElement(model,'elname','algebraic expression',varargin)|
% 
% * _model_     - structure with model description
% * _elname_    - a name of an element to be created
% * _algebraic expression_ - sum, difference or product of two regions
% * _varargin_:
% * _display_   - 'silent' or 'verbose'
%
% footer$$
function model=newComplexElement(model, name, formula, varargin)

dspmode = 'verbose';
if ~isempty(varargin)
    dsp = varargin{length(varargin)};
    if isa(dsp,'char')
        if strcmp(dsp,'silent') || strcmp(dsp,'verbose')
            dspmode = dsp;
        else
            error('Wrong arguments. Display can be "silent" or "verbose" only!\n');
        end
    else
        error('Wrong arguments. Display can be "silent" or "verbose" only!\n');
    end
end

[n]=findElement(name,model.Elements);
if n>0
    error('Element %s already exists!', model.Elements{n}.name);
end

[components,operations]=readFormula(formula);
nn=zeros(1,length(components));
for i=1:length(components)
    nn(i)=findElement(components(i),model.Elements);
end

if ~isempty(find(nn==0,1))
    error('At least one of the elements in the formula does not exist!');
end

if strcmp(dspmode,'verbose')
    fprintf(1,'Declaration of a complex element. ');
end

Index=model.Elements{nn(1)}.location_index;

for i=1:length(components)-1
    index2=model.Elements{nn(i+1)}.location_index;
    [Index]=combineElements( Index, index2,operations(i));
end

%formula
string= formula(~isspace(formula));
string = insertBefore(string,'+',' ');
string = insertAfter(string,'+',' ');
string = insertBefore(string,'-',' ');
string = insertAfter(string,'-',' ');
string = insertBefore(string,'&',' ');
string = insertAfter(string,'&',' ');


%declaration of the structure
struct.name = name;
struct.type = 'complex element';
struct.formula = string;
struct.location_index = Index;

model.Elements{length(model.Elements)+1}=struct;

if strcmp(dspmode,'verbose')
    fprintf(1,'New element %s created. %s = %s\n', name, name, string);
end
