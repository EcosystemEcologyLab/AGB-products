write_vrt <- function(rast, path) {
  terra::vrt(rast, filename = path, overwrite = TRUE, return_filename = TRUE)
}