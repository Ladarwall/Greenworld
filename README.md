# Greenworld
Repository of the article *Rapid establishment of species barriers in plants
compared to animals*. 

## List of software
- [Stacks](https://catchenlab.life.illinois.edu/stacks/)
## List of R package
- [data.table](https://rdrr.io/cran/data.table/)
- [ggthemes](https://cran.r-project.org/web/packages/ggthemes/index.html)
- [ggbreak](https://github.com/YuLab-SMU/ggbreak)
- [ggplot2](https://ggplot2.tidyverse.org/)


## Explore different combinations of parameters for **Stacks**
The three following scripts can be used to explore different combinations of parameters for the script *denovo_map.pl* from **Stacks**.
The purpose is to find a good enough combination of parameters to optimize the number of polymorphic loci.

### StacksExplore.sh
This script can be used to launch a set of *denovo_map.pl* runs (from **Stacks**) with different parameters.
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
It also produce a pdf with the % of polymorphic loci for each species. In each cases, only the *r80* loci (see [Stacks documentation](https://catchenlab.life.illinois.edu/stacks/)) are reported.

The script as to been run in the same directory as the output of *gimmeRad2plot.sh* (*stacksExplorer_rdy2plot.tsv*) and use as single arguement the name of genus (or analysis). It can be run with the following command `Rscript ~/path/to/StacksExplorer_plots.R Genus_name`.


## Modify fasta files
### patchOneLine.sh
This script loops over a fasta file to ensure that each sequence is in single-line format (with no line breaks after a certain number of bases).
It can be run with the following command `patchOneLine.sh ./path/to/fasta`

### patchSPname.sh
The fasta file produce by this pipeline lack the correct species name in the sequence headers. 
To correct this, you can use this command `patchSPname.sh ./path/to/fasta ./path/to/SraRunTable.txt`.
The SraRunTable.txt is the metadata file and can be obtain from the NCBI page [SRA Run Selector](https://www-ncbi-nlm-nih-gov.inee.bib.cnrs.fr/Traces/study/). You can also produce a similar metadata with a file containing two column named "Organism" and "Sample_Name" and separated by a tab.
