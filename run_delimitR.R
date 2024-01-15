# R Script for delimitR Analysis

# Note: Ensure that the required R packages (delimitR) are installed.

# Load necessary libraries
library(delimitR)

# Define input parameters
observedtree <- c('((1,(3,2)),(4,0));','((3,2),(1,(4,0)));','(1,((3,2),(4,0)));')
traitsfile <- 'traits.txt'
observedSFS <- 'gasteracantha_reduced_MSFS'
migmatrix <- matrix(c(FALSE, TRUE, FALSE,TRUE,TRUE,
                    TRUE, FALSE, TRUE,FALSE,FALSE,
                    FALSE, TRUE, FALSE,FALSE,FALSE,
                    TRUE, FALSE, FALSE,FALSE,FALSE,
                    TRUE, FALSE, FALSE,FALSE,FALSE),
                    nrow = 5, ncol = 5, byrow = TRUE)
divwgeneflow <- FALSE
seccontact <- TRUE
maxedges <- 3
obsspecies<- 5
obssamplesize <- c(10,10,10,10,10)
obssnps <- 500
obsprefix <- 'gasteracantha_five'
obspopsizeprior <- list(c(1000,100000),c(1000,100000),c(1000,10000),c(1000,10000),c(1000,10000))
obsdivtimeprior <- list(c(300000,1000000),c(300000,1000000),c(1000000,5000000),c(1000000,7000000))
myrules <- c('Tdiv4$>Tdiv3$','Tdiv3$>Tdiv2$','Tdiv3$>Tdiv1$','Tdiv2$>Tdiv1$')
obsmigrateprior <- list(c(0.000005,0.000025))
nclasses <- 5

# Create the models
setup_fsc2(tree=observedtree,
           nspec=obsspecies,
           samplesizes=obssamplesize,
           nsnps=obssnps,
           prefix=obsprefix,
           migmatrix=migmatrix,
           popsizeprior=obspopsizeprior,
           divtimeprior=obsdivtimeprior,
           migrateprior=obsmigrateprior,
           secondarycontact= seccontact,
           divwgeneflow= divwgeneflow,
           maxmigrations = maxedges,
           myrules=myrules)

#define function to run delimitR in parallel

parallel_fsc <- function(prefix, pathtofsc, nreps, ncores) {
    # List template and estimation files for each model
    tpllist <- system(paste("ls ", prefix, "*.tpl", sep = ""), intern = TRUE)
    estlist <- system(paste("ls ", prefix, "*.est", sep = ""), intern = TRUE)
    listoffiles <- mapply(c, tpllist, estlist, SIMPLIFY = FALSE)

    # Set up parallel cluster
    cl <- parallel::makeCluster(ncores)

    # Run Fastsimcoal2 in parallel
    parallel::parLapply(cl, listoffiles, function(x) {
        system(paste(pathtofsc, " -t ", x[1], " -e ", x[2],
            " -n 1 --msfs -q --multiSFS -x -E", nreps, sep = ""), ignore.stdout = TRUE)
    })

    # Close parallel cluster
    parallel::stopCluster(cl)
}


# Run the models in parallel
parallel_fsc(prefix="gasteracantha_five",
             pathtofsc='/datacnmat01/biologia/biologia.evolutiva/shared/polythore_total/new_data/final_analysis/model_selection/fsc26_linux64/fsc26',
             nreps=10000,
             ncores=32)

# Random Forest Analysis
FullPrior <- makeprior(prefix=obsprefix,
                       nspec=obsspecies,
                       nclasses=nclasses,
                       getwd(),
                       traitsfile = traitsfile,
                       threshold=100,
                       thefolder = 'Prior',
                       ncores = 32)
save(list=ls(),file="full_prior.rda")
clean_working(prefix=obsprefix)
ReducedPrior <- Prior_reduced(FullPrior)
myRF <- RF_build_abcrf(ReducedPrior,FullPrior,500)
myRF
save(list=ls(),file="myRF.rda")

# Prepare observed data
myobserved <- prepobserved(observedSFS,
                            FullPrior,
                            ReducedPrior,
                            nclasses,
                            obsspecies,
                            traitsfile=traitsfile,
                            threshold = 100)

# Run Random Forest prediction
prediction <- RF_predict_abcrf(myRF, myobserved, ReducedPrior, FullPrior, 500)
prediction

# Save results
save(list=ls(),file="total_results.rda")
