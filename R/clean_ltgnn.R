
#' Pre-process LT-GNN data tiles
#' 
#' This is designed to work on a single tile of the LT-GNN dataset which are
#' downloaded as .zip files.  It uses the /vsizip/ protocol to load files
#' *inside* the .zip files without unzipping them.
#'
#' @param input path to a single .zip file containing a .tif of a tile
#' @param output the output directory to save the processed .tif
#'
#' @return output file path
#' 
clean_ltgnn <- function(input, output = "/Volumes/moore/AGB_cleaned/lt_gnn/") {
  fs::dir_create(output)
  #construct path to .tif inside of .zip using /vsizip
  tif <- 
    input |> 
    fs::path_file() |>
    fs::path_ext_set(".tif")
  
  rast_path <- paste("/vsizip", input, tif, sep = "/") #must be a double // after vsizip to use absolute paths!
  
  ltgnn_agb <- rast(rast_path)
  
  terra::varnames(ltgnn_agb) <- "AGB"
  terra::units(ltgnn_agb) <- "Mg/ha"
  names(ltgnn_agb) <- 1990:2017
  
  # Write as COG
  ## construct tile name
  tile_name <- stringr::str_extract(tif, "h\\d+v\\d+")
  outpath <- fs::path(
    output,
    paste0(paste("lt.gnn", tile_name, "1990-2017", sep = "_"), ".tif")
  )
  terra::writeRaster(ltgnn_agb, filename = outpath, filetype = "COG", overwrite = TRUE)
  #return
  outpath
}
