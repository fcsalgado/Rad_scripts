# Load necessary libraries
library(reconproGS)
library(poppr)
library(vcfR)

# Read VCF file and convert to genind format
vcf <- vcfR::read.vcfR("gasteracantha_popTotal.vcf")
my_genind <- vcfR2genind(vcf)

# Read population information from a file
tabla <- read.table("pops.txt", head = TRUE)

# Define regional groups based on populations
amazonas <- c("Lencois", "PFBA", "Acre", "Leticia", "Guaviare", "Tarapoto", "Moyobamba", "Sucua", "Misahualli", "Villavicencio", "Jaen", "Banos")
dry <- c("Alamor", "Vilcabamba", "Piura", "Chiclayo", "Santo", "Lima")
andes <- c("Quito", "Bahia", "Boquia", "Cali", "Palomino", "Ibague", "Medellin", "Sanjuan", "San")

# Assign regional labels to each population
reg <- NULL
for (i in tabla$pop) {
  if (i %in% amazonas) {
    reg <- c(reg, "amazonas")
  } else if (i %in% dry) {
    reg <- c(reg, "dry")
  } else if (i %in% andes) {
    reg <- c(reg, "andes")
  }
}
tabla$reg <- reg
my_genind$strata <- tabla

# Calculate genetic distance and perform AMOVA
gen.dist <- dist(x = my_genind, method = "euclidean", diag = TRUE, upper = TRUE)
AMOVA <- poppr.amova(my_genind, hier = ~reg/pop, dist = gen.dist, squared = TRUE, within = TRUE, quiet = FALSE)

# Perform randomization and compare with observed AMOVA
AMOVAsignif <- randtest(AMOVA, nrepet = 999)
plot(AMOVAsignif)

# Randomize data and perform AMOVA on randomized dataset
set.seed(9001)
my_genind_rand <- my_genind
strata(my_genind_rand)[, c(2, 3)] <- strata(my_genind)[sample(nInd(my_genind)), -1]
rand_amova <- poppr.amova(my_genind_rand, hier = ~reg/pop, dist = gen.dist, squared = TRUE, within = TRUE, quiet = FALSE)
