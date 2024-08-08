#' Generate list of ESA CCI files by tile
#' 
#' This function generates a list of file paths where each element of the list
#' corresponds to a tile (e.g. N50W120) and is a character vector containing
#' paths to all the files for that tile (i.e. each year).  Used in combination
#' with `clean_esa()` to combine years and do pre-processing for each tile.
#'
#' @param esa_dir input directory containing .tif (or .tiff) files for each tile
#'   and year.
#'
#' @return a list of file paths
#'
#' @examples
get_esa_paths <- function(root = "/Volumes/moore/", esa_dir = "ESA_CCI") {
  files <- fs::path(root, esa_dir) |> fs::dir_ls(glob = "*.tif*") 
  
  #sort files by tile
  tiles <- files |> stringr::str_extract("(N|S)\\d+(W|E)\\d+") |> unique()
  files_list <-
    purrr::map(tiles, \(tile) {
      files[fs::path_file(files) |> stringr::str_detect(tile)]
    }) |> 
    purrr::set_names(tiles) 
  files_list
}