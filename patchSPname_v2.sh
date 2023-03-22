#!/bin/bash
# patchSPname_v2.sh *fastaFile* *SraRunTable.txt* 

			### To change |sp| into the actual name of species of the individuals ###

# This script take as input the fasta file from fastq2fasta and the metadata file (SraRuntable.txt)
# It then correct the header for each locus in the fasta file. fastq2fasta doesn't provide the species of each locus but simply a "sp". The "sp" is changed by the correct species for the individuals the locus belong to in accordance with the information in the metadata file.

# this version is quicker than the v1 (by doing the things in a better order), thanks to Mathilde Barthe for the awk line. Very powerful bio-informaticien.

# Check if there is all the arguments needed

if [ -z $1 ]; then
	echo ""
	echo "The first argument is not provided. It should indicate the fasta file to correct."
	echo ""
	exit 2
fi

if [ -z $2 ]; then
	echo ""
	echo "The second argument is not provided. It should indicate the SraRunTable.txt."
	echo ""
	exit 2
fi

# Collect the ID of the different individuals present in the fasta file, put it in a list.txt

echo "Initialization."

# Find the number of column with the Organism and Sample Name
rmSpace=$(head $2 -n 1)
rmSpace=${rmSpace// /_}
rmSpace=${rmSpace//,/ } #to loop on a list of strings
# For Organism
count=0
for header in $rmSpace ; do
        count=$((count+1))
        if [ $header == "Organism" ]; then

                spColumnNb=$count
        
	fi
done

#For Sample_Name
count=0
for header in $rmSpace ; do

        count=$((count+1))
        if [ $header == "Sample_Name" ]; then

                SnColumnNb=$count
       
	fi
done
#SnColumnNb=30 # for Arabis dataset
field=$SnColumnNb","$spColumnNb 
# Produce a list of individuals with their species from the metadatafile
cut $2 -d ',' -f ${field} | tail -n +2 | sort | uniq > infoSP.txt # the tail allow to skip the header of the metadata file. removed -f 28,25

# Proceed to correct/update the fasta file by running a sed for each individual in order to correct the
# species name
sed -i 's/ /_/' infoSP.txt # to set the name of species as Genus_species
sed -i "s/,/\\t/" infoSP.txt # for the awk cmd

# if the line is a header change the sp into the correct species name
awk -F'[\t,|]' 'BEGIN { OFS = "|" }; NR==FNR { spname[$2]=$1; next} {if ($1 ~ ">") $2=spname[$3]; print $0}' infoSP.txt $1 > file.out 

#cleaning
#rm infoSP.txt

# to inform that the file has been corrected

name=${1/fas/fasta}
mv file.out $name
rm $1

echo ""
echo "$1 have been corrected."
echo "The name of the file has been changed for $name"
echo ""

