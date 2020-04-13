library(vcfR)
library(adegenet)
library(phrynomics)

vcf<-read.vcfR("random_vcf.vcf",verbose=F)
my_genind <- vcfR2genind(vcf)
#pop<-read.table("pop.txt",head=F)
d<-t(as.data.frame(strsplit(nom, "\\_")))
pop<-as.vector(d[,2])
my_genind$pop<-as.factor(pop)
##Calculate tyhe number of clusters
grp <- find.clusters(my_genind, max.n.clust=40)
###Show your new groups based on your original pops
table.value(table(pop(my_genind), grp$grp), col.lab=paste("inf", 1:7))

##DAPC
dapc.my_genind <- dapc(my_genind, var.contrib = TRUE, scale = FALSE, n.pca = 30, n.da = nPop(my_genind) - 1)

pdf("DAPC.pdf", width = 20, height = 27, family = "Helvetica")

scatter(dapc.my_genind, col=c("#68af57","#fb6ea0","#00cec3"))

##crossvalidation

set.seed(999)
pramx <- xvalDapc(tab(my_genind, NA.method = "mean"), pop(my_genind))

scatter(pramx$DAPC,cex = 2, legend = TRUE,
clabel = FALSE, posi.leg = "bottomleft", col=c("#00cec3","#68af57","#fb6ea0"),
posi.pca = "topleft", cleg = 0.75, xax = 1, yax = 2, inset.solid = 1)

###pca

X <- scaleGen(my_genind, NA.method="mean")

pca1 <- dudi.pca(X,cent=FALSE,scale=FALSE,scannf=FALSE,nf=3)

barplot(pca1$eig[1:50],main="PCA eigenvalues", col=heat.colors(50))

col <- funky(15)

##Plot PCA

s.class(pca1$li, pop(my_genind),xax=1,yax=2, col=c("#68af57","#fb6ea0","#00cec3"), axesell=FALSE,cstar=0, cpoint=3, grid=FALSE)

#1east="#68af57"
#2west="#fb6ea0"
#3dry="#00cec3"

pdf("DAPC_filtered.pdf", width = 20, height = 27, family = "Helvetica")

scatter(dapc.my_genind, col=c("#68af57","#fb6ea0","#00cec3"))
