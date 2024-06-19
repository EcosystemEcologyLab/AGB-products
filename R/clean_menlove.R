#' Clean Menlove & Healey product
#'
#' @references https://daac.ornl.gov/CMS/guides/FIA_Forest_Biomass_Estimates.html
#'
#' @param input path to either .zip file or directory of shapefile
#' @param output path to output raster file
#'
#' @return path to output raster file
clean_menlove <- function(input = "/Volumes/moore/Menlove/data/",
                          output = "/Volumes/moore/AGB_cleaned/menlove/menlove_2009-2019.tif") {
  fs::dir_create(fs::path_dir(output))
  # Read in just the live + dead trees layer
  menlove_vect <- 
    terra::vect(input, query = "SELECT CRM_LIVE_D FROM CONUSbiohex2020")
  
  # Rasterize
  # to roughly 1km resolution?
  template <-  terra::rast(resolution = 0.008, extent = terra::ext(menlove_vect))
  menlove_rast <- terra::rasterize(menlove_vect, template, field = "CRM_LIVE_D")
  
  # Metadata
  
  units(menlove_rast) <- "Mg/ha"
  varnames(menlove_rast) <- "AGB"
  names(menlove_rast) <- "2009-2019 mean live + dead"
  
  # Write to COG
  terra::writeRaster(menlove_rast, output, filetype = "COG", overwrite = TRUE)
  output
}