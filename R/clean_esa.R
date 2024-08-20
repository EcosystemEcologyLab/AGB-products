#' Pre-process ESA CCI data
#'
#' Reads in yearly global .nc files, stacks them, and outputs as tiled
#' cloud-optimized geotiffs
#'
#' @param input character vector of file paths corresponding to global .nc files
#'   for each year
#' @param output path to output directory
#'
#' @return output file path
#' 
clean_esa <- function(input,
                      output = "/Volumes/moore/AGB_clean/esa/") {
  
  fs::dir_create(output)
  esa_list <- purrr::map(input, \(x) rast(x, lyrs = "agb"))
  
  esa <- esa_list |> rast()
  names(esa) <- stringr::str_extract(time(esa), "^\\d{4}")
  varnames(esa) <- "AGB"
  esa
  
  outpath <- path(output, "esa_2010.2017-2020_.tif") #will have tile number appended to it by makeTiles
  
  makeTiles(esa, terra::fileBlocksize(esa)[1,], filename = outpath, filetype = "COG", overwrite = TRUE)
  #makeTiles returns file paths
}
