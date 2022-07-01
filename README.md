# Scripts repository<br><sub> for "Assessment of phylogenetic approaches to study the timing of recombination cessation on sex chromosomes" </sub>

<br>

## List of Contents
* Input/ folder
  + hypothetical_topologies/ folder
  + species_relative_time/ folder
* Script/ folder
  + BEAST_TN93_UCLD/ folder
  + run_BEAST_TN93/ folder
  + recsup_environment.yml
  + run_Codeml.sh
  + run_RAxML_ML_tree.sh
  + run_IQ-Tree_topology_test.sh
  + Approach_summary_plot.Rmd
  + Comparison_between_ELW_BEAST.Rmd
  + Species_combinations_BEAST.Rmd

<br>

## Details

* __hypothetical_topologies/ folder__
The folder contains the 12 hypothetical topologies in newick format. These hypothetical topologies are used in the ELW approach.

* __species_relative_time/ folder__
The folder contains the relative time calibrations for dataset involving 1, 3, 6, 12 outgroups in the BEAST approach.

* __BEAST_TN93_UCLD/ folder__
The folder contains bash script _BEAST_TN93_UCLD_v.20210902.sh_ to generate BEAUTi configuration file and run BEAST2 on 1 alignment file. The template files, _e.g._, _beast_template_12og.txt_ has most of the BEAUTi configuration file, including the priors of site model, clock model and tree model, and is used by _BEAST_TN93_UCLD_v.20210902.sh_ to generate a complete BEAUTi configuration file.

* __run_BEAST_TN93/ folder__
The folder contains bash scripts to run BEAST approach in parallel on a cluster computer. The scripts will use the files in _BEAST_TN93_UCLD/ folder_ and _species_relative_time/ folder_.

* __environment.yml__
This YAML file is used to setup the Conda environment for the analyses.

* __run_Codeml.sh__
The bash script runs Codeml for the dS approach. The script is run locally.

* __run_RAxML_ML_tree.sh__
The bash script constructs maximum likelihood tree using RAxML for the ML<sub>CT</sub> approach. The script is run in parallel on a cluster computer.

* __run_IQ-Tree_topology_test.sh__
The bash script runs topology test using IQ-Tree on a cluster computer. The script will use the files in _hypothetical_topologies/ folder_.

* __Approach_summary_plot.Rmd__
The RMarkdown file has the codes to generate Fig. 3 and Fig. 5.

* __Comparison_between_ELW_BEAST.Rmd__
The RMarkdown file has the codes to generate the major part of Fig. 4.

* __Species_combinations_BEAST.Rmd__
The RMarkdown file has the codes to generate Fig. 6.

<br>

## Appendix
To make it easy to code, the species abbreviation in the scripts are different from that in the paper. The translation can follow the table:

Species (Eng.) | Species (Latin) | Abbr. in the paper | Abbr. in the scripts
---------------|-----------------|----------------------|-----------------------
Great reed warbler | _Acrocephalus arundinaceus_ | _A. aru._| GRW
Clamorous reed warbler | _Acrocephalus stentoreus_ | _A. ste._ | CRW
Marsh warbler | _Acrocephalus palustris_ | _A. pal._ | MW
Western olivaceous warbler | _Iduna opaca_ | _I. opa._ | IO
Savi’s warbler | _Locustella luscinioides_ | _L. lus._ | LL
Bearded reedling | _Panurus biarmicus_ | _P. bia._ | BR
Great tit | _Parus major_ | _P. maj._ | GrT
Zebra finch | _Taeniopygia guttata_ | _T. gut._ | ZeF
Blue-crowned manakin | _Lepidothrix coronata_ | _L. cor._ | BlM
Budgerigar | _Melopsittacus undulatus_ | _M. und._ | Bud
Chicken | _Gallus gallus_ | _G. gal._ | Chi
Emu | _Dromaius novaehollandiae_ | _D. nov._ | Emu
Green anole | _Anolis carolinensis_ | _A. car._ | Ano


