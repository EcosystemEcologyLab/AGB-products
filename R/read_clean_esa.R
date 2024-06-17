#' Title
#'
#' @param files vector of file paths to .tifs starting at "data/rasters/ESA_CCI/"
#'
#' @return SpatRaster object
#' 
read_clean_esa <- function(files, region) {
  #TODO might be faster to first create a raster for each tile with year layers
  #then merge the tiles?
  
  #sort files by year
  years <- c(2010, 2017, 2018, 2019, 2020)
  files_list <- 
    purrr::map(years, \(year) {
      files[fs::path_file(files) |> stringr::str_detect(as.character(year))]
      }) |> 
    purrr::set_names(years)
  
  esa_agb <- 
    #for each year, combine tiles
    purrr::imap(files_list, \(x, idx) {
    combined <- x |> 
      purrr::map(terra::rast) |>
      terra::sprc() |> 
      terra::mosaic()
    # set units and names  
    names(combined) <- idx
    combined
    }) |> 
    #combine layers into a single SpatRaster
    rast()
  
  units(esa_agb) <- "Mg/ha"
  varnames(esa_agb) <- "AGB"
  
  region <- project(region, esa_agb)
  esa_agb |> crop(region) |> mask(region)
}
