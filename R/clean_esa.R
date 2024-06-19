#' Pre-process ESA CCI data
#'
#' To be used on a single tile at a time, for example, in conjunction with the
#' list outupt by `get_esa_paths()` using dynamic branching in `targets`.
#'
#' @param input character vector of file paths corresponding to a single tile
#' @param output path to output directory
#'
#' @return output file name
#' 
clean_esa <- function(
    input,
    output = "/Volumes/moore/AGB_cleaned/esa_cci/"
) {
  fs::dir_create(output)
  
  esa_tile <- terra::rast(input) #input is a vector of file paths for each year in a tile
  
  terra::units(esa_tile) <- "Mg/ha"
  terra::varnames(esa_tile) <- "AGB"
  names(esa_tile) <- c(2010, 2017, 2018, 2019, 2020) #TODO should really do this from file names instead
  
  # Write tile to COG
  ## construct file name
  tile_name <- stringr::str_extract(input, "(N|S)\\d+(W|E)\\d+") |> unique()
  stopifnot(length(tile_name) == 1)
  
  outpath <- 
    fs::path(
      output,
      paste0(paste("esa.cci", tile_name, "2010.2017-2020", sep = "_"), ".tif")
    )
  
  # Write COG
  terra::writeRaster(esa_tile, outpath, filetype = "COG", overwrite = TRUE)
  #return file name
  outpath
}
