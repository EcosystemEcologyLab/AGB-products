#Note: this is for wrangling a single tile
clean_gfw <- function(input_url,
                      output = "/Volumes/moore/AGB_cleaned/gfw/") {
  dir_create(output)
  tile_name <- names(input_url)
  
  #read in raster from URL with vsicurl//
  gfw <- rast(input_url, vsi = TRUE)
  
  #set metadata, no unit conversion needed
  names(gfw) <- 2000
  units(gfw) <- "Mg/ha"
  varnames(gfw) <- "AGB"
  
  filename <- paste0(paste("gfw", tile_name, "2000", sep = "_"), ".tif")
  outpath <- path(output, filename)
  writeRaster(gfw, outpath, filetype = "COG", overwrite = TRUE)
  #return:
  outpath
}

