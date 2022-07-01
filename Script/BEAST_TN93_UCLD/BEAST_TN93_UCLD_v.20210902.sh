#!/bin/bash

# R code 1: Use beautier in babette to make xml file
Babette_beautier='library(beautier)
file <- "<arg>"
name <- strsplit(file, ".", fixed = TRUE)[[1]][1]
new_name <- paste0(name, "_temp.xml")
create_beast2_input_file(file, new_name)'

usage='Options:
    -i [fasta file]
    -b [taxon W]
    -t [template]
    -s [seed]
    -h help'

# Read the flags
while getopts "i:b:t:s:h" opt; do
    case ${opt} in
    i) file=${OPTARG} ;;
    b) taxon=${OPTARG} ;;
    t) template=$(cat ${OPTARG});;
    s) seed=${OPTARG} ;;
    h) echo "${usage}" && exit ;;
    esac
done

# ------------------------------------------
name=$(basename "${file}" | cut -d "." -f 1)
mkdir ${name}/
cp ${file} ${name}/${name}.fasta

in_file=$(echo "${name}/${name}.fasta" | sed -e 's/\//\\\//g')
Babette_beautier_temp=$(echo "${Babette_beautier}" | sed "s/<arg>/${in_file}/")
Rscript <(echo "${Babette_beautier_temp}") 2>&1 >/dev/null

# Make hybrid xml file ---------------------
file_marker=$(($(cat ${name}/${name}_temp.xml | grep -n '</data>' | cut -d ":" -f 1) + 1))
cat ${name}/${name}_temp.xml | sed -n "1,${file_marker}p" >${name}/${name}.xml
echo "${template}" | sed "s/EXAMPLE/${name}/g" | sed "s/TAXON_W/${taxon}_W/g" >>${name}/${name}.xml
rm -f ${name}/${name}.fasta ${name}/${name}_temp.xml

# Run BEAST --------------------------------
beast -seed ${seed} ${name}/${name}.xml 2>&1 >/dev/null
mv ${name}.* ${name}/

# Message ----------------------------------
echo ">>>>${name} Finished!<<<<"
