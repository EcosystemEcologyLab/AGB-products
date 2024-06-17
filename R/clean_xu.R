#' Read and clean Xu et al. dataset
#'
#' @param input the raw file to read in, "test10a_cd_ab_pred_corr_2000_2019_v2.tif"
#' @param output where to save the processed data including file extension
#' @param root the "root" directory where the `input` and `output` paths are
#'   relative to.  Default assumes you have the "snow" network drive mapped to
#'   `/Volumes/moore/`, but the path may be elsewhere for your computer.
#'
#' @return path to saved raster
#' 
#' @examples
#' clean_xu()
#'  
clean_xu <- function(input = "Xu/test10a_cd_ab_pred_corr_2000_2019_v2.tif", 
                     output = "AGB_cleaned/xu.tif",
                     root = "/Volumes/moore/") {
  # Xu
  input_path <- fs::path(root, input)
  output_path <- fs::path(root, output)
  xu_agb_raw <- terra::rast(input_path) 
  #conversion from MgC/ha to Mg/ha
  xu_agb <- xu_agb_raw * 2.2 
  units(xu_agb) <- "Mg/ha"
  names(xu_agb) <- 2000:2019
  varnames(xu_agb) <- "AGB"
  
  # Write to COG
  terra::writeRaster(xu_agb, output_path, filetype = "COG", overwrite = TRUE)
  return(output_path)
}


