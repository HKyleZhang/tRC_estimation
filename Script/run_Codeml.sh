#!/bin/bash

taxa_list="GRW_Z
GRW_W
CRW_Z
CRW_W
MW_Z
MW_W
IO_Z
IO_W
LL_Z
LL_W
BR_Z
BR_W
GrT
ZeF
BlM
Bud
Chi
Emu
Ano"

ctl_template="
      seqfile = dataset.phy * sequence data file name 
      outfile = codeml_output * main result file name 

        noisy = 0  * 0,1,2,3,9: how much rubbish on the screen 
      verbose = 0  * 1: detailed output, 0: concise output 
      runmode = -2  * 0: user tree;  1: semi-automatic;  2: automatic 
                   * 3: StepwiseAddition; (4,5):PerturbationNNI; -2: pairwise 
      seqtype = 1  * 1:codons; 2:AAs; 3:codons-->AAs 
    CodonFreq = 2  * 0:1/61 each, 1:F1X4, 2:F3X4, 3:codon table 
        ndata = NUM_DATASET 
        clock = 0   * 0:no clock, 1:clock; 2:local clock 

        model = 0 
                   * models for codons: 
                       * 0:one, 1:b, 2:2 or more dN/dS ratios for branches 
                   * models for AAs or codon-translated AAs: 
                       * 0:poisson, 1:proportional,2:Empirical,3:Empirical+F 
                       * 6:FromCodon, 8:REVaa_0, 9:REVaa(nr=189) 
      NSsites = 0  * 0:one w;1:neutral;2:selection; 3:discrete;4:freqs; 
                   * 5:gamma;6:2gamma;7:beta;8:beta&w;9:beta&gamma; 
                   * 10:beta&gamma+1; 11:beta&normal>1; 12:0&2normal>1; 
                   * 13:3normal>0 
        icode = 0  * 0:universal code; 1:mammalian mt; 2-11:see below 
 
    fix_omega = 0  * 1: omega or omega_1 fixed, 0: estimate  
        omega = .4 * initial or fixed omega, for codons or codon-based AAs 

    cleandata = 1  * remove sites with ambiguity data (1:yes, 0:no)? 
"

while getopts "i:" opt; do
    case ${opt} in
    i) aln_folder=$(echo "${OPTARG}" | cut -d "/" -f 1) ;;
    esac
done

dir=$(pwd)

# Export required files
echo "${taxa_list}" >${dir}/taxa_list.txt

# Convert to phylip format
## python3 is an alias to call python 3
mkdir ${dir}/phylip
for file in ${dir}/${aln_folder}/*.fasta; do
    file_name=$(basename "${file}" | cut -d '.' -f 1)
    python3 $HOME/Software/BioProg_Mac/amas/AMAS.py convert -d dna -f fasta -i ${file} -u phylip
    mv ${dir}/${file_name}.fasta-out.phy ${dir}/phylip/${file_name}.phy

    while read line; do
        taxa=$(echo "${line}" | tr -d '[:blank:]')
        sed -i "s/\<${taxa}\>[[:blank:]]*/${taxa}  \n/" ${dir}/phylip/${file_name}.phy
    done <${dir}/taxa_list.txt
done

# Make control file
ls ${dir}/phylip/*.phy >file_list.txt
cat ${dir}/phylip/*.phy >${dir}/dataset.phy
num_dataset=$(ls ${dir}/phylip/*.phy | wc -l | tr -d ' ')
echo "${ctl_template}" | sed "s/NUM_DATASET/${num_dataset}/" >codeml.ctl
rm -f ${dir}/taxa_list.txt
rm -rf ${dir}/phylip/

# Run Codeml
CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate recsup
codeml codeml.ctl
