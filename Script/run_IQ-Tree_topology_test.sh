#!/bin/bash -l
#SBATCH -A account
#SBATCH -p node
#SBATCH -n 20
#SBATCH -t 5:00:00

conda activate recsup

in_dir1="${Project_dir}/Data/Processed"
    in_folder[0]="All_ZW"
    in_folder[1]="All_Z+GRW_W"

in_dir3="${Project_dir}/Input/Topologies_collection"

out_dir1="${Project_dir}/Analysis/IQ-Tree_topology_test"

replicate="100000"

# ---------------------------------------------
if [[ ! -d ${out_dir1} ]]; then mkdir ${out_dir1}/; fi
i=0
while [[ $i -lt ${#in_folder[@]} ]]; do
    if [[ $i -eq 7 ]]; then
        cp -r ${in_dir2}/${in_folder[$i]} \
              ${in_dir3}/Topo_${in_folder[$i]} $SNIC_TMP
    else
        cp -r ${in_dir1}/${in_folder[$i]} \
              ${in_dir3}/Topo_${in_folder[$i]} $SNIC_TMP
    fi

    cd ${SNIC_TMP}

# Topology test --------------------------------
    for j in ${in_folder[$i]}/*.fasta; do
        name=$(basename $j | cut -d '.' -f 1)
        treefile="Topo_${in_folder[$i]}/constr.tree"

        iqtree -s $j --trees $treefile --test $replicate --test-au

        start=$(($(cat ${in_folder[$i]}/${name}*.iqtree | grep -n "Tree      logL" | cut -d ':' -f 1) + 2))
        end=$(($(cat ${in_folder[$i]}/${name}*.iqtree | grep -n "deltaL  : logL difference from the maximal logl in the set." | cut -d ':' -f 1) - 2))

        
        if [[ ! -e IQ-Tree_topology_test_${in_folder[$i]}.txt ]]; then
            echo "Transcript_ID Tree logL deltaL bp-RELL p-KH p-SH c-ELW p-AU" >>IQ-Tree_topology_test_${in_folder[$i]}.txt
        fi

        cat ${in_folder[$i]}/${name}*.iqtree \
            | sed -n "${start},${end}p" \
            | tr -s ' ' \
            | sed "s/ - / /g" \
            | sed "s/ + / /g" \
            | sed "s/^ /${name} /g" >>IQ-Tree_topology_test_${in_folder[$i]}.txt       
    done

    cp IQ-Tree_topology_test_${in_folder[$i]}.txt ${out_dir1}/
    i=$((i + 1))
done
