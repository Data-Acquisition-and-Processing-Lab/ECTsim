%% electrodePairs - Calculates indices of electrode numbers for electrode pairs.
%
% This function calculates two indices of electrode numbers for electrode pairs
% (application electrode, sensing electrode). The position in the vectors corresponds
% to the order of measurement of mutual capacitance of electrodes.
%
% Usage:
%   [app_el, rec_el] = electrodePairs(elecNum, all)
%
% Inputs:
%   elecNum    - Number of electrodes in the sensor.
%   all        - 0 for without, 1 with repeating measurements (1-2 and 2-1).
%
% Outputs:
%   app_el - Vector with application electrode numbers.
%   rec_el   - Vector with sensing electrode numbers.
%
% Example:
%   % Calculate electrode pairs for a sensor with 16 electrodes without repeating measurements
%   [app_el, rec_el] = electrodePairs(16, 0);
%   % This will return the application and sensing electrode pairs for the specified sensor.
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function [app_el, rec_el] = electrodePairs(elecNum, all)

index = 1;
for a=1:elecNum
    if all==0
        num = elecNum;
    else
        num = a+elecNum-1;
    end
    
    for r=a+1:num
        if r > elecNum
            r = mod(r,elecNum);
        end
        
        app_el(index)=a;  % electrode numbers in the pair
        rec_el(index)=r;
        
        index = index + 1;
    end
end
