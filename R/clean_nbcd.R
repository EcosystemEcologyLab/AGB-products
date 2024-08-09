# library(targets)
# library(terra)
input <- tar_read(nbcd_paths, branches =  1)

clean_nbcd <- function(input,
                       output = "/Volumes/moore/AGB_cleaned/nbcd/") {
  fs::dir_create(output)
  #https://daac.ornl.gov/NACP/guides/NBCD_2000_V2.html
  #tiled by zone
  # sounds like I want only NBCD_MZxx_FIA_ALD_biomass files
  # files are .tgz, so this is like ltgnn where I need to access files without unzipping
  #scale factor of 0.1
  #in kg/m2
  
  #input is .tgz, so open .tif inside with /vsitar
  tif <- 
    input |> 
    fs::path_file() |>
    fs::path_ext_set("tif")
  
  rast_path <- paste("/vsitar", input, tif, sep = "/") #must be a double // after vsitar to use absolute paths!
  
  nbcd_raw <- rast(rast_path)
  
  #set scale factor
  scoff(nbcd_raw) <- cbind(0.1, 0)
  
  #convert to Mg/ha
  nbcd <- nbcd_raw * 10
  
  #set metadata
  units(nbcd) <- "Mg/ha"
  varnames(nbcd) <- "AGB"
  names(nbcd) <- 2000

  # extract tile name
  tile_name <- tif |> stringr::str_extract("MZ\\d{2}")
  
  outpath <- fs::path(
    output,
    paste0(paste("nbcd", tile_name, "2000", sep = "_"), ".tif")
  )
  
  #since I multiplied by 10 to convert to Mg/ha, values are still integers and
  #can save some disk space by saving as same datatype as input and don't need a
  #scale factor
  
  writeRaster(nbcd, filename = outpath, filetype = "COG", datatype = datatype(nbcd_raw))
  
  #return:
  outpath
}

