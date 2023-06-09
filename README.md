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
This script collect and write in a .tsv file the results from all the runs of *denovo_map.pl* from *StacksExplorer.sh*.
It require as single argument the pathway to the output directory produced by *StacksExplorer.sh* (*stacksExplorer/*).
This .tsv can be used with StacksExplorer_plots.R to plots the results of the different parameter combinations.

Can be used with `gimmeRad2plot.sh ./path/to/stacksExplorer/`.

### StacksExplorer_plots.R
Produce a pdf with a plot of the total number of loci as the number of polymorphic loci in function of the different combination of parameters used with *denovo_map.pl*.
It also produce a pdf with the % of polymorphic loci for each species. In each case, only the *r80* loci (see [Stacks documentation](https://catchenlab.life.illinois.edu/stacks/)) are reported.

The script as to been run in the same directory as the output of *gimmeRad2plot.sh* (*stacksExplorer_rdy2plot.tsv*) and use as single arguement the name of genus (or analysis). It can be run with the following command `Rscript ~/bin/StacksExplorer_plots.R Genus_name`.



