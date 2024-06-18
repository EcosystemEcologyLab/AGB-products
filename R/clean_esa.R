
clean_esa <- function(
    input = "/Volumes/moore/ESA_CCI",
    output = "/Volumes/moore/AGB_cleaned/esa_cci/"
) {
  fs::dir_create(output)
  
  files <- fs::path(input) |> fs::dir_ls(glob = "*.tif*") 
  
  #sort files by tile
  tiles <- files |> stringr::str_extract("(N|S)\\d+(W|E)\\d+") |> unique()
  files_list <-
    purrr::map(tiles, \(tile) {
      files[fs::path_file(files) |> stringr::str_detect(tile)]
    }) |> 
    purrr::set_names(tiles) 
  
  #for each tile, combine years
  rast_list <- files_list |> 
    purrr::map(terra::rast) |> 
    purrr::map(\(x) {
      terra::units(x) <- "Mg/ha"
      terra::varnames(x) <- "AGB"
      names(x) <- c(2010, 2017, 2018, 2019, 2020) #TODO probably better to get this from file names
      x
    })
  
  #if combining tiles is needed:
  # rast_combined <- terra::sprc(rast_list) |> terra::mosaic()
  
  # Write each tile to COG
  ## construct file names
  out_tile_names <- 
    paste0(paste("esa.cci", names(rast_list), "2010.2017-2020", sep = "_"), ".tif")
  out_tile_paths <-
    fs::path(output, filename)
  # write each tile out
  purrr::walk2(rast_list, out_tile_paths, \(rast, outpath) {
    terra::writeRaster(rast, outpath, filetype = "COG", overwrite = TRUE)
  })
  #return file names
  out_tile_paths
}
