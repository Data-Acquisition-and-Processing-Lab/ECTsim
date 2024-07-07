%% withoutRepetition 
% function converts sensitivity matrices for the minimum, maximum and object
% from 'all measurements' to 'without repetitions';
% number of rows is reduced by half in the sensitivity matrix;
% 
%
% *usage:* |[model] = WithoutRepetition(model, src_app_el, src_rec_el, varargin)|
%
% _model_      
% _varargin_  - matrices to convert; all matrices (min, max, pha) if empty 
%               model.post.S matrix will be reduced if 'post' field is present
%    
% _model_ - vector with application electrode numbers
%
% footer$$
function  model = withoutRepetition(model, modelList)
    % model.measurement_count=model.measurement_count/2;  % all measurements
    
    src_app_el = model.Electrodes.app_el;
    src_rec_el = model.Electrodes.rec_el;
    
    model.measurements_all=0;
    [model.Electrodes.app_el, model.Electrodes.rec_el] = electrodePairs(model.Electrodes.num,model.measurements_all);
    
    M = numel(model.Electrodes.app_el);
    indx = zeros(M,1);
    C = zeros(M,1);
    K = zeros(M,1);
    G = zeros(M,1);
    Y = zeros(M,1);

    for i=1:M
        a = model.Electrodes.app_el(i);
        r = model.Electrodes.rec_el(i);
        [p, ~] = intersect(find(src_app_el==a), find( src_rec_el()==r));
        indx(i) = p(1); 
    end
    
    if ~isempty(modelList)
        for cnt=1:length(modelList)
            if isfield(model, modelList{cnt})
                modelTemp = model.(modelList{cnt});
                [~, N]=size(modelTemp.S);
                S = zeros(M,N);
                Sn = zeros(M,N);
                for i=1:M
                    S(i,:) = modelTemp.S(indx(i),:);
                    Sn(i,:) = modelTemp.Sn(indx(i),:);
                    C(i) = modelTemp.C(indx(i));
                    K(i) = modelTemp.K(indx(i));
                    G(i) = modelTemp.G(indx(i));
                    Y(i) = modelTemp.Y(indx(i));
                end
                modelTemp.C = C;
                modelTemp.K = K;
                modelTemp.G = G;
                modelTemp.Y = Y;
                modelTemp.S = S;
                modelTemp.Sn = Sn;
                model.(modelList{cnt}) = modelTemp;
            else
                warning('The field: %s does not exist in the structure!', modelList{cnt});
            end
        end
    else
        warning('You must provide at least one structure to modify, e.g. min ');
    end