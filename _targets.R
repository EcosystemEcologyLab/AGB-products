# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes)
library(fs)
library(reticulate)
library(crew)

# Set target options:
tar_option_set(
  packages = c("fs", "terra", "ncdf4", "purrr", "stringr"), # Packages that your targets need for their tasks.
  controller = crew::crew_controller_local(workers = 4, seconds_idle = 60)
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()

root <- "/Volumes/moore/"
tar_plan(
  #track input files
  tar_file_fast(liu_file, path(root, "Liu/Aboveground_Carbon_1993_2012.nc")),
  tar_file_fast(xu_file, path(root, "Xu/test10a_cd_ab_pred_corr_2000_2019_v2.tif")),
  tar_file_fast(chopping_file, path(root, "Chopping/MISR_agb_estimates_20002021.tif")),
  tar_file_fast(gedi_file, path(root, "GEDI_L4B_v2.1/data/GEDI04_B_MW019MW223_02_002_02_R01000M_MU.tif")),
  tar_file_fast(menlove_file, path(root, "Menlove/data/")),
  #these ones come as multiple files and need some special handling to iterate over each tile
  tar_target(esa_paths_files, get_esa_paths(root), iteration = "list"),
  tar_target(esa_paths, esa_paths_files, pattern = map(esa_paths_files), format = "file_fast"),
  tar_files(ltgnn_paths, fs::dir_ls(path(root, "LT_GNN"), glob = "*.zip"), format = "file_fast"),
  
  #track output files
  tar_file_fast(liu, clean_liu(input = liu_file)),
  tar_file_fast(xu, clean_xu(input = xu_file)),
  tar_file_fast(chopping, clean_chopping(input = chopping_file)),
  tar_file_fast(gedi, clean_gedi(input = gedi_file)),
  tar_file_fast(menlove, clean_menlove(input = menlove_file)),
  #these iterate over tiles and save output as tiles
  tar_file_fast(esa, clean_esa(esa_paths), pattern = map(esa_paths)),
  tar_file_fast(ltgnn, clean_ltgnn(ltgnn_paths), pattern = map(ltgnn_paths))
)
