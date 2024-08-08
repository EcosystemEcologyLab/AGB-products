clean_hfbs <- function(input = "/Volumes/moore/Harmonized Forest Biomass Spawn/tif/aboveground_biomass_carbon_2010.tif",
                       output = "/Volumes/moore/AGB_cleaned/hfbs/hfbs_2010.tif") {
  hfbs <- terra::rast(input)
  names(hfbs) <- 2010
  fs::dir_create(fs::path_dir(output))
  writeRaster(hfbs, output, filetype = "COG", overwrite = TRUE)
  #return
  output
}