library(vcfR)
library(adegenet)
library(phrynomics)

vcf<-read.vcfR("filter_linked.vcf",verbose=F)
my_genind <- vcfR2genind(vcf)
pop<-read.table("pop.txt",head=F)
my_genind$pop<-as.factor(pop$V1)
##Calculate tyhe number of clusters
grp <- find.clusters(my_genind, max.n.clust=40)
###Show your new groups based on your original pops
table.value(table(pop(my_genind), grp$grp), col.lab=paste("inf", 1:7))

dapc.my_genind <- dapc(my_genind, var.contrib = TRUE, scale = FALSE, n.pca = 30, n.da = nPop(my_genind) - 1)

##crossvalidation

set.seed(999)
pramx <- xvalDapc(tab(my_genind, NA.method = "mean"), pop(my_genind))

###pca

##Format your data
X <- scaleGen(my_genind, NA.method="mean")
##perfom the PCA
pca1 <- dudi.pca(X,cent=FALSE,scale=FALSE,scannf=FALSE,nf=3)
##Look at the PCAs
barplot(pca1$eig[1:50],main="PCA eigenvalues", col=heat.colors(50))

col <- funky(15)
###Plot the variation
s.class(pca1$li, pop(my_genind),xax=1,yax=3, col=transp(col,.6), axesell=FALSE,cstar=0, cpoint=3, grid=FALSE)
