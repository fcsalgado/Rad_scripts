####wrote por Angela P Fuentes

#Transform your VCF to genepop

### create an strata file and remove sample with less that 4 samples
#extract the statistics using bash as follow
sed 's/_/ /g' samples.txt | cut -d " " -f 1 | sort | uniq -c > samples_per_pop.txt

sed 's/_/ /g' samples.txt | cut -d " " -f 1 > file1.txt
paste samples.txt file1.txt > popfile.txt

##remove the individuals with vcftools

vcftools --vcf 090_filtered_without_outgroups.vcf --remove remove.txt --recode --recode-INFO-all --out 095_popanalysis

###Open R and change the format
library(radiator)

genomic_converter(data="095_popanalysis.vcf", strata = "popfile.txt", output = c("genind", "genepop", "structure"), filename = "095_filtered", verbose = TRUE)


# Clean environment space.
rm(list=ls())

# Set working directory.
#setwd("/home/user/Desktop/Tutorial")

### Load libraries needed.
#library("gplots")
library("vegan")
library("genepopedit")

### Load genotype data.
file_path_genotypes <- "/home/fsalgado/libelulas/polythore_genepop2.gen"

# For dataset of <15,000 loci, use read.table().
# Use data.table() to load larger datasets.
GenePopData <- read.table(file_path_genotypes, sep="\t",quote="", stringsAsFactors=FALSE)

# Return population names
PopNames <- genepop_detective(GenePopData, variable="Pops")
PopNames

# Return population counts
PopCounts <- genepop_detective(GenePopData, variable="PopNum")
PopCounts

# Return sample IDs
SampleIDs <- genepop_detective(GenePopData, variable="Inds")
SampleIDs
length(SampleIDs)

#### Basic statistics.
library("adegenet")
library("pegas")
library("hierfstat")

# Read in genotype data in "genpop" file format.
x <- read.genepop(file_path_genotypes, ncode=3, quiet=FALSE)

# Obtain summary statistics with adegenet().
# Such as: allelic frequencies, observed heterozygosities, genetic diversities per locus and population,
# mean observed heterozygosities, mean gene diversities within population Hs, Gene diversities overall Ht and corrected Htp, and Dst, Dstp.
# Fst and Fstp as well as Fis following Nei (1987) per locus and overall loci.
basicStats <- basic.stats(x)
basicStats

# Save results in a txt file.
write.table(basicStats$perloc, file="Basic_stats_per_locus_scallops.txt",
            sep="\t", row.names=FALSE, col.names=TRUE, quote=FALSE)

# Other way to calculate summary statistics.
SumStats <- summary(x)
SumStats
names(SumStats)

# Make a barplot to assses whether Ho and He differ per locus.
barplot(SumStats$Hexp-SumStats$Hobs, main="Heterozygosity: expected-observed",
        ylab="Hexp - Hobs")

# Global Fst.
fstat(x, fstonly = TRUE)

# Fst by locus. Fst (pop/total), Fit (Ind/total), and Fis (ind/pop).
Fst(as.loci(x))

F_stats <- basic.stats(x, diploid = TRUE, digits = 2)
F_stats
names(F_stats)
save(list=ls(), file="basic_statistics.rda")

### Calculate Pairwise FST
pwFST <- genet.dist(x, method = "WC84")  # Be patient, this step takes a few min
pwFST_mt <- as.matrix(pwFST)

class(pwFST_mt)
row.names(pwFST_mt)
colnames(pwFST_mt)

# Clean population names up.
row.names(pwFST_mt) <-gsub("_.*","", row.names(pwFST_mt))
colnames(pwFST_mt) <-gsub("_.*","", colnames(pwFST_mt))

row.names(pwFST_mt)
colnames(pwFST_mt)

# Verify columns and rows of the matrix are the same.
all.equal(row.names(pwFST_mt), colnames(pwFST_mt))


### Generate heatmap to visualize the pair-wise Fst matrix.

# Load libraries.
library("ggplot2")
library("reshape")

# Convert the distance matrix to data.frame.
pwFST_dist <- melt(pwFST_mt)
head(pwFST_dist)

# Set the order of rows/columns to follow geographic location.
pwFST_dist$X1 <- factor(pwFST_dist$X1, levels =c("pr","m","cv","spnov","g","d","o","p","n"))
pwFST_dist$X2 <- factor(pwFST_dist$X2, levels =c("pr","m","cv","spnov","g","d","o","p","n"))

# Set up heatmap plot
pdf("Fst_heatmap.pdf")
heatmap_plot <- ggplot(pwFST_dist, aes(X1, X2)) + geom_tile(aes(fill=value)) +
  scale_fill_gradient(name = "Fst",low = "#FFFFFF",high = "#012345")
heatmap_plot
dev.off()

###AMOVA
library(poppr)
x$pop<-factor(gsub("_.*","", x$pop))
strat<-cbind(SampleIDs,as.character(x$pop))
estrata<-read.csv("estrata.csv",head=T)
strata(x) <- data.frame(estrata)
gen.dist <- dist(x = x, method = "euclidean", diag=TRUE, upper=TRUE)
AMOVA <- poppr.amova(x, hier = ~reg/pop, dist = gen.dist, squared = TRUE, within = FALSE, quiet = FALSE)
###DAPC
##according to variation select the bestk, keep all the PCs that you want
grp <- find.clusters(x, max.n.clust=40)
###Check if your categorization is consistent with your apriori information
table(pop(x), grp$grp)
table.value(table(pop(x), grp$grp), col.lab=paste("inf", 1:7),row.lab=levels(x$pop))
###perfom the dapc based in your new grouping
dapc1 <- dapc(x, grp$grp)
scatter(dapc1, scree.da=FALSE, bg="white", pch=20,  cell=0, cstar=0, solid=.4,cex=3,clab=0, leg=TRUE)
###perfom the dapc based in your original grouping
dapc1 <- dapc(x, x$pop)
scatter(dapc1, scree.da=FALSE, bg="white", pch=20,  cell=0, cstar=0, solid=.4,cex=3,clab=0, leg=TRUE)
scatter(dapc1,1,1, bg="white",scree.da=FALSE, legend=TRUE, solid=.4)
