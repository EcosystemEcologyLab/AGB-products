

# Above-ground Biomass Raster Pre-Processing

<!-- badges: start -->

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

<!-- badges: end -->

The goal of this repository is to do some light pre-processing to
above-ground biomass data products and save them to the “snow” server in
a common format.

Pre-processing steps currently taken:

- Name all layers appropriately
  - If they are years, use the year (e.g. `"2005"`)
  - If they represent a time range, use the time range
    (e.g. `"2005-2010 mean"` or `"2009, 2012-2014 mean"`)
- Convert to units of Mg/ha
- Rasterize vector products
- Save as cloud optimized geotiff(s)

Other possible steps that could be added in the future:

- Re-project to a common CRS
- Include layers besides AGB. For example, some products have layers
  with standard deviation or quality control flags that are currently
  removed during this pre-processing.

## Example Function

In `R/` there is a collection of `clean_*()` functions defined. One of
the simpler ones is for the Xu et al. dataset:

``` r
# Function has arguments for input and output path.  Input might be a directory in the case of multiple tiles
clean_xu <- function(
    input = "/Volumes/moore/Xu/test10a_cd_ab_pred_corr_2000_2019_v2.tif", 
    output = "/Volumes/moore/AGB_cleaned/xu/xu.tif"
) {
  # Read in file(s)
  xu_agb_raw <- terra::rast(input) 
  # Do any necessary conversions or subsetting
  xu_agb <- xu_agb_raw * 2.2 
  # Add metadata including layer names
  units(xu_agb) <- "Mg/ha"
  varnames(xu_agb) <- "AGB"
  names(xu_agb) <- 2000:2019
  
  # Write to COG
  terra::writeRaster(xu_agb, output, filetype = "COG", overwrite = TRUE)
  # Return output path
  output
}
```

If you have snow mounted to `/Volumes/moore/` then all you need to do is
run `clean_xu()` to read in the downloaded raw data, do the processing,
and save it out as a COG to `AGB_cleaned/xu.tif`.

> [!NOTE]
>
> This will actually write two files, `xu.tiff` and a “sidecar” file
> `xu.tiff.aux.json` containing some metadata (just the units in this
> example). `terra::rast("path/to/xu.tiff")` will automatically also
> read in the sidecar file if it is in the same directory.

## Using `targets`

These functions are set up to all be run as part of a `targets` pipeline
using just the command `tar_make()`. The pipeline (defined in
`_targets.R`) tracks both input and output files as well as the code in
the `clean_*()` functions so if there are any changes (e.g. adding a new
tile for the ESA CCI dataset), running `tar_make()` should automatically
update the output data in the `AGB_cleaned/` folder on snow.

## Setup with `renv`

The R package dependencies for this repository are tracked with `renv`.
When you first open this project, you’ll be prompted to install the
dependencies with `renv::restore()`. This will attempt to install the
exact versions of all packages used. Sometimes, especially when a
package needs to be built from source, this will fail. You have the
option of turning off `renv` with `renv::deactivate(clean = TRUE)`,
installing the most recent versions of required R packages (the ones in
`_targets_packages.R`, and then re-initializing `renv` with
`renv::init()`. However, note that changes in R packages could require
you to update code in the cleaning functions or in `_targets.R`.

------------------------------------------------------------------------

Developed in collaboration with the University of Arizona [CCT Data
Science](https://datascience.cct.arizona.edu/) team
