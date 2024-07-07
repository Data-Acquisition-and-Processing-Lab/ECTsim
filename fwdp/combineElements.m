%% combineElements
% Function performs an operation (addition, or, substraction ) of two
% region
%
% *usage:*     |[Index]=combineElements(Index, Index2, operations)|
%
% * _Index_        -  first region indices
% * _index2_       -  second region indices
% * _operations_   - define as sum, difference or product of two regions
%
% *returns:*   vector of indices operation on 2 region
%
% footer$$

function [ Index ] = combineElements( index1, index2, operator )

[~,i1,~]=intersect(index1,index2);

switch (operator)
    case '+'
        index1(i1)=[];
        Index=[index1;index2];        
    case '-'
        index1(i1)=[];
        Index=index1;
    case '&'
        Index=index1(i1);
end
end
