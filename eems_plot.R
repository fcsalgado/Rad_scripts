if (dir.exists("rEEMSplots")) {
 install.packages("rEEMSplots", repos = NULL, type = "source")
 } else {
 stop("Move to the directory that contains the rEEMSplots source to install the package.")
 }

 extdata_path <- system.file("~/Documents/Gasteracantha_files/eems/inputs/run/eems/", package = "rEEMSplots")
  eems_results <- file.path(extdata_path, "output")
  name_figures <- file.path(path.expand("/home/fabian/Documents/Gasteracantha_files/eems/plot"), "plot")


 eems.plots(mcmcpath = "/home/fabian/Documents/Gasteracantha_files/eems/output",
 plotpath = paste0(name_figures, "-axes-flipped"),
 longlat = FALSE)

 eems.plots(mcmcpath = "/home/fabian/Documents/Gasteracantha_files/eems/output", plotpath = paste0(name_figures, "-output-PNGs"), longlat = TRUE, plot.height = 8, plot.width = 7, res = 600, out.png = TRUE)


 library("rgdal")
 projection_none <- "+proj=longlat +datum=WGS84"
 projection_mercator <- "+proj=merc +datum=WGS84"

 eems.plots(mcmcpath = "/home/fabian/Documents/Gasteracantha_files/eems/output",plotpath = paste0(name_figures, "-geographic-map"), longlat = TRUE, projection.in = projection_none, projection.out = projection_mercator,add.map = TRUE,col.map = "black",
 lwd.map = 5, res = 600, out.png = TRUE)

map_world <- getMap()
andes<-map_world[c(36,47,125,169),]

eems.plots(mcmcpath = "/home/fabian/Documents/Gasteracantha_files/eems/output",plotpath = paste0(name_figures, "-shapefile"), longlat = TRUE, m.plot.xy = { plot(andes, col = NA, add = TRUE) },q.plot.xy = { plot(andes, col = NA, add = TRUE) })
