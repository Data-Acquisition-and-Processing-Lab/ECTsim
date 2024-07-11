%% combineElements - Performs an operation (addition, subtraction, or multiplication) on two regions.
%
% This function performs a specified operation (addition, subtraction, or multiplication) on
% two regions defined by their indices. The resulting indices from the operation are returned.
%
% Usage:
%   Index = combineElements(Index, Index2, operations)
%
% Inputs:
%   Index      - First region indices.
%   Index2     - Second region indices.
%   operations - Operation to be performed, defined as '+', '-', or '&'.
%
% Outputs:
%   Index - Vector of indices resulting from the operation on the two regions.
%
% Example:
%   % Assume Index and Index2 are already defined
%   resultIndex = combineElements(Index, Index2, '+');
%   % This will return the indices resulting from the addition of the two regions.
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

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
