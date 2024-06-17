#' Read Liu .nc file and convert to raster with correct projection and units
#'
#' @param file data/rasters/Liu/Aboveground_Carbon_1993_2012.nc
#' @param region SpatVector of AZ
#' @return a SpatRaster object
#' 
read_clean_liu = function(file, region) {
  # Open Liu AGBc netCDF file
  nc <- nc_open(file)
  
  # Extract lat/lon attributes
  lat <- ncvar_get(nc, 'latitude')
  lon <- ncvar_get(nc, 'longitude')
  
  # Extract AGBc variable (matrix)
  liu.agb.mat <- ncvar_get(nc, 'Aboveground Biomass Carbon')
  
  # Close netCDF file
  nc_close(nc)
  
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
  
  # Project and Crop
  region <- project(region, liu_agb)
  liu_agb |> crop(region) |> mask(region)
}
