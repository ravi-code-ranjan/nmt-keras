#!/usr/bin/env bash

task=emea
src_lan=en
trg_lan=fr
split=dev
base_model_path=/media/HDD_2TB/MODELS/online_learning/
model_path=${base_model_path}/${task}_${src_lan}${trg_lan}_GroundHogModel_src_emb_512_bidir_True_enc_LSTM_512_dec_LSTM_512_deepout_linear_trg_emb_512_Adadelta_1.0
model_files=update_130000 
dest_dir=Online_learning_experiments/$task/${src_lan}${trg_lan}/
verbose=1

mkdir -p  $dest_dir

src=/media/HDD_2TB/DATASETS/${task}/${src_lan}${trg_lan}/${split}.${src_lan}
trg=/media/HDD_2TB/DATASETS/${task}/${src_lan}${trg_lan}/${split}.${trg_lan}

for algo in PAS ; do
	for lr in 0.1 0.01 0.001 0.0001 0.00001 ; do
	    for c in 1.0 ; do
            for clipVal in 0. 1. ; do
                echo "`date` Algo: ${algo}. LR: ${lr}. CLIP_C: ${clipVal}"
                echo -e "\t Storing log in ${dest_dir}/log.${split}.${task}_${src_lan}${trg_lan}.${algo}.lr_${lr}.clip_${clipVal}.c_${c}"
                hyps=${dest_dir}/hyps_k3.${split}.${task}_${src_lan}${trg_lan}.${algo}.lr_${lr}.clip_${clipVal}.c_${c}
                python main.py --config ${model_path}/config.pkl --dataset datasets/Dataset_${task}_${src_lan}${trg_lan}.pkl \
                       -src ${src} \
                       -trg ${trg} \
                       --hypotheses ${hyps} \
                       --models ${model_path}/${model_files} -o -v ${verbose} \
                       --changes LR=${lr} OPTIMIZER=${algo} CLIP_C=${clipVal} C=${c} N_BEST_OPTIMIZER=True > ${dest_dir}/log.${split}.${task}_${src_lan}${trg_lan}.${algo}.lr_${lr}.clip_${clipVal}.c_${c} 2>&1
                sleep 3
                echo "`calc_bleu -r ${trg} -t ${hyps}`"
            done
        done
    done
done
echo "Finished!"