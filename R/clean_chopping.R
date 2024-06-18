#' Read and wrangle data from Chopping et al. 2022
#'
#' @param input path to raw file to read in, "MISR_agb_estimates_20002021.tif"
#' @param output path to save the processed data including file extension
#' 
#' @examples
#' clean_chopping()
#' 
#' @references Chopping, M.J., Z. Wang, C. Schaaf, M.A. Bull, and R.R. Duchesne.
#'   2022. Forest Aboveground Biomass for the Southwestern U.S. from MISR,
#'   2000-2021. ORNL DAAC, Oak Ridge, Tennessee, USA.
#'   https://doi.org/10.3334/ORNLDAAC/1978
#' 
#' @return output path
#' 
clean_chopping <- function(input = "/Volumes/moore/Chopping/MISR_agb_estimates_20002021.tif",
                           output = "/Volumes/moore/AGB_cleaned/chopping/chopping_2000-2021.tif") {
  # Create output dir if not already there
  fs::dir_create(fs::path_dir(output))
  chopping_agb <- terra::rast(input)
  
  # Set units
  units(chopping_agb) <- "Mg/ha"
  varnames(chopping_agb) <- "AGB"
  # Spans 2000 - 2021
  names(chopping_agb) <- 2000:2021
  
  # Write to COG
  terra::writeRaster(chopping_agb, output, filetype = "COG", overwrite = TRUE)
  output

}