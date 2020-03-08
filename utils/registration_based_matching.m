%%%%% function to compare annotation accuracy of registration vs CRF method
%%%%% for alternate strains.
%%%%% registration here is 3D done with 3D atlas
%%%%% Methods used for registration
%%%%% 1. CPD
%%%%% 2. GLMD (Global and Local Mixture Distance based (GLMD) Non-rigid
%%%%%    Point Set Matching)
%%%%% 3. TPS-RPM


addpath(genpath('C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Joint_tracking\TPS-RPM'))
addpath(genpath('C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GLMD_Demo'))
addpath(genpath('C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\CPD2'))

data = {'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_1r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_3r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_4r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_5r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_6r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_7r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_8r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_9r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_10r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_11r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_14r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_19r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_20r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_22r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_23r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_24r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_28r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_29r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_33r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_34r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_36r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_37r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_38r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_39r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_50r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_52r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_54r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_55r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_57r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_58r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_59r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_60r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_62r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_65r.mat\',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\data_20190809_67r.mat\'};

%%%%%%%%%%%% creat annotated neurons list
all_marker_names = {};
for i = 1:size(data,2)
    load(data{1,i})
    all_marker_names = cat(1,all_marker_names,marker_name);
end
landmark_list = unique(all_marker_names);
ind_RIGL = find(strcmp('RIGL',landmark_list));
ind_RIGR = find(strcmp('RIGR',landmark_list));
ind_AVG = find(strcmp('AVG',landmark_list));
landmark_list([ind_RIGL;ind_RIGR;ind_AVG],:) = [];

% load('C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\data_neuron_relationship_2D_3D.mat')
load('C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\data_neuron_relationship.mat')
source = [X_rot,Y_rot,Z_rot];

%%%%%%%%%%%%%%%%%% define GLTP_EM parameters %%%%%%%%%%%%%%%%%%%%%%%%%%
param.omega = 0.1; param.K = 5; param.alpha = 3; param.beta = 2; param.lambda = 3; param.all_feat = 1; param.plot_iter = 1; param.norm = 1; param.denorm = 0;

%%%%%%%%%%%%%%%%%%%%%%% define CPD parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opt.method='nonrigid'; % use nonrigid registration
opt.beta=1;            % the width of Gaussian kernel (smoothness)
opt.lambda=3;          % regularization weight

opt.viz=0;              % DON't show every iteration
opt.outliers=0.3;       % Noise weight
opt.fgt=0;              % do not use FGT (default)
opt.normalize=1;        % normalize to unit variance and zero mean before registering (default)
opt.corresp=1;          % compute correspondence vector at the end of registration (not being estimated by default)

opt.max_it=100;         % max number of iterations
opt.tol=1e-10;          % tolerance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

match_top_matrix = NaN(size(data,2),size(landmark_list,1));
match_top_3_matrix = NaN(size(data,2),size(landmark_list,1));
match_top_5_matrix = NaN(size(data,2),size(landmark_list,1));
for i = 1:size(data,2)
    load(data{1,i})
    
    % generate axis
    mu_r_centered = mu_r - repmat(mean(mu_r),size(mu_r,1),1);
    [coeff,score,latent] = pca(mu_r_centered);
    PA = coeff(:,axes_param(1,1))';
    PA = PA/norm(PA);
    LR = coeff(:,axes_param(1,2))';
    LR = LR/norm(LR);
    DV = coeff(:,axes_param(1,3))';
    DV = DV/norm(DV);
    
    A_neuron = axes_neurons_to_neuron_map(1,1);P_neuron = axes_neurons_to_neuron_map(2,1);
    L_neuron = axes_neurons_to_neuron_map(3,1);R_neuron = axes_neurons_to_neuron_map(4,1);
    D_neuron = axes_neurons_to_neuron_map(5,1);V_neuron = axes_neurons_to_neuron_map(6,1);
    
    if (mu_r_centered(A_neuron,:)-mu_r_centered(P_neuron,:))*PA' < 0
        PA = -PA;
    end
    if D_neuron ~= 0 && V_neuron ~= 0
        if (mu_r_centered(V_neuron,:)-mu_r_centered(D_neuron,:))*DV' < 0
            DV = -DV;
        end
        if cross(DV,PA)*LR' < 0
            LR = -LR;
        end
    else
        if (mu_r_centered(R_neuron,:)-mu_r_centered(L_neuron,:))*LR' < 0
            LR = -LR;
        end
        if cross(PA,LR)*DV' < 0
            DV = -DV;
        end
    end

    % take neurons coordinates to AP, LR, DV axis
    X = mu_r_centered*PA';
    Y = mu_r_centered*LR';
    Z = mu_r_centered*DV';
    
    target = [X,Y,Z];
    [Transform, C] = cpd_register(source, target, opt);
    dist = repmat(diag(Transform.T*Transform.T'),1,size(Transform.X,1)) + repmat(diag(Transform.X*Transform.X')',size(Transform.T,1),1) - 2*Transform.T*Transform.X';
    [sort_dist,sort_index] = sort(dist,2,'ascend');
%     Transform = GLTP_EM(source',target',param);
    for n = 1:size(landmark_list,1)
        if ~isempty(find(strcmp(landmark_list{n,1},marker_name)))
            curr_neuron = marker_to_neuron_map(find(strcmp(landmark_list{n,1},marker_name)),1);
            CPD_match = Neuron_head{C(curr_neuron,1),1};
            if strcmp(landmark_list{n,1},CPD_match)
                match_top_matrix(i,n) = 1;
            else
                match_top_matrix(i,n) = 0;
            end
            top_3_labels = Neuron_head(sort_index(curr_neuron,1:3),:);
            if ~isempty(find(strcmp(landmark_list{n,1},top_3_labels)))
                match_top_3_matrix(i,n) = 1;
            else
                match_top_3_matrix(i,n) = 0;
            end
            top_5_labels = Neuron_head(sort_index(curr_neuron,1:8),:);
            if ~isempty(find(strcmp(landmark_list{n,1},top_5_labels)))
                match_top_5_matrix(i,n) = 1;
            else
                match_top_5_matrix(i,n) = 0;
            end
        end
    end
end

%%%% calculate correct prediction fraction
% NaN in match matrix are landmarks not present in the data. 0 are not
% matched correctly and 1 are matched correctly.
correct_fraction = zeros(size(match_top_matrix,1),1);
correct_fraction_top_3 = zeros(size(match_top_matrix,1),1);
correct_fraction_top_5 = zeros(size(match_top_matrix,1),1);
for i = 1:size(match_top_matrix,1)
    num_landmarks = size(match_top_matrix,2) - sum(isnan(match_top_matrix(i,:)));
    correct = nansum(match_top_matrix(i,:));
    correct_fraction(i,1) = correct/num_landmarks;
    correct_top_3 = nansum(match_top_3_matrix(i,:));
    correct_fraction_top_3(i,1) = correct_top_3/num_landmarks;
    correct_top_5 = nansum(match_top_5_matrix(i,:));
    correct_fraction_top_5(i,1) = correct_top_5/num_landmarks;
end