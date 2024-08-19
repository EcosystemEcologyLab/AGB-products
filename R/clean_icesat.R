  #for a single tile
clean_icesat <- function(input_url,
                         output = "/Volumes/moore/AGB_cleaned/icesat/") {
  fs::dir_create(output)
  tile_id <- names(input_url)
  
  #read in
  icesat_raw <- rast(input_url, vsi = TRUE)
  #keep just the AGB layer
  icesat <- icesat_raw[["aboveground_biomass_density (Mg ha-1)"]]
  
  #set metadata
  units(icesat) <- "Mg/ha"
  names(icesat) <- "2020"
  varnames(icesat) <- "AGB"
  
  #construct output file name
  filename <- paste0(paste("icesat", "2020", tile_id, sep = "_"), ".tif")
  outpath <- path(output, filename)
  #save tile out
  writeRaster(icesat, outpath, filetype = "COG", overwrite = TRUE)
  #return:
  outpath
}