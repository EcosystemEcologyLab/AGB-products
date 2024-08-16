  #for a single tile
clean_icesat <- function(input,
                         output = "/Volumes/moore/AGB_cleaned/icesat/") {
  fs::dir_create(output)
  
  #read in
  icesat_raw <- terra::rast(input)
  #keep just the AGB layer
  icesat <- icesat_raw[["aboveground_biomass_density (Mg ha-1)"]]
  
  #set metadata
  units(icesat) <- "Mg/ha"
  names(icesat) <- "2020"
  varnames(icesat) <- "AGB"
  
  #extract tile name
  tile_id <- path_file(input) |> stringr::str_extract("(?<=_)\\d+(?=\\.tif)")
  #construct output file name
  filename <- paste0(paste("icesat", "2020", tile_id, sep = "_"), .tif)
  outpath <- path(output, filename)
  #save tile out
  writeRaster(icesat, outpuath, filetype = "COG", overwrite = TRUE)
  #return:
  outpath
}