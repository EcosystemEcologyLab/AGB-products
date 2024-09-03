write_vrt <- function(rast, path) {
  terra::vrt(rast, filename = path, set_names = TRUE, overwrite = TRUE, return_filename = TRUE)
}