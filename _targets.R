# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes)
library(fs)

# Set target options:
tar_option_set(
  packages = c("fs", "terra", "ncdf4", "purrr", "stringr"), # Packages that your targets need for their tasks.
  controller = crew::crew_controller_local(workers = 4, seconds_idle = 60)
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# tar_source("other_functions.R") # Source other scripts as needed.
root <- "/Volumes/moore/"
tar_plan(
  #track input files
  tar_file(liu_file, path(root, "Liu/Aboveground_Carbon_1993_2012.nc")),
  tar_file(xu_file, path(root, "Xu/test10a_cd_ab_pred_corr_2000_2019_v2.tif")),
  tar_file(chopping_file, path(root, "Chopping/MISR_agb_estimates_20002021.tif")),
  #these ones come as multiple files and need some special handling to iterate over each tile
  tar_target(esa_paths_files, get_esa_paths(), iteration = "list"),
  tar_target(esa_paths, esa_paths_files, pattern = map(esa_paths_files), format = "file"),
  tar_files(ltgnn_paths, fs::dir_ls(path(root, "LT_GNN"), glob = "*.zip")),
  
  #track output files
  tar_file(liu, clean_liu(input = liu_file)),
  tar_file(xu, clean_xu(input = xu_file)),
  tar_file(chopping, clean_chopping(input = chopping_file)),
  #these iterate over tiles and save output as tiles
  tar_file(esa, clean_esa(esa_paths), pattern = map(esa_paths)),
  tar_file(ltgnn, clean_ltgnn(ltgnn_paths), pattern = map(ltgnn_paths))
)
