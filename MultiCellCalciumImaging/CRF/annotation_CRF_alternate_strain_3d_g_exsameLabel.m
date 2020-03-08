%%%% function for automatic annotation of one stack
%%%% Changes - 
%%%% 1. Geodesic distance based edge potentials
%%%% 2. log linear hard edge potentials
%%%% 3. Handle duplicates
%%%%    3a. Reassign all duplicate nodes
%%%%    3b. Form graph structure of all nodes, change potential so that
%%%%    unassigned nodes can be assigned unassigned labels, clamp potential
%%%%    for assigned nodes
%%%% 4. Hide landmarks and check their predicted identities
%%%% 5. Node potential based on normalized distance along PA
%%%% 6. Relative angle based edge-potentials

function [landmark_match_score,not_match,node_label,Neuron_head] = annotation_CRF_alternate_strain_3d_g_exsameLabel(data,numLandmarks,numLabelRemove,rng_fix_landmark,num)
rng shuffle
%%% load image data and neuron relationship data (don't forget
%%% landmark_names and landmark_to_neuron_map
load(['C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_alternateStrains\AML5\RelPos\',data,'.mat'])
load('C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\data_neuron_relationship.mat')
% load(['/gpfs/pace1/project/pchbe2/schaudhary9/Annotation/NeuroPAL/AlternateStrains/RelPos/',data,'.mat'])
% load('/gpfs/pace1/project/pchbe2/schaudhary9/Annotation/NeuroPAL/data_neuron_relationship.mat')

%%% remove all labels that are not present in the annotated neurons. This
%%% is the same case matching to same number of labels in atals simulations
% keep_neurons = {'BAGL';'BAGR';'URXL';'URXR';'ASEL';'ASER';'AFDL';'AFDR';'AQR'}; % AX216
keep_neurons = {'IL2R';'IL1R';'IL1VR';'IL1VL';'IL1DR';'IL1DL';'IL2L';'IL1L';'AIBR';'AIBL';'AIZR';'AIZL';'ASGR';'ASGL';'RIVR';'RIVL';'RIGR';'AVG'}; % AML5
ind_remove = 1:1:size(Neuron_head,1);
ind_keep = [];
for i = 1:size(keep_neurons,1)
    ind_keep = [ind_keep;find(strcmp(keep_neurons{i,1},Neuron_head))];
end
ind_remove(:,ind_keep) = [];
Neuron_head(ind_remove,:) = [];
DV_matrix(ind_remove,:) = [];
DV_matrix(:,ind_remove) = [];
geo_dist(ind_remove,:) = [];
geo_dist(:,ind_remove) = [];
LR_matrix(ind_remove,:) = [];
LR_matrix(:,ind_remove) = [];
PA_matrix(ind_remove,:) = [];
PA_matrix(:,ind_remove) = [];
ganglion(ind_remove,:) = [];
X_rot(ind_remove,:) = [];
Y_rot(ind_remove,:) = [];
Z_rot(ind_remove,:) = [];
X_rot_norm(ind_remove,:) = [];

% %%% remove some labels to create variability in solution
landmark_names = {};
% dont_remove = zeros(size(landmark_names,1),1);
% for i = 1:size(dont_remove,1)
%     dont_remove(i,1) = find(strcmp(Neuron_head,landmark_names{i,1}));
% end
% all_dont_remove = [1:1:size(Neuron_head,1)]';
% all_dont_remove(dont_remove,:) = [];
% ganglion(dont_remove,:) = [];
% 
% anterior_index = all_dont_remove(ganglion(:,1) == 1);
% lateral_index = all_dont_remove(ganglion(:,1) == 2);
% ventral_index = all_dont_remove(ganglion(:,1) == 3);
% num_anterior_remove = round(size(anterior_index,1)/size(ventral_index,1)*numLabelRemove/(size(anterior_index,1)/size(ventral_index,1)+size(lateral_index,1)/size(ventral_index,1)+1));
% num_lateral_remove = round(size(lateral_index,1)/size(ventral_index,1)*numLabelRemove/(size(anterior_index,1)/size(ventral_index,1)+size(lateral_index,1)/size(ventral_index,1)+1));
% num_ventral_remove = numLabelRemove - num_anterior_remove - num_lateral_remove;
% 
% remove_anterior = anterior_index(randperm(size(anterior_index,1),num_anterior_remove),:);
% remove_lateral = lateral_index(randperm(size(lateral_index,1),num_lateral_remove),:);
% remove_ventral = ventral_index(randperm(size(ventral_index,1),num_ventral_remove),:);
% remove_index = [remove_anterior;remove_lateral;remove_ventral];
% Neuron_head(remove_index,:) = [];
% DV_matrix(remove_index,:) = [];
% DV_matrix(:,remove_index) = [];
% geo_dist(remove_index,:) = [];
% geo_dist(:,remove_index) = [];
% LR_matrix(remove_index,:) = [];
% LR_matrix(:,remove_index) = [];
% PA_matrix(remove_index,:) = [];
% PA_matrix(:,remove_index) = [];
% X_rot(remove_index,:) = [];
% Y_rot(remove_index,:) = [];
% Z_rot(remove_index,:) = [];
% X_rot_norm(remove_index,:) = [];

% generate axis
A_neuron = axes_neurons_to_neuron_map(1,1);
P_neuron = axes_neurons_to_neuron_map(2,1);
L_neuron = axes_neurons_to_neuron_map(3,1);
R_neuron = axes_neurons_to_neuron_map(4,1);
D_neuron = axes_neurons_to_neuron_map(5,1);
V_neuron = axes_neurons_to_neuron_map(6,1);
mu_r_centered = mu_marker - repmat(mean(mu_marker),size(mu_marker,1),1);

if ind_PCA == 1
    [coeff,score,latent] = pca(mu_r_centered);
    PA = coeff(:,axes_param(1,1))';
    PA = PA/norm(PA);
    LR = coeff(:,axes_param(1,2))';
    LR = LR/norm(LR);
    DV = coeff(:,axes_param(1,3))';
    DV = DV/norm(DV);
    
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
else
    PA = mu_r_centered(A_neuron,:) - mu_r_centered(P_neuron,:); % PA axis based on A,P
    PA = PA/norm(PA);
    if L_neuron ~= 0 && R_neuron ~= 0
        LR = mu_r_centered(R_neuron,:) - mu_r_centered(L_neuron,:); % LR axis based on L,R
        LR = LR/norm(LR);
        % fun = @(x)-(x(1)*coeff(1,1) + x(2)*coeff(2,1) + x(3)*coeff(3,1))^2/(x(1)^2 + x(2)^2 + x(3)^2);
        fun = @(x)-(x(1)*LR(1,1) + x(2)*LR(1,2) + LR(1,3))^2/(x(1)^2 + x(2)^2 + 1^2);
        Aeq = PA(1,1:2);
        beq = -PA(1,3);
        % x0 = coeff(:,1);
        x0 = LR(1,1:2);
        PA = fmincon(fun,x0,[],[],Aeq,beq);   % PA axis (perperndicular to LR and in direction of PC1)
        PA = [PA,1];
        PA = PA/norm(PA);

        % DV axis (perperndicular to LR and PA axis)
        A = [PA(1,1:2);LR(1,1:2)];
        b = [-PA(1,3);-LR(1,3)];
        DV = inv(A'*A)*A'*b;           
        DV = [DV',1];
        DV = DV/norm(DV);
        
        if (mu_r_centered(A_neuron,:)-mu_r_centered(P_neuron,:))*PA' < 0
            PA = -PA;
        end
        if cross(PA,LR)*DV' < 0
            DV = -DV;
        end
    else
        DV = mu_r_centered(V_neuron,:) - mu_r_centered(D_neuron,:); % LR axis based on L,R
        DV = DV/norm(DV);
        % fun = @(x)-(x(1)*coeff(1,1) + x(2)*coeff(2,1) + x(3)*coeff(3,1))^2/(x(1)^2 + x(2)^2 + x(3)^2);
        fun = @(x)-(x(1)*DV(1,1) + x(2)*DV(1,2) + DV(1,3))^2/(x(1)^2 + x(2)^2 + 1^2);
        Aeq = PA(1,1:2);
        beq = -PA(1,3);
        % x0 = coeff(:,1);
        x0 = DV(1,1:2);
        PA = fmincon(fun,x0,[],[],Aeq,beq);   % PA axis (perperndicular to LR and in direction of PC1)
        PA = [PA,1];
        PA = PA/norm(PA);

        % DV axis (perperndicular to LR and PA axis)
        A = [PA(1,1:2);LR(1,1:2)];
        b = [-PA(1,3);-LR(1,3)];
        DV = inv(A'*A)*A'*b;           
        DV = [DV',1];
        DV = DV/norm(DV);
        
        if (mu_r_centered(A_neuron,:)-mu_r_centered(P_neuron,:))*PA' < 0
            PA = -PA;
        end
        if cross(PA,LR)*DV' < 0
            DV = -DV;
        end
    end
end
% figure,scatter3(mu_r_centered(:,1),mu_r_centered(:,2),mu_r_centered(:,3),'.r')
% hold on
% plot3([0,50*PA(1,1)],[0,50*PA(1,2)],[0,50*PA(1,3)],'b','LineWidth',2.5)
% plot3([0,20*LR(1,1)],[0,20*LR(1,2)],[0,20*LR(1,3)],'g','LineWidth',2.5)
% plot3([0,20*DV(1,1)],[0,20*DV(1,2)],[0,20*DV(1,3)],'k','LineWidth',2.5)

% take neurons coordinates to AP, LR, DV axis
X = mu_r_centered*PA';
Y = mu_r_centered*LR';
Z = mu_r_centered*DV';
X_norm = (X-min(X))/(max(X)-min(X));

addpath(genpath('C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Joint_tracking\UGM'))
% addpath(genpath('/gpfs/pace1/project/pchbe2/schaudhary9/Annotation/ParameterSearch/UGM'))
% create spatial neighborhood
K = 6;
pos = [mu_r_centered(:,1),mu_r_centered(:,2),mu_r_centered(:,3)];
euc_dist = repmat(diag(pos*pos'),1,size(pos,1)) + repmat(diag(pos*pos')',size(pos,1),1) - 2*pos*pos';
[sort_euc_dist,sort_index] = sort(euc_dist,2);
adj = zeros(size(X,1),size(X,1));
for i = 1:size(adj,1)
    adj(i,sort_index(i,2:min(size(X,1),K+1))) = 1;
end
adj = max(adj,adj');
G = graph(adj);
geo_dist_r = distances(G);
geo_dist_r(find(isinf(geo_dist_r))) = 50;
% [sOut,tOut] = findedge(G);
% figure,scatter3(X(:,1),Y(:,1),Z(:,1),30,'.r')
% hold on
% for i = 1:size(sOut,1)
%     plot3([X(sOut(i,1));X(tOut(i,1))],[Y(sOut(i,1));Y(tOut(i,1))],[Z(sOut(i,1));Z(tOut(i,1))],'k')
% end
% adj_lfs = exp(-geo_dist_r.^2/(2*max(max(geo_dist_r))));
% D = diag(sum(adj_lfs,2));
% L = D - adj_lfs;
% [eigvec_r,eigval_r] = eig(L);

% create node and edge potential
adj = ones(size(X,1),size(X,1)); % fully connected graph structure of CRF
adj = adj - diag(diag(adj));
nStates = size(Neuron_head,1);
nNodes = size(X,1);
edgeStruct = UGM_makeEdgeStruct(adj,nStates);

node_pot =  ones(nNodes,nStates);
% loc_sigma = 0.8;
% node_pot = zeros(nNodes,nStates);
% for i = 1:nNodes
%     node_pot(i,:) = diag(exp(-((ones(size(X_rot_norm))*X_norm(i,1) - X_rot_norm)*(ones(size(X_rot_norm))*X_norm(i,1) - X_rot_norm)')/(2*loc_sigma^2)))';
% end

% VC_neurons_index = find(VC_neurons(:,1) == 1);
% VC_ind_matrix = zeros(nStates,nStates);
% VC_ind_matrix(VC_neurons_index,VC_neurons_index) = 1;
% edge_pot = zeros(nStates,nStates,edgeStruct.nEdges);
% 
% dist_PA = repmat(diag(pos(:,1)*pos(:,1)'),1,size(pos(:,1),1)) + repmat(diag(pos(:,1)*pos(:,1)')',size(pos(:,1),1),1) - 2*pos(:,1)*pos(:,1)';
% dist_PA(find(dist_PA<0)) = 0;
% dist_PA = sqrt(dist_PA);
% dist_PA = dist_PA/(0.1); % dist_PA/4 = 5 => dist_PA = 20 => 20 pixels radius will reach 0.99 value
% 
% dist_LR = repmat(diag(pos(:,2)*pos(:,2)'),1,size(pos(:,2),1)) + repmat(diag(pos(:,2)*pos(:,2)')',size(pos(:,2),1),1) - 2*pos(:,2)*pos(:,2)';
% dist_LR(find(dist_LR<0)) = 0;
% dist_LR = sqrt(dist_LR);
% dist_LR = dist_LR/(0.1); % dist_LR/2 = 5 => dist_LR = 10 => 10 pixels radius will reach 0.99 value
% 
% 
% dist_DV = repmat(diag(pos(:,3)*pos(:,3)'),1,size(pos(:,3),1)) + repmat(diag(pos(:,3)*pos(:,3)')',size(pos(:,3),1),1) - 2*pos(:,3)*pos(:,3)';
% dist_DV(find(dist_DV<0)) = 0;
% dist_DV = sqrt(dist_DV);
% dist_DV = dist_DV/(0.1); %(0.00001*std(dist_DV(find(triu(dist_DV,1)>0))));
% 
% PA_matrix2 = PA_matrix;
% LR_matrix2 = LR_matrix;
% DV_matrix2 = DV_matrix;
% PA_matrix2(find(PA_matrix == 0)) = -1;
% LR_matrix2(find(LR_matrix == 0)) = -1;
% DV_matrix2(find(DV_matrix == 0)) = -1;

lambda_PA = 0;
lambda_LR = 0;
lambda_DV = 0;
lambda_geo = 0;
lambda_angle = 1;
for i = 1:edgeStruct.nEdges
    node1 = edgeStruct.edgeEnds(i,1);
    node2 = edgeStruct.edgeEnds(i,2);
    angle_matrix = get_relative_angles(X_rot,Y_rot,Z_rot,X,Y,Z,node1,node2);
    if X(node1,1) < X(node2,1)
        if Y(node1,1) < Y(node2,1)
            if Z(node1,1) < Z(node2,1)
                pot = exp(lambda_PA*PA_matrix).*exp(lambda_DV*DV_matrix).*exp(lambda_LR*LR_matrix).*exp(exp(-lambda_geo*(geo_dist-geo_dist_r(node1,node2)).^2)).*exp(lambda_angle*angle_matrix);
            else
                pot = exp(lambda_PA*PA_matrix).*exp(lambda_DV*DV_matrix').*exp(lambda_LR*LR_matrix).*exp(exp(-lambda_geo*(geo_dist-geo_dist_r(node1,node2)).^2)).*exp(lambda_angle*angle_matrix);
            end
        else
            if Z(node1,1) < Z(node2,1)
                pot = exp(lambda_PA*PA_matrix).*exp(lambda_DV*DV_matrix).*exp(lambda_LR*LR_matrix').*exp(exp(-lambda_geo*(geo_dist-geo_dist_r(node1,node2)).^2)).*exp(lambda_angle*angle_matrix);
            else
                pot = exp(lambda_PA*PA_matrix).*exp(lambda_DV*DV_matrix').*exp(lambda_LR*LR_matrix').*exp(exp(-lambda_geo*(geo_dist-geo_dist_r(node1,node2)).^2)).*exp(lambda_angle*angle_matrix);
            end
        end
    else
        if Y(node1,1) < Y(node2,1)
            if Z(node1,1) < Z(node2,1)
                pot = exp(lambda_PA*PA_matrix').*exp(lambda_DV*DV_matrix).*exp(lambda_LR*LR_matrix).*exp(exp(-lambda_geo*(geo_dist-geo_dist_r(node1,node2)).^2)).*exp(lambda_angle*angle_matrix);
            else
                pot = exp(lambda_PA*PA_matrix').*exp(lambda_DV*DV_matrix').*exp(lambda_LR*LR_matrix).*exp(exp(-lambda_geo*(geo_dist-geo_dist_r(node1,node2)).^2)).*exp(lambda_angle*angle_matrix);
            end
        else
            if Z(node1,1) < Z(node2,1)
                pot = exp(lambda_PA*PA_matrix').*exp(lambda_DV*DV_matrix).*exp(lambda_LR*LR_matrix').*exp(exp(-lambda_geo*(geo_dist-geo_dist_r(node1,node2)).^2)).*exp(lambda_angle*angle_matrix);
            else
                pot = exp(lambda_PA*PA_matrix').*exp(lambda_DV*DV_matrix').*exp(lambda_LR*LR_matrix').*exp(exp(-lambda_geo*(geo_dist-geo_dist_r(node1,node2)).^2)).*exp(lambda_angle*angle_matrix);
            end
        end
    end
    pot(find(pot<0.01)) = 0.001; %  small potential of incompatible matches
    pot = pot - diag(diag(pot)) + 0.001*eye(size(pot,1)); 
    edge_pot(:,:,i) = pot;
end

% No landmarks in alternate strains
clamped = zeros(nNodes,1);

[nodeBel,edgeBel,logZ] = UGM_Infer_Conditional(node_pot,edge_pot,edgeStruct,clamped,@UGM_Infer_LBP);
conserved_nodeBel = nodeBel; %node belief matrix to maintain marginal probabilities after clamping in subsequent steps
% optimal_decode = UGM_Decode_Conditional(node_pot,edge_pot,edgeStruct,clamped,@UGM_Decode_LBP);
[sort_nodeBel,nodeBel_sort_index] = sort(nodeBel,2,'descend');
curr_labels = nodeBel_sort_index(:,1);
[PA_score,LR_score,DV_score,geodist_score,tot_score] = consistency_scores(nNodes,curr_labels,X,Y,Z,PA_matrix,LR_matrix,DV_matrix,geo_dist,geo_dist_r);
[landmark_match_score,not_match] = compare_labels_of_hidden_landmarks(curr_labels,[],marker_name,landmark_names,Neuron_head);

%%% handle duplicate assignments 
orig_state_array = [1:1:size(Neuron_head,1)]';
clamped_neurons = [];
node_label = duplicate_labels(curr_labels,X,Y,Z,PA_matrix,LR_matrix,DV_matrix,geo_dist,geo_dist_r,lambda_geo,clamped_neurons);
cnt = 2;
while find(node_label(:,1) == 0)
    assigned_nodes = find(node_label(:,1) ~= 0);
    assigned_labels = node_label(node_label(:,1) ~= 0,1);
    unassigned_nodes = find(node_label(:,1) == 0);
    
    node_pot =  ones(nNodes,nStates);
%     loc_sigma = 0.8;
%     node_pot = zeros(nNodes,nStates);
%     for i = 1:nNodes
%         node_pot(i,:) = diag(exp(-((ones(size(X_rot_norm))*X_norm(i,1) - X_rot_norm)*(ones(size(X_rot_norm))*X_norm(i,1) - X_rot_norm)')/(2*loc_sigma^2)))';
%     end
    node_pot(unassigned_nodes,assigned_labels) = 0;
    node_pot(find(node_pot<0.01)) = 0.001;
    edge_pot = zeros(nStates,nStates,edgeStruct.nEdges);
    for i = 1:size(edgeStruct.edgeEnds,1)
        node1 = edgeStruct.edgeEnds(i,1);
        node2 = edgeStruct.edgeEnds(i,2);
        angle_matrix = get_relative_angles(X_rot,Y_rot,Z_rot,X,Y,Z,node1,node2);
        if X(node1,1) < X(node2,1)
            if Y(node1,1) < Y(node2,1)
                if Z(node1,1) < Z(node2,1)
                    pot = exp(lambda_PA*PA_matrix).*exp(lambda_DV*DV_matrix).*exp(lambda_LR*LR_matrix).*exp(exp(-lambda_geo*(geo_dist-geo_dist_r(node1,node2)).^2)).*exp(lambda_angle*angle_matrix);
                else
                    pot = exp(lambda_PA*PA_matrix).*exp(lambda_DV*DV_matrix').*exp(lambda_LR*LR_matrix).*exp(exp(-lambda_geo*(geo_dist-geo_dist_r(node1,node2)).^2)).*exp(lambda_angle*angle_matrix);
                end
            else
                if Z(node1,1) < Z(node2,1)
                    pot = exp(lambda_PA*PA_matrix).*exp(lambda_DV*DV_matrix).*exp(lambda_LR*LR_matrix').*exp(exp(-lambda_geo*(geo_dist-geo_dist_r(node1,node2)).^2)).*exp(lambda_angle*angle_matrix);
                else
                    pot = exp(lambda_PA*PA_matrix).*exp(lambda_DV*DV_matrix').*exp(lambda_LR*LR_matrix').*exp(exp(-lambda_geo*(geo_dist-geo_dist_r(node1,node2)).^2)).*exp(lambda_angle*angle_matrix);
                end
            end
        else
            if Y(node1,1) < Y(node2,1)
                if Z(node1,1) < Z(node2,1)
                    pot = exp(lambda_PA*PA_matrix').*exp(lambda_DV*DV_matrix).*exp(lambda_LR*LR_matrix).*exp(exp(-lambda_geo*(geo_dist-geo_dist_r(node1,node2)).^2)).*exp(lambda_angle*angle_matrix);
                else
                    pot = exp(lambda_PA*PA_matrix').*exp(lambda_DV*DV_matrix').*exp(lambda_LR*LR_matrix).*exp(exp(-lambda_geo*(geo_dist-geo_dist_r(node1,node2)).^2)).*exp(lambda_angle*angle_matrix);
                end
            else
                if Z(node1,1) < Z(node2,1)
                    pot = exp(lambda_PA*PA_matrix').*exp(lambda_DV*DV_matrix).*exp(lambda_LR*LR_matrix').*exp(exp(-lambda_geo*(geo_dist-geo_dist_r(node1,node2)).^2)).*exp(lambda_angle*angle_matrix);
                else
                    pot = exp(lambda_PA*PA_matrix').*exp(lambda_DV*DV_matrix').*exp(lambda_LR*LR_matrix').*exp(exp(-lambda_geo*(geo_dist-geo_dist_r(node1,node2)).^2)).*exp(lambda_angle*angle_matrix);
                end
            end
        end
        
        if node_label(node1,1) == 0 && node_label(node2,1) == 0 % unassigned-unassigned nodes
            pot(assigned_labels,assigned_labels) = 0;
        elseif node_label(node1,1) == 0 && node_label(node2,1) ~= 0 % unassigned-assigned nodes
            pot(assigned_labels,:) = 0;
        elseif node_label(node1,1) ~= 0 && node_label(node2,1) == 0 % assigned-unassigned nodes
            pot(:,assigned_labels) = 0;
        else
        end 
        pot(find(pot<0.01)) = 0.001; %  small potential of incompatible matches
        pot = pot - diag(diag(pot)) + 0.001*eye(size(pot,1));
        edge_pot(:,:,i) = pot;
    end
    
    clamped = zeros(nNodes,1);
    clamped(assigned_nodes) = assigned_labels;
    
    [nodeBel,edgeBel,logZ] = UGM_Infer_Conditional(node_pot,edge_pot,edgeStruct,clamped,@UGM_Infer_LBP);
    conserved_nodeBel(unassigned_nodes,:) = nodeBel(unassigned_nodes,:);
    [sort_nodeBel,nodeBel_sort_index] = sort(nodeBel,2,'descend');
    
    curr_labels = nodeBel_sort_index(:,1);
    [PAscore,LRscore,DVscore,geodistscore,totscore] = consistency_scores(nNodes,curr_labels,X,Y,Z,PA_matrix,LR_matrix,DV_matrix,geo_dist,geo_dist_r);
    PA_score(:,cnt) = PAscore;
    LR_score(:,cnt) = LRscore;
    DV_score(:,cnt) = DVscore;
    geodist_score(:,cnt) = geodistscore;
    tot_score(:,cnt) = totscore;
    [landmarkMatchScore,not_match] = compare_labels_of_hidden_landmarks(curr_labels,[],marker_name,landmark_names,Neuron_head);
    landmark_match_score(:,cnt) = landmarkMatchScore;
    
    node_label = duplicate_labels(curr_labels,X,Y,Z,PA_matrix,LR_matrix,DV_matrix,geo_dist,geo_dist_r,lambda_geo,clamped_neurons);
    cnt = cnt + 1;
     if cnt > 5
         break
     end
end
% %%% save experiments results
% experiments_file = ['/gpfs/pace1/project/pchbe2/schaudhary9/Annotation/NeuroPAL/AlternateStrains/RelPos/Results_multi_3D_g/experiments_',data,'_',num2str(numLandmarks),'_',num2str(numLabelRemove),'_',num2str(rng_fix_landmark),'_',num2str(num),'.mat'];
% if exist(experiments_file)
%     load(experiments_file)
%     num_exp = size(experiments,2);
%     
%     experiments(num_exp+1).K = K;
%     experiments(num_exp+1).lambda_PA = lambda_PA;
%     experiments(num_exp+1).lambda_LR = lambda_LR;
%     experiments(num_exp+1).lambda_DV = lambda_DV;
%     experiments(num_exp+1).lambda_geo = lambda_geo;
%     experiments(num_exp+1).PA_score = PA_score;
%     experiments(num_exp+1).LR_score = LR_score;
%     experiments(num_exp+1).DV_score = DV_score;
%     experiments(num_exp+1).geodist_score = geodist_score;
%     experiments(num_exp+1).tot_score = tot_score;
%     experiments(num_exp+1).landmark_match_score = landmark_match_score;
%     experiments(num_exp+1).num_landmarks = numLandmarks;
%     experiments(num_exp+1).loc_sigma = loc_sigma;
%     experiments(num_exp+1).lambda_angle = lambda_angle;
%     experiments(num_exp+1).node_label = node_label;
%     experiments(num_exp+1).numLabelRemove = numLabelRemove;
% %     experiments(num_exp+1).mu_r = mu_r;
% %     experiments(num_exp+1).thisimage_r = thisimage_r;
%     experiments(num_exp+1).Neuron_head = Neuron_head;
% %     experiments(num_exp+1).landmarks_used = rand_selection;
% %     experiments(num_exp+1).landmark_names = landmark_names;
% %     experiments(num_exp+1).landmark_to_neuron_map = landmark_to_neuron_map;
%     save(experiments_file,'experiments')
% else
%     experiments = struct();
%     experiments(1).K = K;
%     experiments(1).lambda_PA = lambda_PA;
%     experiments(1).lambda_LR = lambda_LR;
%     experiments(1).lambda_DV = lambda_DV;
%     experiments(1).lambda_geo = lambda_geo;
%     experiments(1).PA_score = PA_score;
%     experiments(1).LR_score = LR_score;
%     experiments(1).DV_score = DV_score;
%     experiments(1).geodist_score = geodist_score;
%     experiments(1).tot_score = tot_score;
%     experiments(1).landmark_match_score = landmark_match_score;
%     experiments(1).num_landmarks = numLandmarks;
%     experiments(1).loc_sigma = loc_sigma;
%     experiments(1).lambda_angle = lambda_angle;
%     experiments(1).node_label = node_label;
%     experiments(1).numLabelRemove = numLabelRemove;
% %     experiments(1).mu_r = mu_r;
% %     experiments(1).thisimage_r = thisimage_r;
%     experiments(1).Neuron_head = Neuron_head;
% %     experiments(1).landmarks_used = rand_selection;
% %     experiments(1).landmark_names = landmark_names;
% %     experiments(1).landmark_to_neuron_map = landmark_to_neuron_map;
%     save(experiments_file,'experiments')
% end