# Load required libraries
library(boot)
library(tidyverse)

# Import all your best runs in a single folder
bLhood <- list.files(pattern="*.bestlhoods$", recursive=TRUE, full.names=TRUE)
lbLhoods <- lapply(bLhood, read.table, header=TRUE)
est.sim <- do.call(rbind, args=lbLhoods)

# Create a function to use with the package boot
med.i <- function(x, i) mean(x[i])

# Create an empty tibble to fill with the results
results <- tibble(var_name=character(), median=double(), min=double(), max=double())

# Do the bootstrap
for(n in names(est.sim)){
  # Perform bootstrap on each column of est.sim
  bootstr <- boot(est.sim[,n], statistic=med.i, R=10000)
  
  # Compute confidence intervals
  b.ci <- boot.ci(bootstr, conf=0.95, type="perc")
  t0 <- b.ci$t0
  ci <- b.ci[[4]][1, tail(seq_len(ncol(b.ci[[4]])), 2)]
  
  # Create a tibble for the current variable
  tmp <- tibble(var_name=n, median=t0, min=ci[1], max=ci[2])
  
  # Append the results to the overall tibble
  results <- rbind(results, tmp)
}
