# clear the R environment
rm(list = ls())
library(tidyverse)
library(PopGenome)

###To calculate the total length of the loci, use the script size_loci.sh

##Load your vcf ##Your vcf must be in a separate folder
data <- readData("vcf/", format = "VCF", include.unknown = TRUE, FAST = TRUE)

##load your popfile
pops <- read.table("popfile.txt", head=T)
##add this value
##number of nSites
n.snps<-data@n.biallelic.sites + data@n.polyallelic.sites
##popassign
populations<-split(as.character(pops$ind), pops$pop)
data<-set.populations(data,populations,diploid=TRUE)
##Calculations
# NEUTRALITY STATISTICS 
data <- neutrality.stats(data, FAST=TRUE) 
get.neutrality(data)[[1]] 
data@Tajima.D 
# FST 
data <- F_ST.stats(data)
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

nd<-data@nuc.diversity.within/size
pops <- levels(pops$pop)
colnames(nd) <- paste0(pops, "_pi")

colnames(tajima) <- paste0(pops, "_tajima")

w<-data@theta_Watterson/size
colnames(w) <- paste0(pops, "_w")

###Calculations by sites

data <- diversity.stats(data, pi = TRUE)
data_nuc_div <- t(data@region.stats@nuc.diversity.within[[1]])
nd_site<-nd_site<-as.data.frame(t(apply(data_nuc_div,2,mean)))
colnames(nd_site) <- paste0(pops, "_pi")




# Concatenate loci
CON <- concatenate.regions(data) 
CON <- detail.stats(CON,site.spectrum=TRUE,site.FST=TRUE) 
results <-get.detail(CON) 
allele_Freqs <- CON@region.stats@minor.allele.freqs[[1]] 
freq.table <- list()
freq.table[[1]] <- table(allele_Freqs) 
sfs <- data.frame(freq.table)
sfs<-sfs[-1,]##Remove missing data
library(ggplot2) 
ggplot(sfs, aes(x=allele_Freqs, y=Freq)) + geom_bar(stat = 'identity')
