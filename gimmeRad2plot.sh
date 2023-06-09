#!/bin/bash
# gimmeRad2plot.sh *stacksExplorer directory*

### Used after the script StacksExplorer.sh to produce a file ready to be plot with StacksExplorer_plots.R 
# it doesn't take any argument, and output a dataframe (stacksExplorer_rdy2plot.csv) with the m, M, n, r80 (nb of loci present in at least 80% of individuals of a pop), the number of polymorphic loci and the r80 polymorphic loci (% of loci polymorphe per population).


stacksExplorer=${1:-stacksExplorer}    

# check if in the right place
[[ ! -d $stacksExplorer ]] && echo -e "\nNo $stacksExplorer directory found.\nDid you run the StacksExplorer.sh ?\nAre you in the parent directory of the $stacksExplorer ?\n" && exit

# check the number of fasta files produced (error if there is missing file)
nb_comb=$(find $stacksExplorer/ -maxdepth 1 -wholename '*stacksExplorer_m*' | wc -l)
nb_done=$(find $stacksExplorer/ -wholename '*/catalog.fa.gz' | wc -l)

# informe the user if there is missing files
if [ $nb_comb != $nb_done ];then
	echo -e "\nThe number of catalog.fa.gz doesn't seem to match the number of combinaisons tested.
Are you sure that everything went well with the denono_map.pl ?\n"
#	exit
fi

# get each populations and produce the corresponding headers
pop_file=$(find $stacksExplorer -wholename '*populations.log' | head -1) # to have a populations.log file, any does the job.
sp_list=$(grep "defaultgrp" $pop_file)
sp_list=${sp_list##*: }
sp_list=${sp_list// /_} # to change space between genus and species if the genus is provided
sp_list=$(echo $sp_list | sed 's/,_/\t/g') # to modified what is between species to tab
nb_sp=$(echo $sp_list | wc -w)
# create the dataframe to plot
echo -e "m\tM\tn\tr80\tpoly_loci\t$sp_list" > $stacksExplorer/stacksExplorer_rdy2plot.tsv

nb_dir=$(find ./$stacksExplorer -wholename '*/catalog.fa.gz' | wc -l)
echo -e "\nThere is $nb_dir analyses to collect.\n"

cnt=1
for i in $(find ./$stacksExplorer -wholename '*/catalog.fa.gz');do # catalog.fa.gz is only produce if denovo_map.pl worked fine
	comb=${i%/*} # get rid of the "catalog.fa.gz" in the i variable
	# nb of loci present in at least 80% of the individual of the population 
	summary_path="${comb}/populations.sumstats_summary.tsv"
	start_line=$(expr $(expr $(cat $summary_path | wc -l) / 2) + 2) #line from which we start the loop, because there is two dataframe in one in this file
	comb2=${comb##*/}
	m_value=$(echo $comb2 | cut -d'_' -f2) && m_value=${m_value/m/}
	M_value=$(echo $comb2 | cut -d'_' -f3) && M_value=${M_value/M/}
	n_value=$(echo $comb2 | cut -d'_' -f4) && n_value=${n_value/n/}
	r80=$(zcat $i  | grep ">" | wc -l)
	# nb of polymorphic loci in the final conscencus file
	popu_log_distr="${comb}/populations.log.distribs" # file containing the distribution of nb of SNP per loci
	poly_loci_tot=$(grep -A5000 "BEGIN snps_per_loc_postfilters" $popu_log_distr |  sed '/^END snps_per_loc_postfilters$/,$d' | tail -n +5 | cut -d$'\t' -f 2 | awk '{Total=Total+$1} END{print Total}') # to sum the number of loci with at least one SNP (aka polymorphic loci)
	if [ -z "$poly_loci_tot" ];then # if the variable is empty, set it to "0", otherwise the script StacksExplorer_plotteur.R bugs.
		poly_loci_tot=0
	fi
		
	line_toadd="${m_value}\t${M_value}\t${n_value}\t${r80}\t${poly_loci_tot}"
	for u in $(seq $nb_sp);do # to collect value for each populations, it collect the value of the column % of polymo loci for each line (population) starting at the line of the first population (there is 2 dataframes in one file so the loop need to start at the right line)
		start_line=$(($start_line + 1))
		r80_loci_tmp=$(sed -n ${start_line}p $summary_path | cut -d$'\t' -f 6)
		line_toadd="${line_toadd}\t$r80_loci_tmp"
	done
	echo -e "$line_toadd" >> $stacksExplorer/stacksExplorer_rdy2plot.tsv
	echo -e "\e[1A\e[KDone $cnt on ${nb_dir}." # weird part to overwrite previous echo
	cnt=$(($cnt + 1))
done
echo -e "\nThe file stacksExplorer_rdy2plot.tsv has been produce in the $stacksExplorer directory.\nThe next script to use will be StacksExplorer_plots.R\n" 
