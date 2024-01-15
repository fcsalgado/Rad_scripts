# R script for RF Model using mRates and training/testing data

# Load the randomForestSRC library
library("randomForestSRC")

# Read in deme level values from all spatial variables
altitude <- read.table("tables_analyses/alt.txt")
Bio18 <- read.table("tables_analyses/Bio18.txt")
Bio2 <- read.table("tables_analyses/Bio2.txt")
Bio3 <- read.table("tables_analyses/Bio3.txt")
Bio15 <- read.table("tables_analyses/Bio15.txt")
kernel <- read.table("tables_analyses/kernel.txt")
niche <- read.table("tables_analyses/niche.txt")

# Merge the environmental datasets into one dataframe: each deme has its own row, and each variable has its own column
Env.Table <- data.frame(altitude, Bio18, Bio2, Bio3, Bio15, kernel, niche)
names(Env.Table) <- c("altitude", "Bio18", "Bio2", "Bio3", "Bio15", "kernel", "niche")

# Read in deme level values for migration surfaces from mRates.txt, convert to migration rate, and take the log value to normalize response variable
mRates1 <- read.table("mrates.txt", header = FALSE)
mRates1$V1 <- log10(mRates1$V1)
names(mRates1) <- c("rates")

# Combine environmental and migration rate datasets
Full.Table = cbind(Env.Table, mRates1)

# Remove rows with missing values
Full.Table <- Full.Table[complete.cases(Full.Table),]

# "Full Model" random forest with tuning
FullModel_tune = tune(rates ~ altitude + Bio18 + Bio2 + Bio3 + Bio15, importance=TRUE, na.action=c("na.omit"), data=Full.Table) # to account for spatial autocorrelation add the kernel here and all the other models
mtry_optimal <- FullModel_tune$optimal[["mtry"]]
nodesize_optimal <- FullModel_tune$optimal[["nodesize"]]
FullModel_withTuning = rfsrc(rates ~ altitude + Bio18 + Bio2 + Bio3 + Bio15, importance=TRUE, na.action=c("na.omit"), mtry = mtry_optimal, nodesize = nodesize_optimal, data=Full.Table)

# Find correlation between predicted and actual migration rates, and RMSE of the model
R = cor(FullModel_withTuning$predicted.oob, Full.Table$rates)
RMSE = sqrt(mean((FullModel_withTuning$predicted.oob - Full.Table$rates)^2))

# Print results
FullModel_withTuning
paste("R", R)
paste("RMSE", RMSE)

# Create figures and save as PDFs
pdf("noKernel/mRates_2-4_varImp.pdf", 7, 7)
plot(FullModel_withTuning, m.target = NULL, plots.one.page = TRUE, sorted = TRUE, verbose = TRUE)
dev.off()

pdf("noKernel/mRates_2-4_FullScatter.pdf", 5, 5)
plot(FullModel_withTuning$predicted.oob, Full.Table$rates, xlab="Predicted migration", ylab="Observed migration (MAPS)")
legend("bottomright", legend=c(paste0("Pearson correlation = ", round(R,3))), cex=0.7)
dev.off()

# Run random forest again with a 70/30 training/testing ratio
NumPoints = nrow(Full.Table)
Training = NumPoints * 0.7
TrainingInt = round(Training)
TrainingPoints = sample(1:NumPoints, TrainingInt, replace = FALSE)
Full.Table.train = Full.Table[TrainingPoints,]
Full.Table.valid = Full.Table[-TrainingPoints,]

TrainModel_tune = tune(rates ~ altitude + Bio18 + Bio2 + Bio3 + Bio15, importance=TRUE, na.action=c("na.omit"), data=Full.Table)
mtry_optimal_train <- TrainModel_tune$optimal[["mtry"]]
nodesize_optimal_train <- TrainModel_tune$optimal[["nodesize"]]
TrainModel = rfsrc(rates ~ altitude + Bio18 + Bio2 + Bio3 + Bio15, importance=TRUE, na.action=c("na.omit"), mtry = mtry_optimal_train, nodesize = nodesize_optimal_train, data=Full.Table.train)

# Calculate predicted vs actual migration rates for testing and training data, and RMSE for each dataset
Rtrain = cor(TrainModel$predicted.oob, Full.Table.train$rates)
Rtest = cor((predict.rfsrc(TrainModel, Full.Table.valid))$predicted, Full.Table.valid$rates)
RMSEtrain = sqrt(mean((TrainModel$predicted.oob - Full.Table.train$rates)^2))
RMSEtest = sqrt(mean((predict.rfsrc(TrainModel, Full.Table.valid)$predicted - Full.Table.valid$rates)^2))

# Print 70/30 training/testing results
TrainModel
paste("Rtrain", Rtrain)
paste("Rtest", Rtest)
paste("RMSEtrain", RMSEtrain)
paste("RMSEtest", RMSEtest)

# Create figures and save as PDFs
pdf("noKernel/mRates_2-4_varImp.pdf", 7, 7)
plot(TrainModel, m.target = NULL, plots.one.page = TRUE, sorted = TRUE, verbose = TRUE)
dev.off()

pdf("noKernel/mRates_2-4_TrainingObservedScatter.pdf", 5, 5)
plot(TrainModel$predicted.oob, Full.Table.train$rates, xlab ="Predicted Migration (training)", ylab="Observed Migration (MAPS)")
legend("bottomright", legend=c(paste0("Pearson correlation = ", round(Rtrain,3))), cex=0.7)
dev.off()

pdf("noKernel/mRates_2-4_ValidObservedScatter.pdf", 5, 5)
plot(predict.rfsrc(TrainModel, Full.Table.valid)$predicted, Full.Table.valid$rates, xlab ="Predicted Migration (validation)", ylab="Observed Migration (MAPS)")
legend("bottomright", legend=c(paste0("Pearson correlation = ", round(Rtest,3))), cex=0.7)
dev.off()

# Save the R environment
save(list=ls(),file="noKernel/objects.rda")
