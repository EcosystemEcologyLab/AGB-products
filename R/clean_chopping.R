#' Read and wrangle data from Chopping et al. 2022
#'
#' @param input the raw file to read in, "MISR_agb_estimates_20002021.tif"
#' @param output where to save the processed data including file extension
#' @param root the "root" directory where the `input` and `output` paths are
#'   relative to.  Default assumes you have the "snow" network drive mapped to
#'   `/Volumes/moore/`, but the path may be elsewhere for your computer.
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
clean_chopping <- function(input = "Chopping/MISR_agb_estimates_20002021.tif",
                           output = "AGB_cleaned/chopping.tif",
                           root = "/Volumes/moore/") {
  input_path <- fs::path(root, input)
  output_path <- fs::path(root, output)

  chopping_agb <- terra::rast(input_path)
  
  # Set units
  units(chopping_agb) <- "Mg/ha"
  # Spans 2000 - 2021
  names(chopping_agb) <- 2000:2021
  varnames(chopping_agb) <- "AGB"
  
  # Write to COG
  terra::writeRaster(chopping_agb, output_path, filetype = "COG", overwrite = TRUE)
  return(output_path)

}