clean_hfbs <- function(input = "/Volumes/moore/Harmonized Forest Biomass Spawn/tif/aboveground_biomass_carbon_2010.tif",
                       output = "/Volumes/moore/AGB_cleaned/hfbs/hfbs_2010.tif") {
  hfbs_raw <- terra::rast(input)
  fs::dir_create(fs::path_dir(output))
  
  #data is in MgC/ha with scale factor of 0.1
  #multiply by scale factor and convert to Mg/ha by multiplying by 2.2
  hfbs <- hfbs_raw * (0.1 * 2.2)
  
  #set metadata
  names(hfbs) <- 2010
  varnames(hfbs) <- "AGB"
  units(hfbs) <- "Mg/ha"
  
  writeRaster(hfbs, output, filetype = "COG", overwrite = TRUE)
  #return
  output
}

# input <- hfbs_file
