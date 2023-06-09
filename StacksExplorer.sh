#/bin/bash
# StacksExplorer.sh *directory with samples* *popmap file*

### This script launch a set of denovo_map.pl (from Stacks) runs with different parameters to found out the best configuration ###

# Check if the required arguments are provided
if [ $# -ne 2 ]; then
	echo -e "\nYou need to provide the directory containing the sample files (.fq.gz) and the popmap file as arguments.\n" && exit
fi

### setup of the ressources for the script
module load stacks/ # if you use Environment Modules (often the case on cluster)
function exists_in_list() {
    LIST=$1
    DELIMITER=$2
    VALUE=$3
    echo $LIST | tr "$DELIMITER" '\n' | grep -F -q -x "$VALUE"
} # function to check the answer of the user, used somewhere in the script.

### set the different arguments
## The three next lines explain the three parameters
# m = Minimum number of homomorphe reads for a stack to be valid (homomorphe under this treshold are considered secondary reads)
# M = Maximum distance between two stacks to be considered from the same polymorphe locus (distance = number of position with a different nucleotide)
# n = Maximum distance between two locus from differents populations to be considered to be the same locus (distance = number of position with a different nucleotide)

min_m=3 ### Hard coded value, can be modified ###
max_m=5 ### Hard coded value, can be modified ###
min_M=1 ### Hard coded value, can be modified ###
max_M=6 ### Hard coded value, can be modified ###
n_diff=1 ### Hard coded value, can be modified ### Distance from M, for exampple : if n_diff=1 and M=4 then n will take the value 3,4 and 5 (or 4 and 5 if you only test for value of n equal or superior to M) 

samples=${1} # Directory with the individuals to analyzes
popmap=${2} # File of population mapping -> per line: name of the sampling\tpopulation belonging
cpus=10 ### Hard coded value, can be modified ### number of cpus per run
mem=40 ### Hard coded value, can be modified ### number of GB of ram per run
part="fast" ### Hard coded value, can be modified ### if run less than 24h = fast; if run longer than 24h = long

### check if the script is correctly set :
nb_m=$(expr $max_m - $(expr $min_m - 1)) # number of different values that m will take
nb_M=$(expr $max_M - $(expr $min_M - 1)) # number of different values that M will take
nb_n=$(expr 1 + $n_diff) # number of different values that n will take
nb_run=$(expr $nb_m \* $nb_M \* $nb_n) # total number of run with the current configuration

echo -e "\nPlease take a moment to check that this script is correctly set up :
Parameters for slurm (per run): $cpus cpus, $mem GB mem, partition set as $part
Range of values explored : m {${min_m}:${max_m}}, M {${min_M}:${max_M}}, n will be distant from $n_diff of M (only superior to M in this version of of the script).
With these values, we're in for $nb_run runs ! Are you sure you want this ? y or n ?\n"
read -p '' tmp # Ask the user if the setup is okay

okay_answer="y yes Y YES okay yup oui o OUI O"

# if the parameters and number of runs are okay, proceed, else exit
if exists_in_list "$okay_answer" " " "$tmp";then
	echo -e "\nOkay then, let's go for the show.\n"
else
	echo -e "\nThat's what I thought, please correct the value of parameters directly in the script (look for -Hard coded value-, then try again.\n"
	exit
fi

# create a stacksExplorer repertory if it doesn't already exist
if [[ ! -d "stacksExplorer" ]];then
	mkdir stacksExplorer
fi

### launch the different analysis
for m_int in $(seq ${min_m} ${max_m});do # for each value of m
	for M_int in $(seq ${min_M} ${max_M});do # for each value of M
		# to set the min max value of n, if n_diff = 0 then n = M
		#min_n=$(expr $M_int - $n_diff) # You can comment/uncomment this line, depending if you want to test for value of n inferior to M (or not)
		max_n=$(expr $M_int + $n_diff)
		for n_int in $(seq ${M_int} ${max_n});do # for each value of n
			new_dir="stacksExplorer/stacksExplorer_m${m_int}_M${M_int}_n${n_int}" # delete the directory for this configuration, if it already exist, else create it
			if [[ -d "$new_dir" ]];then
				rm -r $new_dir
				mkdir stacksExplorer/stacksExplorer_m${m_int}_M${M_int}_n${n_int}
			else
				mkdir stacksExplorer/stacksExplorer_m${m_int}_M${M_int}_n${n_int}
			fi
			echo "Running the m${m_int}_M${M_int}_n${n_int} configuration."
			sbatch --mem ${mem}GB --cpus-per-task $cpus -p $part --wrap="time denovo_map.pl -T 10 -M $M_int -m $m_int -n $n_int -o ./stacksExplorer/stacksExplorer_m${m_int}_M${M_int}_n${n_int}/ --samples $samples --popmap $popmap --min-samples-per-pop 0.80 && rm stacksExplorer/stacksExplorer_m${m_int}_M${M_int}_n${n_int}/*bam && rm stacksExplorer/stacksExplorer_m${m_int}_M${M_int}_n${n_int}/*tags*"
			done
	done
done

echo -e "\nThe runs have been launch.\nWhen done, the next soft to run will be gimmeRad2plot.sh\n"
