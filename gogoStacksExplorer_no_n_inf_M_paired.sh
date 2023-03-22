#/bin/bash
# gogoStacksExplorer_no_n_inf_M.sh *directory with samples* *popmap file*

### to launch a bunch of denovo_map.pl runs (using slurm) with different parameters to found out a good enough configuration ###

## Some variables are hard coded and need to be modified directly in the script.

# modified for paired end data, to use single end data -> remove --paired and --rm_pcr_duplicates argument from the denovo_map.pl command line
# fastq must be in .1.fq.gz and .2.fq.gz
# popmap id must have .1 an .2

### setup of the ressources for the script
module load stacks/
function exists_in_list() {
    LIST=$1
    DELIMITER=$2
    VALUE=$3
    echo $LIST | tr "$DELIMITER" '\n' | grep -F -q -x "$VALUE"
} # function to check the answer of the user, used somewhere in the script.

### set the different arguments <----------------- CAN BE MODIFIED
# m = minimum nb of homomorphe reads for a stack to be valid (if not -> secondary reads)
# M = maximum distance between two stacks to be considered from the same polymorphe locus
# n = maximum distance between two locus from differents populations to be considered to be the same locus
# For more details, see Stacks documentation.
min_m=3
max_m=5
min_M=1
max_M=6
n_diff=1 # Distance from M, if n_diff=1 and M=4 then n will take the value 3,4 and 5.

samples=${1} # directory with the individuals to analyzes
popmap=${2} # file of population map, per line: name of the sampling \t population belonging

# Arguments for slurm <-------------- CAN BE MODIFIED
cpus=10 # number of cpus per run 
mem=40 # number of GB of ram per run 
part="long" # if run less than 24h = fast; if run longer than 24h = long

### check if the script is correctly set :
nb_m=$(expr $max_m - $(expr $min_m - 1)) # number of different values that m will take
nb_M=$(expr $max_M - $(expr $min_M - 1)) # number of different values that M will take
nb_n=$(expr 1 + $n_diff) # number of different values that n will take
nb_run=$(expr $nb_m \* $nb_M \* $nb_n) # total number of run with the current configuration

echo -e "\nPlease take a moment to check that this script is correctly set up :
Parameters for slurm (per run): $cpus cpus, $mem GB mem, partition set as $part
Range of values explored : m {${min_m}:${max_m}}, M {${min_M}:${max_M}}, n will be distant from $n_diff of M (only superior to M in this version of gogoStackExplorer).
With these values, we're in for $nb_run runs ! Are you sure you want this ? y or n ?\n"
read -p '' tmp # Ask the user if the setup is okay

okay_answer="y yes Y YES okay yup oui o OUI O"

# if the parameters, number of runs is okay, proceed, else exit
if exists_in_list "$okay_answer" " " "$tmp";then
	echo -e "\nOkay then, let's go for the show.\n"
else
	echo -e "\nThat's what I thought, please correct the value of parameters directly in the script then try again.\n"
	exit
fi
# create a stacksExplorer repertory if doesn't already exist
if [[ ! -d "stacksExplorer" ]];then
	mkdir stacksExplorer
fi
### launch the different analysis
for m_int in $(seq ${min_m} ${max_m});do # for each value of m
	for M_int in $(seq ${min_M} ${max_M});do # for each value of M
		# to set the min max value of n, if n_diff = 0 then n = M
		#min_n=$(expr $M_int - $n_diff)
		max_n=$(expr $M_int + $n_diff)
		for n_int in $(seq ${M_int} ${max_n});do # for each value of n
			new_dir="stacksExplorer/stacksExplorer_m${m_int}_M${M_int}_n${n_int}" # delete the directory for this configuration, if it already exist, else creat it
			if [[ -d "$new_dir" ]];then
				rm -r $new_dir
				mkdir stacksExplorer/stacksExplorer_m${m_int}_M${M_int}_n${n_int}
			else
				mkdir stacksExplorer/stacksExplorer_m${m_int}_M${M_int}_n${n_int}
			fi
			sbatch --mem ${mem}GB --cpus-per-task $cpus -p $part --wrap="time denovo_map.pl -T 10 -M $M_int -m $m_int -n $n_int -o ./stacksExplorer/stacksExplorer_m${m_int}_M${M_int}_n${n_int}/ --samples $samples --popmap $popmap --min-samples-per-pop 0.80 --rm-pcr-duplicates --paired
 && rm stacksExplorer/stacksExplorer_m${m_int}_M${M_int}_n${n_int}/*bam && rm stacksExplorer/stacksExplorer_m${m_int}_M${M_int}_n${n_int}/*tags*"
			done
	done
done

echo -e "\nThe runs have been launch.\nWhen done, the next soft to run will be gimmeRad2plot.sh\n"

