%%%% function to analyze probabilistic label run of neuropal data by
%%%% removing random combination of labels in each run. This function is
%%%% for chosen landmarks. Use 'analyze_multi_simulation_pred.m' in
%%%% case of landmarks

%%%% Input - input directories of probabilistic label results

function pred_struct = analyze_multi_simulation_pred_chLand()
%     addpath(genpath('C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\'))
    in_direc = {'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_NeuroPAL\RelPos_Col\Results_chLand\Results_multi_3D_data_20190706_5_chLand\',...
        'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_NeuroPAL\RelPos_Col\Results_chLand\Results_multi_3D_data_20190706_21_chLand\',...
        'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_NeuroPAL\RelPos_Col\Results_chLand\Results_multi_3D_data_20190710_2_chLand\',...
        'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_NeuroPAL\RelPos_Col\Results_chLand\Results_multi_3D_data_20190710_5_chLand\',...
        'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_NeuroPAL\RelPos_Col\Results_chLand\Results_multi_3D_data_20190710_8_chLand\',...
        'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_NeuroPAL\RelPos_Col\Results_chLand\Results_multi_3D_data_20190710_10_chLand\',...
        'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_NeuroPAL\RelPos_Col\Results_chLand\Results_multi_3D_data_20190710_22_chLand\',...
        'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_NeuroPAL\RelPos_Col\Results_chLand\Results_multi_3D_data_20190710_24_chLand\',...
        'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_NeuroPAL\RelPos_Col\Results_chLand\Results_multi_3D_data_20190710_27_chLand\'};
    
    data = {'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_NeuroPAL\RelPos_Col\data_20190706_5.mat',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_NeuroPAL\RelPos_Col\data_20190706_21.mat',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_NeuroPAL\RelPos_Col\data_20190710_2.mat',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_NeuroPAL\RelPos_Col\data_20190710_5.mat',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_NeuroPAL\RelPos_Col\data_20190710_8.mat',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_NeuroPAL\RelPos_Col\data_20190710_10.mat',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_NeuroPAL\RelPos_Col\data_20190710_22.mat',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_NeuroPAL\RelPos_Col\data_20190710_24.mat',...
    'C:\Users\Shivesh\Dropbox (GaTech)\PhD\GlobalBrainCode\GlobalBrainTrackingNew\functions\Annotation_CRF\NeuroPAL_validation\prediction_NeuroPAL\RelPos_Col\data_20190710_27.mat'};
    
    pred_struct = struct();
    
    
    for f = 1:size(in_direc,2)
        top_correct_frac = [];
        top_3_correct_frac = [];
        top_5_correct_frac = [];
        fileList = dir(in_direc{1,f});
        load(data{1,f})
        landmark_list = marker_index;
%         landmark_list = [1:1:size(marker_index,1)]';
        
        labels = {};
        cnt = 1;
        for i = 1:size(fileList,1)
            name = fileList(i).name;
            if ~strcmp(name,'.') && ~strcmp(name,'..')
                load([in_direc{1,f},name])
                
                landmarks_used = [];
                for lu = 1:size(experiments(1).landmarks_used,1)
                    landmarks_used = [landmarks_used;find(strcmp(experiments(1).landmarks_used{lu,1},marker_name))];
                end
                landmark_to_be_pred = landmark_list;
                landmark_to_be_pred(landmarks_used,:) = [];
                for k = 1:size(landmark_to_be_pred,1)
                    if experiments(1).node_label(landmark_to_be_pred(k,1),1) == 0
                        labels{k,cnt} = '';
                    else
                        labels{k,cnt} = experiments(1).Neuron_head{experiments(1).node_label(landmark_to_be_pred(k,1),1),1};
                    end
                end
                cnt = cnt + 1;
            end
        end
        top_labels = calculate_top_labels(labels);
        true_labels = marker_name;
        true_labels(landmarks_used,:) = [];
        top_correct = 0;
        top_3_correct = 0;
        top_5_correct = 0;
        for tr_lb = 1:size(true_labels,1)
            if ~isempty(find(strcmp(true_labels(tr_lb,1),top_labels(tr_lb).top_labels(1,1))))
                top_correct = top_correct + 1;
            end
            if ~isempty(find(strcmp(true_labels(tr_lb,1),top_labels(tr_lb).top_labels(1,1:min(3,size(top_labels(tr_lb).top_labels,2))))))
                top_3_correct = top_3_correct + 1;
            end
            if ~isempty(find(strcmp(true_labels(tr_lb,1),top_labels(tr_lb).top_labels(1,1:min(5,size(top_labels(tr_lb).top_labels,2))))))
                top_5_correct = top_5_correct + 1;
            end
        end
        top_correct_frac = [top_correct_frac;top_correct/size(top_labels,2)];
        top_3_correct_frac = [top_3_correct_frac;top_3_correct/size(top_labels,2)];
        top_5_correct_frac = [top_5_correct_frac;top_5_correct/size(top_labels,2)];
        
        pred_struct(f).data_name = data{1,f};
        pred_struct(f).top_correct_frac = top_correct_frac;
        pred_struct(f).top_3_correct_frac = top_3_correct_frac;
        pred_struct(f).top_5_correct_frac = top_5_correct_frac;
    end
end

function top_labels = calculate_top_labels(labels)
    top_labels = struct();
    for i = 1:size(labels,1)
        uniq_labels = unique(labels(i,:));
        count = [];
        for j = 1:size(uniq_labels,2)
            count(1,j) = sum(strcmp(uniq_labels(1,j),labels(i,:)));
        end
        [sort_count,sort_index] = sort(count,'descend');
        top_labels(i).top_labels = uniq_labels(1,sort_index(1,1:min(5,size(sort_index,2))));
    end
end