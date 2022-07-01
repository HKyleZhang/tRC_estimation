#!/bin/bash -l
#SBATCH -A account
#SBATCH -p node
#SBATCH -n 20
#SBATCH -t 4:00:00

source activate recsup

in_dir1="${Project_dir}/Data/Processed"
    in_folder[0]="All_ZW"
    in_folder[1]="All_Z+GRW_W"

out_dir1="${Project_dir}/Analysis/ML_tree"

outgroup="Ano"

# ---------------------------------------------
i=0
while [[ $i -lt ${#in_folder[@]} ]]; do
    out_folder[$i]=$(echo "${in_folder[$i]}_RAxML")

    if [[ ! -d ${out_dir1}/${out_folder[$i]} ]]; then mkdir -p ${out_dir1}/${out_folder[$i]}; fi    
    cd ${SNIC_TMP}/$(basename ${in_folder[$i]})


# RAxML ML tree -------------------------------
    ls *.fasta > seq_files.txt
    parallel -j 19 'raxmlHPC -s {} -m GTRGAMMAX -f a -p 20210504 -x 20210504 -N autoMRE -n $(echo {} | cut -d '.' -f 1)' :::: seq_files.txt

    ls RAxML_bipartitions.* > tree_files.txt
    parallel -j 19 "gotree reroot outgroup -i {} -o {}.reroot ${outgroup}" :::: tree_files.txt

    ls RAxML_bipartitions.*.reroot > reroot_tree_files.txt
    parallel -j 19 "gotree collapse support -s 70 -i {} -o {}.collapsed" :::: reroot_tree_files.txt
    
    mkdir collapsed_reroot_tree
    cp *.collapsed collapsed_reroot_tree/
    mkdir reroot_tree
    cp *.reroot reroot_tree/
    mkdir tree
    cp RAxML_bipartitions.* tree/
    mkdir bootstrap
    cp RAxML_bootstrap.* bootstrap/
    mkdir info
    cp RAxML_info.* info/

    cp -r *tree/ bootstrap/ info/ ${out_dir1}/${out_folder[$i]}/

    i=$((i+1))
done
