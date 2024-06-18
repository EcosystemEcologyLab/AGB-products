#' Read and clean Xu et al. dataset
#'
#' @param input path to file to read in, "test10a_cd_ab_pred_corr_2000_2019_v2.tif"
#' @param output path to save the processed data including file extension
#'
#' @return path to saved raster
#' 
#' @examples
#' clean_xu()
#'  
clean_xu <- function(input = "/Volumes/moore/Xu/test10a_cd_ab_pred_corr_2000_2019_v2.tif", 
                     output = "/Volumes/moore/AGB_cleaned/xu/xu_2000-2029.tif") {
  # Create output dir (if not already there)
  fs::dir_create(fs::path_dir(output))
  # Read in data
  xu_agb_raw <- terra::rast(input) 
  #conversion from MgC/ha to Mg/ha
  xu_agb <- xu_agb_raw * 2.2 
  #add metadata
  units(xu_agb) <- "Mg/ha"
  varnames(xu_agb) <- "AGB"
  names(xu_agb) <- 2000:2019
  
  # Write to COG
  terra::writeRaster(xu_agb, output, filetype = "COG", overwrite = TRUE)
  output
}


