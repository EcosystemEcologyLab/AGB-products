# library(targets)
# file <- tar_read(gfw_data)
make_gfw_urls <- function(file) {
  df <- read.csv(file)
  urls <- df$Mg_ha_1_download
  names(urls) <- df$tile_id
  urls
}
