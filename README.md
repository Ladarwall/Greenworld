# Greenworld
Repository of the article *Rapid establishment of species barriers in plants
compared to animals*

## Scripts used for the greenzone article

This repository contain different homemade scripts used in the workflow of the supplementary of the greenzone article.

### List of the scripts :

#### To explore Stacks parameters
- StacksExplorer.sh 
- GimmeRad2plot.sh
- StacksExplorer_plots.R

# list of R packages TODO

### StacksExplore.sh
This script can be used to launch a set of *denovo_map.pl* runs (from Stacks) with different parameters.
This step is usefull to explore suitable parameter configurations for *denovo_map.pl*.

The script require two arguments. The pathway to a directory containing the sample files (.fastq.gz) and the pathway to the popmap file.
The popmap file should include a list of the samples to be used with one ID and species per line, separated by a tab (an example is provided in this repository).

This script can be run with the following command : `StacksExplorer.sh ./path/to/SamplesDirectory ./path/to/popmapFile`

Once all the runs have been completed, the next script to use is *gimmeRad2plot.sh*.

### gimmeRad2plot.sh
This script collect and write in a .tsv file the results from all the run of *denovo_map.pl* from *StacksExplorer.sh*.
It require as single argument the pathway to the output directory produced by *StacksExplorer.sh* (*stacksExplorer_rdy2plot.tsv*).
This .tsv can be used with StacksExplorer_plots.R to plots the results of the different parameter combinations.

Can be used with `gimmeRad2plot.sh ./path/to/stacksExplorer_rdy2plot.tsv` or `gimmeRad2plot.sh` if runned from the same directory as *stacksExplorer_rdy2plot.tsv*.

### StacksExplorer_plots.R

