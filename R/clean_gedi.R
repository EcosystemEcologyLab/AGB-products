#' Pre-process GEDI L4B v2.1
#'
#' Note: this dataset comes with many other files for additional layers such as
#' variance, quality control flags, etc.  These may also be of use in addition
#' to the AGB layer read in by this function.
#'
#' @references https://daac.ornl.gov/GEDI/guides/GEDI_L4B_Gridded_Biomass_V2_1.html 
#'
#' @param input path to input tif.  Input file has a single layer representing
#'   mean aboveground biomass density for the period 2019-04-18 to 2023-03-16
#' @param output path to output file
#'
#' @return path to output file
clean_gedi <- function(input = "/Volumes/moore/GEDI_L4B_v2.1/data/GEDI04_B_MW019MW223_02_002_02_R01000M_MU.tif",
                       output = "/Volumes/moore/AGB_cleaned/gedi/gedi_2019-2023.tif") {
  fs::dir_create(fs::path_dir(output))
  gedi_agb <- terra::rast(input)
  
  units(gedi_agb) <- "Mg/ha"
  names(gedi_agb) <- "2019-2023"
  varnames(gedi_agb) <- "AGB"
  
  #write to COG
  terra::writeRaster(gedi_agb, output, filetype = "COG", overwrite = TRUE)
  #return
  output
}