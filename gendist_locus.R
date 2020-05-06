library(mmod)
library(adegenet)
library(pegas)
distances<-function(fasta){
dna = read.dna(fasta,format='fasta')
nom<-labels(dna)
s<-strsplit(nom, "\\_")
cate<-sapply(s, '[[', 2)
east<-c("Acre","Baños","Buenavista","Campinas","ElPangui","Gualaquiza","Guaviare","Jaen","Lencois","Leticia","Misahualli","Moyobamba","Villavicencio","PraiadoForte","Sucua","Tarapoto")
dry<-c("Alamor","Chiclayo","Piura","SantoDomingo","Vilcabamba","Lima")
west<-c("BahiaMalaga","Boquia","Cali","Cartagena","Cucuta","Galapagos","Ibague","Medellin","Palmira","Quito","SanAndres","Tolu")
pops<-NULL
for(i in cate){
  if (i %in% west == TRUE){
    pops<-c(pops, "west")
  } else if (i %in% dry == TRUE){
    pops<-c(pops, "dry")
  } else if (i %in% east == TRUE){
    pops<-c(pops, "east")
  }
}

my_gen<-as.genind.DNAbin(dna,pops)
genepop<-genind2genpop(my_gen)
nei<-nei.dist(genepop)
print(fasta)
return(nei)
}

locus<-dir(pattern="locus*")

results<-lapply(as.list(locus),distances)

result_dist<-lapply(results, as.matrix)
