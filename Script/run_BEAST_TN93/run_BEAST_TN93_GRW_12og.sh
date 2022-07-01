#!/bin/bash -l
#SBATCH -A account
#SBATCH -p node
#SBATCH -n 20
#SBATCH -t 3-00:00:00

module load R/4.0.0 bioinfo-tools beast2/2.6.3
conda activate recsup

in_dir1="${Project_dir}/Script/BEAST_TN93_UCLD"
    in_file11="BEAST_TN93_UCLD_v.20210902.sh"
    in_file12="beast_template_12og.txt"

in_dir2="${Project_dir}/Input/species_relative_time"
    in_file21="species_rel_time_12og.txt"

in_dir3="${Project_dir}/Data/Ready-to-be_run"
    in_folder31="c11"

out_dir1="${Project_dir}/Analysis/Species_combinations_BEAST"

seed=$RANDOM

# ------------------------------------------
folder_list=$(ls ${in_dir3}/${in_folder31})

for folder in ${folder_list}; do
    if [[ ! -d ${out_dir1}/${in_folder31}_seed${seed}/${folder} ]]; then mkdir -p ${out_dir1}/${in_folder31}_seed${seed}/${folder}; fi 
    mkdir ${SNIC_TMP}/run_temp/
    cd ${SNIC_TMP}/run_temp/
    cp ${in_dir1}/${in_file11} \
       ${in_dir1}/${in_file12}  ${SNIC_TMP}/run_temp/
    cp ${in_dir2}/${in_file21}  ${SNIC_TMP}/run_temp/
    cp -r ${in_dir3}/${in_folder31}/${folder} ${SNIC_TMP}/run_temp/

    species=$(echo ${folder} | sed "s/-Ano-GRW_Z+GRW_W//")
    num_sp=$(($(echo ${species} | grep -o '-' | wc -l) + 1))
    i=1
    while [[ $i -le ${num_sp} ]]; do
        taxon=$(echo ${species} | cut -d '-' -f $i)
        rel_time=$(cat ${in_file21} | grep ${taxon} | cut -f2)
        sed -i "s/$(echo "TAXON${i}+")/$(echo "${taxon}+")/g" ${in_file12}
        sed -i "s/$(echo "TAXON${i}\"")/$(echo "${taxon}\"")/g" ${in_file12}
        sed -i "s/$(echo "REL_TIME${i}<")/$(echo "${rel_time}<")/g" ${in_file12}
        i=$((i + 1))
    done

    dir=$(pwd)
    ls ${folder}/ > seq_files.txt

# run BEAST ---------------------------------
    export BEAST_XMX=15g
    echo "Ready to run BEAST!"
    parallel -j 17 "bash ${in_file11} -i ${dir}/${folder}/{} -b GRW -t ${in_file12} -s ${seed}" :::: seq_files.txt

# ------------------------------------------
    mkdir Raw/
    for f in ${folder}/*.fasta; do
        name=$(basename $f | cut -d '.' -f 1)
        mv ${name} Raw/
    done

    mkdir beast_log/
    mkdir beast_trees/
    for j in $(ls Raw/); do
        cp Raw/${j}/${j}*.log beast_log/${j}.log
        cp Raw/${j}/${j}*.trees beast_trees/${j}.trees
    done
    cp -r beast*/ Raw/ ${out_dir1}/${in_folder31}_seed${seed}/${folder}

# -------------------------------------
rcode='library(tidyverse)
library(tracerer)

beast_log_parse <- function(input) {
  file_list <- list.files(path = input$path, pattern = "*.log")
  info_summary <- list()
  j <- 1
  name <- ""
  for (i in 1:length(file_list)) {
    name[j] <- strsplit(file_list[i], input$sep)[[1]][1]
    
    log_file <- parse_beast_log(paste(input$path,file_list[i],sep = "/"))
    log_file_burnin <- remove_burn_ins(log_file, burn_in_fraction = 0.1)
    
    grw <- calc_summary_stats_trace(log_file_burnin$mrca.age.Est., sample_interval = 100) %>% as_tibble() %>% select(-mode, -geom_mean)
    
    info_summary[[j]] <- mutate(grw, Transcript_ID = name[j])
    
    j <- j + 1
  }
  
  info_summary <- reduce(info_summary, bind_rows) %>% 
    select(Transcript_ID, everything())
  
  return(info_summary)
}

folder_path <- "./beast_log"
models <- "TN93"
dataset <- "GRW"
clock <- "UCLD"
name_split <- ".l"

dd <- tibble(model = models,  
             dataset = dataset, 
             clock_model = clock, 
             path = folder_path, 
             sep = name_split) %>% 
    nest(input = c(path, sep)) %>% 
    mutate(estimate = map(input, beast_log_parse))

dd_unnest <- dd %>% select(-input) %>% unnest(cols = "estimate")
write_csv(dd_unnest, "BEAST_log_summary.csv")
'

# ---------------------------------------
    Rscript <(echo "${rcode}")
    if [[ ! -d ${out_dir1}/BEAST_log_summary/ ]]; then mkdir ${out_dir1}/BEAST_log_summary/; fi    
    cp BEAST_log_summary.csv ${out_dir1}/BEAST_log_summary/BEAST_log_summary_12og.csv

# ---------------------------------------
    cd ${SNIC_TMP}/
    rm -rf run_temp/
done
