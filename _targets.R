# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes)
library(fs)
# library(reticulate)
library(crew)

# Set target options:
tar_option_set(
  packages = c("fs", "terra", "ncdf4", "purrr", "stringr"), # Packages that your targets need for their tasks.
  controller = crew::crew_controller_local(workers = 2, seconds_idle = 60)
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()

#TODO detect OS and switch root automatically??
#on mac:
# root <- "/Volumes/moore/"
#on windows vm:
root <- "//snow.snrenet.arizona.edu/projects/moore"

tar_plan(
  #track input files
  tar_file_fast(liu_file, path(root, "AGB_raw", "Liu/Aboveground_Carbon_1993_2012.nc")),
  tar_file_fast(xu_file, path(root, "AGB_raw", "Xu/test10a_cd_ab_pred_corr_2000_2019_v2.tif")),
  tar_file_fast(chopping_file, path(root, "AGB_raw", "Chopping/MISR_agb_estimates_20002021.tif")),
  tar_file_fast(gedi_file, path(root, "AGB_raw", "GEDI_L4B_v2.1/data/GEDI04_B_MW019MW223_02_002_02_R01000M_MU.tif")),
  tar_file_fast(menlove_file, path(root, "AGB_raw", "Menlove/data/")),
  tar_file_fast(hfbs_file, path(root, "AGB_raw", "Harmonized Forest Biomass Spawn/tif/aboveground_biomass_carbon_2010.tif")),
  #these ones come as multiple files and need some special handling to iterate over each tile
  tar_target(esa_paths_files, get_esa_paths(path(root, "AGB_raw")), iteration = "list"),
  tar_target(esa_paths, esa_paths_files, pattern = map(esa_paths_files), format = "file_fast"),
  tar_files(ltgnn_paths, fs::dir_ls(path(root, "AGB_raw", "LT_GNN"), glob = "*.zip"), format = "file_fast"),
  tar_files(nbcd_paths,
            fs::dir_ls(path(root, "AGB_raw", "Natl Biomass Carbon Dataset/NBCD2000_v2_1161/data"),
                       regexp =  "NBCD_MZ\\d{2}_FIA_ALD_biomass.tgz$"),
            format = "file_fast"),
  tar_file_fast(gfw_data, path(root, "AGB_raw", "GFW/Aboveground_Live_Woody_Biomass_Density.csv"),
                description = "metadata CSV"),
  tar_target(gfw_urls, make_gfw_urls(gfw_data),
             description = "named vector of URLs"),
  
  #track output files
  tar_file_fast(liu, clean_liu(input = liu_file, output = path(root, "AGB_cleaned/liu/liu_1993-2012.tif"))),
  tar_file_fast(xu, clean_xu(input = xu_file, output = path(root, "AGB_cleaned/xu/xu_2000-2019.tif"))),
  tar_file_fast(chopping, clean_chopping(input = chopping_file, output = path(root, "AGB_cleaned/chopping/chopping_2000-2021.tif"))),
  tar_file_fast(gedi, clean_gedi(input = gedi_file, output = path(root, "AGB_cleaned/gedi/gedi_2019-2023.tif"))),
  tar_file_fast(menlove, clean_menlove(input = menlove_file, output = path(root, "AGB_cleaned/menlove/menlove_2009-2019.tif"))),
  tar_file_fast(hfbs, clean_hfbs(input = hfbs_file, output = path(root, "AGB_cleaned/hfbs/hfbs_2010.tif"))),
  #these iterate over tiles and save output as tiles
  tar_file_fast(esa, clean_esa(input = esa_paths, output = path(root, "AGB_cleaned/esa_cci/")), pattern = map(esa_paths)),
  tar_file_fast(ltgnn, clean_ltgnn(input = ltgnn_paths, output = path(root, "AGB_cleaned/lt_gnn/")), pattern = map(ltgnn_paths)),
  tar_file_fast(nbcd, clean_nbcd(input = nbcd_paths, output = path(root, "AGB_cleaned/nbcd/")), pattern = map(nbcd_paths)),
  tar_file_fast(gfw, clean_gfw(input_url = gfw_urls, output = path(root, "AGB_cleaned/gfw/")), pattern = map(gfw_urls))
)
