## Adding a new data product

Currently, the raw files for data products are in folder in the `moore/` folder on the 'Snow' server (which you will need to get access to from Andy Honaker).
On a mac, this mounts at `/Volumes/moore/`.
Download the file or files for the data product to the root level of this directory.

## Data wrangling

If the raw data is tiled (i.e. it comes as multiple .tifs representing different geographic areas), create functions that work on a **single tile**.
Wrangling functions should do the following:

1.  Take two arguments, `input` and `output` which are specified as full file paths
2.  Read in the raw data
3.  Convert units if necessary to Mg/ha
4.  If there are multiple years of data, they should be represented as layers
5.  Name layers after the year or years they represent
6.  If input data is in vector format, rasterize to a reasonable resolution
7.  Create the output directory if necessary
8.  Write out as a cloud-optimized GEOtiff using the "COG" GDAL driver
9.  **Return the output file path if successful**

Currently, we are not re-projecting data to a common CRS or merging tiles.
These steps are done in downstream workflows when necessary.

### Naming things

For each data product, choose a unique short name that is all lowercase with no spaces (underscores are ok).
The output path should be, e.g., `/Volumes/moore/AGB_cleaned/<short_name>/<short_name>_1990-2000.tif` replacing the years with the range of that particular data product.
If tiled, the output file name should be constructed to include some kind of tile identifier, ideally matching the raw data.
E.g. `<short_name>_h01v10_1990-2000.tif`.

The function that does the data wrangling should be named `clean_<short_name>`.
Each data wrangling function should be in its own file named `clean_<short_name>.R` or `clean_<short_name>.py`.

### R

If you write the wrangling function in R, we recommend using the `terra` package for spatial data manipulation and writing.
Feel free to use `roxygen2` style comments Here's a relatively simple example:

``` r
#' Read and clean Xu et al. dataset
#'
#' @param input path to file to read in, "test10a_cd_ab_pred_corr_2000_2019_v2.tif"
#' @param output path to save the processed data including file extension
#'
#' @return path to saved raster
#' 
#' @examples
#' clean_xu()
#'  
clean_xu <- function(input = "/Volumes/Projects/moore/Xu/test10a_cd_ab_pred_corr_2000_2019_v2.tif", 
                     output = "/Volumes/Projects/moore/AGB_cleaned/xu/xu_2000-2019.tif") {
  # Create output dir (if not already there)
  fs::dir_create(fs::path_dir(output))
  # Read in data
  xu_agb_raw <- terra::rast(input) 
  #conversion from MgC/ha to Mg/ha
  xu_agb <- xu_agb_raw * 2.2 
  #add metadata
  units(xu_agb) <- "Mg/ha"
  varnames(xu_agb) <- "AGB"
  names(xu_agb) <- 2000:2019
  
  # Write to COG
  terra::writeRaster(xu_agb, output, filetype = "COG", overwrite = TRUE)
  
  # return the output filepath
  output
}
```

See other examples in `R/`.

### Python

If you write a wrangling function in Python, follow the same guidelines.
Here's the equivalent python version of the above function using the `rioxarray` library.

``` python
import rioxarray

def clean_xu(input = "/Volumes/moore/Xu/test10a_cd_ab_pred_corr_2000_2019_v2.tif", 
             output = "/Volumes/moore/AGB_cleaned/xu/xu_2000-2019.tif"):
    #TODO: create output directory if it doesn't exist
    # Read in data
    xu = rioxarray.open_rasterio(input)
    # conversion from MgC/ha to Mg/ha
    xu = xu * 2.2
    # add metadata
    xu.attrs["long_name"] = [str(i) for i in range(2000, 2019 + 1)]

    # Write out as COG and return out path
    xu.rio.to_raster(output, driver = "COG")
    return output
```

Place python scripts in `python/`

## Connecting it up to the workflow

This repository uses the `targets` R package for workflow management.
The entire pipeline can be run with the R command `targets::tar_make()` and it will skip any steps that do not need to be re-run.
Visualize the workflow with `targets::tar_glimpse()` or `targets::tar_visnetwork()`.

To add your new function to the workflow, you'll have to edit `_targets.R` .
Each step in the workflow is called a "target" and defined by a function that starts with `tar_` such as `tar_target()` or `tar_file_fast()`.
There are targets to track the input files for changes, and targets that do the wrangling and track the output file paths for changes.

### If not tiled

Add a target that looks like

```         
tar_file_fast(<short_name>_file, path(root, "raw_data/raw_data.tif"))
```

And a target that looks like

```         
tar_file_fast(<short_name>, clean_<short_name>(input = <short_name>_file))
```

### If tiled

It's a little more complicated because we need to iterate over all the tiles, applying the cleaning function to each one.
You can use `tar_files()` with a directory to create a list of files to iterate over.
Then for the downstream target, use the `pattern = map(<short_name>_files)` argument.
For example:

``` r
# get paths to all the input files (.zip in this case)
tar_files(ltgnn_paths, fs::dir_ls(path(root, "LT_GNN"), glob = "\*.zip"), format = "file_fast"),

# apply `clean_ltgnn()` to all paths
tar_file_fast(ltgnn, clean_ltgnn(ltgnn_paths), pattern = map(ltgnn_paths))
```

### Python functions

Integrating python functions is trickier because they cannot be sourced at the top of `_targets.R` like the R functions because of the way `reticulate` works (python functions contain external pointers that are only valid in the current R session).
Instead, one must create a target to track the python script for changes (so the code is re-run if changes are made to the function), and in the target that does the wrangling, source the python script target with `reticulate::source_python()`

For example:

``` r
#track input file for changes
tar_file_fast(xu_file, path(root, "Xu/test10a_cd_ab_pred_corr_2000_2019_v2.tif")),

#track python code for changes
tar_file_fast(xu_py, "python/clean_xu.py"),

#clean and save output
tar_file_fast(
  xu,
  command = {
    reticulate::source_python(xu_py)
    clean_xu(xu_file)
  }
)
```

## Running it

Install all dependencies with `renv::restore()` (the `renv` package should install itself when you first open the R project).
Run the pipeline with `targets::tar_make()` .
