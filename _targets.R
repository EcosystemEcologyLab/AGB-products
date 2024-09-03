# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes)
library(fs)
library(crew)

# Set target options:
tar_option_set(
  packages = c("fs", "terra", "ncdf4", "purrr", "stringr", "xml2"), # Packages that your targets need for their tasks.
  controller = crew::crew_controller_local(
    workers = 4,
    seconds_idle = 60,
    tasks_max = 10 #this prevents tempdir() from filling up too much maybe?
  )
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
  #these ones come as multiple files and need some special handling
  tar_file_fast(esa_paths, fs::dir_ls(path(root, "AGB_raw/ESA_CCI_global/"), glob = "*.nc")),
  tar_files(ltgnn_paths, fs::dir_ls(path(root, "AGB_raw", "LT_GNN"), glob = "*.zip"), format = "file_fast"),
  tar_files(nbcd_paths,
            fs::dir_ls(path(root, "AGB_raw", "Natl Biomass Carbon Dataset/NBCD2000_v2_1161/data"),
                       regexp =  "NBCD_MZ\\d{2}_FIA_ALD_biomass.tgz$"),
            format = "file_fast"),
  tar_file_fast(gfw_data, path(root, "AGB_raw", "GFW/Aboveground_Live_Woody_Biomass_Density.csv"),
                description = "metadata CSV"),
  tar_target(gfw_urls, make_gfw_urls(gfw_data),
             description = "named vector of URLs"),
  tar_target(icesat_urls, make_icesat_urls(fs::path(root, "AGB_raw/Boreal_AGB_Density_ICESat2/download_links.html"))),

  #track output files
  tar_file_fast(liu, clean_liu(input = liu_file, output = path(root, "AGB_cleaned/liu/liu_1993-2012.tif"))),
  tar_file_fast(xu, clean_xu(input = xu_file, output = path(root, "AGB_cleaned/xu/xu_2000-2019.tif"))),
  tar_file_fast(chopping, clean_chopping(input = chopping_file, output = path(root, "AGB_cleaned/chopping/chopping_2000-2021.tif"))),
  tar_file_fast(gedi, clean_gedi(input = gedi_file, output = path(root, "AGB_cleaned/gedi/gedi_2019-2023.tif"))),
  tar_file_fast(menlove, clean_menlove(input = menlove_file, output = path(root, "AGB_cleaned/menlove/menlove_2009-2019.tif"))),
  tar_file_fast(hfbs, clean_hfbs(input = hfbs_file, output = path(root, "AGB_cleaned/hfbs/hfbs_2010.tif"))),
  #these save output as tiles
  tar_file_fast(esa, clean_esa(input = esa_paths, output = path(root, "AGB_cleaned/esa_cci/"))),
  tar_file_fast(ltgnn, clean_ltgnn(input = ltgnn_paths, output = path(root, "AGB_cleaned/lt_gnn/")), pattern = map(ltgnn_paths)),
  tar_file_fast(nbcd, clean_nbcd(input = nbcd_paths, output = path(root, "AGB_cleaned/nbcd/")), pattern = map(nbcd_paths)),
  tar_file_fast(gfw, clean_gfw(input_url = gfw_urls, output = path(root, "AGB_cleaned/gfw/")), pattern = map(gfw_urls)),
  tar_file_fast(icesat, clean_icesat(input_url = icesat_urls, output = path(root, "AGB_cleaned/icesat/")), pattern = map(icesat_urls)),
  
  #create vrt files.
  #These can be used to read in all the tiles as a virtual file system with
  #terra::vrt("<filename>.vrt"). Downstream {targets} workflows should only have
  #to track the one vrt file, which will be updated when new tiles are added or
  #the projetion changes (or any other values tracked in the .vrt file)
  tar_file(esa_vrt, write_vrt(esa, path(root, "AGB_cleaned/esa_cci/esa_2010.2017-2020.vrt"))),
  tar_file(ltgnn_vrt, write_vrt(ltgnn, path(root, "AGB_cleaned/lt_gnn/lt.gnn_1990-2017.vrt"))),
  tar_file(nbcd_vrt, write_vrt(nbcd, path(root, "AGB_cleaned/nbcd/nbcd_2000.vrt"))),
  tar_file(gfw_vrt, write_vrt(gfw, path(root, "AGB_cleaned/gfw/gfw_2000.vrt"))),
  tar_file(icesat_vrt, write_vrt(icesat, path(root, "AGB_cleaned/icesat/icesat_2020.vrt")))
)
