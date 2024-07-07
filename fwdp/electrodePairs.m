%% electrodePairs 
% calculates two indices of electrode numbers for electrode pairs;
% (application electrode, sensing electrode)
% position in the vectors coresponds to the order of measurement
% of mutual capacitance of electrodes
%
% *usage:* |[application, receiving] = electrodePairs(elecNum, all)|
%
% _elecNum_     - number of electrodes in the sensor
% _all_         - 0 - without, 1 with repeting measurements (1-2 and 2-1)
% 
% _application_    - vector with application electrode numbers
% _receiving_      - vector with sensing electrode numbers
%
% footer$$

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
