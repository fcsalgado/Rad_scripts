library(boot)
library(tidyverse)
#Import all your best runs in a single folder
bLhood <- list.files(pattern="*.bestlhoods$", recursive=TRUE, full.names=TRUE)
lbLhoods <- lapply(bLhood, read.table, header=TRUE)
est.sim <- do.call(rbind, args=lbLhoods)
#Create a function to use with the package boot
med.i <- function(x, i) mean(x[i])
#Create an empty tibble to fill with the 
results<-tibble(var_name=character(),median=double(),min=double(),max=double())
#do the bootstrap
for(n in names(est.sim)){
	bootstr <- boot(est.sim[,n], statistic=med.i, R=10000)
	b.ci <- boot.ci(bootstr, conf=0.95,type="perc")
	t0 <- b.ci$t0
	ci <- b.ci[[4]][1, tail(seq_len(ncol(b.ci[[4]])), 2)]
	tmp<-tibble(var_name=n,median=t0,min=ci[1],max=ci[2])
	results<-rbind(results,tmp)    
}
