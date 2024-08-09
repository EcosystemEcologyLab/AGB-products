# library(targets)
# input <- tar_read(hfbs_file)

clean_hfbs <- function(input = "/Volumes/moore/Harmonized Forest Biomass Spawn/tif/aboveground_biomass_carbon_2010.tif",
                       output = "/Volumes/moore/AGB_cleaned/hfbs/hfbs_2010.tif") {
  
  hfbs_raw <- terra::rast(input)
  fs::dir_create(fs::path_dir(output))
  
  #data is in MgC/ha with scale factor of 0.1 (to save disk space)
  
  #set scale factor
  scoff(hfbs_raw) <- cbind(0.1, 0)
  
  #convert to Mg/ha by multiplying by 2.2
  #round to one decimal place (sig fig of original data)
  hfbs <- round(hfbs_raw * 2.2, 1)
  
  #set metadata
  names(hfbs) <- 2010
  varnames(hfbs) <- "AGB"
  units(hfbs) <- "Mg/ha"
  
  #write out with scale factor of 0.1 to convert to unsigned integers and save disk space
  writeRaster(hfbs, output, filetype = "COG", scale = 0.1, datatype = "INT4U", overwrite = TRUE)
  #return
  output
}

