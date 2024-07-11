%% newComplexElement - Creates a new complex element by combining existing elements.
%
% This function creates a new complex element by combining existing elements
% according to a specified formula. The new element is then added to the 'Elements'
% cell array in the numerical model.
%
% Usage:
%   model = newComplexElement(model, name, formula)
%
% Inputs:
%   model   - Structure with model description.
%   name    - Name of the element to be created.
%   formula - Operation on elements represented as 'el1+el2', 'el1-el2', or 'el1&el2'.
%
% Outputs:
%   model - Updated model structure with the new complex element added.
%
% Example:
%   % Assume model is already initialized and elements 'el1' and 'el2' exist
%   model = newComplexElement(model, 'newElement', 'el1+el2');
%   % This will create a new element named 'newElement' by combining 'el1' and 'el2'.
%
% See also: newSimpleElement
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function model=newComplexElement(model, name, formula)

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
