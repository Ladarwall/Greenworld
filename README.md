# Rapid establishment of species barriers in plants compared to animals
Repository of the article *Rapid establishment of species barriers in plants compared to animals, Monnet et al, unpublished*.
Includes five scripts from the [workflow of this article](https://github.com/Ladarwall/Greenworld/blob/main/workflow_diagram.pdf), that can all be launched from a terminal.

## List of software
- [Stacks](https://catchenlab.life.illinois.edu/stacks/)
## List of R package
- [data.table](https://rdrr.io/cran/data.table/)
- [ggthemes](https://cran.r-project.org/web/packages/ggthemes/index.html)
- [ggbreak](https://github.com/YuLab-SMU/ggbreak)
- [ggplot2](https://ggplot2.tidyverse.org/)


## To explore different combinations of parameters for **Stacks**
The three following scripts can be used to explore different combinations of parameters for the script *denovo_map.pl* from **Stacks**.
The purpose is to find a good enough combination of parameters to optimize the number of polymorphic loci (see [Lost in parameter space: a road map for stacks](https://doi.org/10.1111/2041-210X.12775)).

### StacksExplore.sh
This script launch a set of *denovo_map.pl* runs (**Stacks**) with different parameters.

It require two arguments: the pathway to a directory containing the sample files (fastq format) and the pathway to the popmap file.
The popmap file should include a list of the samples to be used with one ID and species per line, separated by a tab (an [example](https://github.com/Ladarwall/Greenworld/blob/main/popmap_file_example.txt) is provided in this repository).

Can be run with the following command : `StacksExplorer.sh ./path/to/SamplesDirectory ./path/to/popmapFile`

Once all the runs have been completed, the next script to use is *gimmeRad2plot.sh*.

### gimmeRad2plot.sh
This script collect and write in a .tsv file the results from all the runs of *denovo_map.pl* from *StacksExplorer.sh*.
It require as single argument the pathway to the output directory produced by *StacksExplorer.sh* (*stacksExplorer/*).

Can be used with the command `gimmeRad2plot.sh ./path/to/stacksExplorer/`.

This .tsv can be used with StacksExplorer_plots.R to plots the results of the different combinations of parameters.

### StacksExplorer_plots.R
Produces a pdf with a graph of the total number of loci as well as the number of polymorphic loci as a function of the different combinations of parameters used with *denovo_map.pl*.
It also produces a pdf with the % of polymorphic loci for each species. In each cases, only the *r80* loci (see [Stacks documentation](https://catchenlab.life.illinois.edu/stacks/)) are reported.

The script as to been run in the same directory as the output of *gimmeRad2plot.sh* (*stacksExplorer_rdy2plot.tsv*) and use as single argument the genus name (or analysis name). It can be run with the following command `Rscript ~/path/to/StacksExplorer_plots.R Genus_name`.


## To modify fasta files
### patchOneLine.sh
This script loops over a fasta file to ensure that each sequences is in single-line format (with no line breaks after a certain number of bases).

Can be used with the command `patchOneLine.sh ./path/to/fasta`

### patchSPname.sh
The fasta file produce by this pipeline lack the correct species name in the sequence headers, this can be corrected with this script.

Can be used with the command `patchSPname.sh ./path/to/fasta ./path/to/SraRunTable.txt`.

The SraRunTable.txt is a metadata file and can be obtain from the NCBI page [SRA Run Selector](https://www-ncbi-nlm-nih-gov.inee.bib.cnrs.fr/Traces/study/). You can also produce a similar metadata with a file containing two column named "Organism" and "Sample_Name" and separated by a tab.
