rm(list=ls())
### to plot the dataframe from gogoStacksExplorer.sh and gimmeRad2plot.sh (plot of r80 of rad data)
# One variable is hard coded (The name of the genus), see later in the script
library(data.table)
library(ggthemes)
library(ggbreak)
library(ggplot2)

# A function factory for getting integer axis values.
integer_breaks <- function(n = 5, ...) {
  fxn <- function(x) {
    breaks <- floor(pretty(x, n, ...))
    names(breaks) <- attr(breaks, "labels")
    breaks
  }
  return(fxn)
}

genus = "" # <======= CHANGE GENUS NAME HERE
plotme = fread("stacksExplorer_rdy2plot.tsv",header = T,sep = '\t')

# to collect the name of each species
species_names = names(plotme)[-(1:5)]

# to add a column to plot not the absolute value of n but the relative value from M
n_diff=c()
for (row in 1:nrow(plotme)) {
  M_tmp = as.integer(plotme[row,"M"])
  n_tmp = as.integer(plotme[row,"n"])
  diff_tmp = n_tmp - M_tmp
  n_diff = append(n_diff,diff_tmp)
  }
plotme = cbind(plotme,n_diff)

set_colors = c("#3fa261","#f8333c","#fcab10","#2b9eb3","#7712ba")

awesomePlot = ggplot(plotme,aes(M, r80)) + geom_line(aes(colour=factor(m),linetype=factor(n_diff)),size=1)+ 
  ggtitle(paste("r80 in function of m,M and n (",genus," data)",sep="")) + ylim(min(plotme$poly_loci)  * 0.975, max(plotme$r80) * 1.025) +
  labs(colour="m",linetype="n distance") + theme_light()+ scale_x_continuous(breaks = integer_breaks())+
  scale_color_manual(values = set_colors) + labs(caption = "r80 = loci found in at least 80% of the population
  m = Minimum stack depth / minimum depth of coverage
  M = Distance allowed between stacks
  n = Distance allowed between catalog loci (express as a distance from M)") +
  scale_y_break(c(max(plotme$poly_loci)  * 1.025, min(plotme$r80) * 0.975), scale = 0.5) +
  geom_line(aes(y=poly_loci,colour=factor(m),linetype=factor(n_diff)),size=1) + ylab("Number of loci") +
  geom_label( aes(x=max(plotme$M) ,y=min(plotme$poly_loci)  * 0.975,hjust=1,vjust=0,label="Polymorphic loci"),size = 5,show.legend =F,stat = "unique") +
  geom_label( aes(x=max(plotme$M) ,y=max(plotme$r80)  * 0.975,hjust=1,vjust=0,label="Total loci"),size = 5,show.legend =F,stat = "unique")

awesomePlot
name_pdf = paste('r80_',genus,'_plot.pdf',sep='')
pdf(name_pdf,width = 19,height = 10,onefile=F)
print(awesomePlot)
dev.off()

# to create specific ggplot (one per species) with % of polymorphe sites
for (species in species_names){
  print(species)
  tmp_plot = ggplot(plotme,aes_string("M",species)) +  geom_line(aes(colour=factor(m),linetype=factor(n_diff)),size=1)+
    ggtitle(paste("% of r80 polymo loci in function of m,M and n (",species," data)",sep="")) +
    labs(colour="m",shape="n distance",y = "% r80 poly loci") + theme_light()+ scale_x_continuous(breaks = integer_breaks())+
    scale_color_manual(values = set_colors) + labs(caption = "% r80 poly loci = Share of porlymorphic loci in the loci present in at least 80% of the population.
  m = Minimum stack depth / minimum depth of coverage
  M = Distance allowed between stacks
  n = Distance allowed between catalog loci (express as a distance from M)") 
  name_pdf = paste(species,"Plot.pdf",sep="")
  pdf(name_pdf,width = 12,height = 6)
  print(tmp_plot)
  dev.off()
}

