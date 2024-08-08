#Note: this is for wrangling a single tile
clean_gfw <- function(input = "/Volumes/moore/AGB_raw/GFW/40N_110W.tif",
                      output = "/Volumes/moore/AGB_cleaned/gfw/") {
  dir_create(output)
  tile_name <- path_file(input) |> path_ext_remove()
  gfw <- rast(input)
  names(gfw) <- 2000
  filename <- paste0(paste("gfw", tile_name, "2000", sep = "_"), ".tif")
  outpath <- path(output, filename)
  writeRaster(gfw, filename, filetype = "COG", overwrite = TRUE)
  #return:
  outpath
}