#' Read Liu .nc file and convert to raster with correct projection and units
#'
#' @param input the raw file to read in, "Aboveground_Carbon_1993_2012.nc"
#' @param output where to save the processed data including file extension
#' @param root the "root" directory where the `input` and `output` paths are
#'   relative to.  Default assumes you have the "snow" network drive mapped to
#'   `/Volumes/moore/`, but the path may be elsewhere for your computer.
#' 
#' @examples
#' clean_liu()
#' 
#' @return output path
clean_liu = function(
    input = "Liu/Aboveground_Carbon_1993_2012.nc",
    output = "AGB_cleaned/liu.tif",
    root = "/Volumes/moore/"
) {
  input_path <- fs::path(root, input)
  output_path <- fs::path(root, output)
  # Open Liu AGBc netCDF file
  nc <- ncdf4::nc_open(input_path)
  #close the nc file when the function completes or if it gets interrupted
  on.exit(ncdf4::nc_close(nc))
  
  # Extract lat/lon attributes
  lat <- ncdf4::ncvar_get(nc, 'latitude')
  lon <- ncdf4::ncvar_get(nc, 'longitude')
  
  # Extract AGBc variable (matrix)
  liu.agb.mat <- ncdf4::ncvar_get(nc, 'Aboveground Biomass Carbon')

  # Get spatial extent of Liu dataset
  liu.ext <- c(min(lon), max(lon), min(lat), max(lat))
  
  # Set spatial coordinate reference system variable
  liu.crs <- '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'
  
  # Convert from AGBC (MgC/ha) to AGB (Mg/ha) by multiplying by 2.2
  liu_agb <- terra::rast(liu.agb.mat) * 2.2
  terra::ext(liu_agb) <- liu.ext
  terra::crs(liu_agb) <- liu.crs
  
  # Set names and units
  names(liu_agb) <- 1993:2012
  varnames(liu_agb) <- "AGB"
  terra::units(liu_agb) <-  "Mg/ha"
  
  # Write to COG
  terra::writeRaster(liu_agb, output_path, filetype = "COG", overwrite = TRUE)
  return(output_path)
}
