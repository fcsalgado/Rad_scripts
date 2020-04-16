# clear the R environment
rm(list = ls())
library(tidyverse)
library(PopGenome)

##Load your vcf ##Your vcf must be in a separate folder
data <- readData("vcf/", format = "VCF", include.unknown = TRUE, FAST = TRUE)

##load your popfile
pops <- read.table("popfile.txt", head=T)
##add this value
data<-set.populations(data,split(pops$ind, pops$pop),diploid=TRUE)
##Calculations
# NEUTRALITY STATISTICS 
data <- neutrality.stats(data, FAST=TRUE) 
get.neutrality(data)[[1]] 
data@Tajima.D 
# FST 
data <- F_ST.stats(data, mode="haplotype")
get.F_ST(data)[[1]] 
data@nucleotide.F_ST 
# DIVERSITY
data <- diversity.stats(data)
get.diversity(data) 
data@nuc.diversity.within 
# SFS
data <-detail.stats(data,site.spectrum=TRUE,site.FST=TRUE) 
results <- get.detail(data) 
data@region.stats@minor.allele.freqs

# Concatenate loci
CON <- concatenate.regions(data) 
CON <- detail.stats(CON,site.spectrum=TRUE,site.FST=TRUE) 
results <-get.detail(CON) 
allele_Freqs <- CON@region.stats@minor.allele.freqs[[1]] 
freq.table <- list()
freq.table[[1]] <- table(allele_Freqs) 
sfs <- data.frame(freq.table)

library(ggplot2) 
ggplot(sfs, aes(x=allele_Freqs, y=Freq)) + geom_bar(stat = 'identity')
