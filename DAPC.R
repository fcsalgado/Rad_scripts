# Load necessary libraries
library(vcfR)
library(adegenet)
library(phrynomics)

# Read the VCF file containing random SNPs
vcf <- read.vcfR("<your_vcf>", verbose = FALSE)

# Convert VCF to genind format
my_genind <- vcfR2genind(vcf)

# Read population information from a text file
pop <- read.table("pop.txt", head = FALSE)

# Define population classes and set levels
clases <- c("Campinas", "PFBA", "Lencois", "Acre", "Leticia", "Guaviare", "Tarapoto", "Moyobamba", "Sucua", "Misahualli", "Jaen", "Villavicencio", "ElPangui", "Gualaquiza", "Banos", "Alamor", "Vilcabamba", "Piura", "Chiclayo", "Lima", "Santo", "Quito", "Bahia", "Cali", "Palmira", "Boquia", "Ibague", "Medellin", "Cucuta", "Cartagena", "Sanjuan", "San")
pop$V1 <- factor(pop$V1, levels = clases)

# Assign population information to genind object
my_genind$pop <- as.factor(pop$V1)

# Calculate the number of clusters using find.clusters
grp <- find.clusters(my_genind, max.n.clust = 40)

# Display the distribution of original populations within the clusters
table.value(table(pop(my_genind), grp$grp), col.lab = paste("inf", 1:7))

# DAPC analysis
dapc.my_genind <- dapc(my_genind, var.contrib = TRUE, scale = FALSE, n.pca = 30, n.da = nPop(my_genind) - 1)

# Save DAPC results to a PDF file
pdf("DAPC.pdf", width = 20, height = 27, family = "Helvetica")

# Plot DAPC results with specified colors
scatter(dapc.my_genind, col = c("#68af57", "#fb6ea0", "#00cec3"))

# Cross-validation using xvalDapc
set.seed(999)
my_genind$pop <- grp$grp
pramx <- xvalDapc(tab(my_genind, NA.method = "mean"), pop(my_genind), training.set = 0.9, result = "groupMean", center = TRUE, scale = FALSE, n.pca = NULL, n.rep = 100)

# Plot cross-validation results
scatter(pramx$DAPC, cex = 2, legend = TRUE, clabel = FALSE, posi.leg = "bottomleft", col = c("#00cec3", "#68af57", "#fb6ea0"), posi.pca = "topleft", cleg = 0.75, xax = 1, yax = 2, inset.solid = 1)

