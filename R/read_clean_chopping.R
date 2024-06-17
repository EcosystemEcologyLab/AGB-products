#' Read and wrangle data from Chopping et al. 2022
#'
#' @param file "data/rasters/Chopping/MISR_agb_estimates_20002021.tif"
#' @param region SpatVector of AZ
#' 
#' @references Chopping, M.J., Z. Wang, C. Schaaf, M.A. Bull, and R.R. Duchesne.
#'   2022. Forest Aboveground Biomass for the Southwestern U.S. from MISR,
#'   2000-2021. ORNL DAAC, Oak Ridge, Tennessee, USA.
#'   https://doi.org/10.3334/ORNLDAAC/1978
#' 
#' @return SpatRaster object
#' 
read_clean_chopping <- function(file, region) {
  # Read in file and select
  # Spans 2000 - 2021 so layer 10 is 2010
  chopping_agb <- terra::rast(file)
  
  # Set units and names
  units(chopping_agb) <- "Mg/ha"
  names(chopping_agb) <- 2000:2021
  varnames(chopping_agb) <- "AGB"

  region <- project(region, crs(chopping_agb))
  crop(chopping_agb, region) |> mask(region)
}