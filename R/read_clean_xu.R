#' Read and clean Xu et al. dataset
#'
#' @param file "data/rasters/Xu/test10a_cd_ab_pred_corr_2000_2019_v2.tif"
#' @param region SpatVector of AZ
#'
#' @return SpatRaster object
#' 
read_clean_xu <- function(file, region) {
  # Xu
  xu_agb <- terra::rast(file) * 2.2 #conversion from MgC/ha to Mg/ha
  units(xu_agb) <- "Mg/ha"
  names(xu_agb) <- 2000:2019
  varnames(xu_agb) <- "AGB"
  
  # Project and crop
  region <- terra::project(region, xu_agb)
  xu_agb |> crop(region) |> mask(region)
}