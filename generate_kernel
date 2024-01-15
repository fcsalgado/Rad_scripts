# Source: https://www.samuelbosch.com/2014/02/creating-kernel-density-estimate-map-in.html

# Load required libraries
library("KernSmooth")
library("raster")
library("dplyr")

# Define the coordinate reference system
crs.geo <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

# Load input points from a file
points <- read.table("../eems/better_vcf/total_samples/gasteracantha_input.coord", sep="\t", header = FALSE)

# Load input polygon from a file
polygon_eems <- read.table("../eems/better_vcf/total_samples/gasteracantha_input.outer", sep="\t", header = FALSE)
names(polygon_eems) <- c("x", "y")

# Compute distinct coordinates from the input points
coordinates2 <- distinct(points)

# Compute the 2D binned kernel density estimate
est <- bkde2D(coordinates2, 
              bandwidth = c(2, 2), 
              gridsize = c(1800, 2460),
              range.x = list(c(min(polygon_eems$x), max(polygon_eems$x)), c(min(polygon_eems$y), max(polygon_eems$y))))

# Create a raster from the kernel density estimate
est.raster <- raster(list(x = est$x1, y = est$x2, z = est$fhat))
projection(est.raster) <- crs.geo

# Set raster extent based on the polygon coordinates
xmin(est.raster) <- min(polygon_eems$x)
xmax(est.raster) <- max(polygon_eems$x)
ymin(est.raster) <- min(polygon_eems$y)
ymax(est.raster) <- max(polygon_eems$y)

# Visually inspect and save the raster output
plot(est.raster)
writeRaster(est.raster, "kernel", format = "GTiff")
