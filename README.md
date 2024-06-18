

The goal of this repository is to do some light pre-processing to
above-ground biomass data products and save them to the “snow” server in
a common format.

Preprocessing steps to be done:

- Name all layers appropriately

  - If they are years, use the year (e.g. `"2005"`)

  - If they represent a time range, use the time range
    (e.g. `"2005-2010"` or `"2009, 2012-2014"`)

  - ❔If they are something other than AGB, append that to the year
    (e.g. `"2005_SD"` , `"2005_MEAN"`

- Convert to units of Mg/ha

- ❔Project to the same CRS

- ❔Rasterize vector products

- ❔Merge tiles into a single file

## Example

In `R/` there is a collection of `clean_*()` functions defined. One of
the simpler ones is for the Xu et al. dataset:

``` r
clean_xu <- function(input = "Xu/test10a_cd_ab_pred_corr_2000_2019_v2.tif", 
                     output = "AGB_cleaned/xu.tif",
                     root = "/Volumes/moore/") {
  # Xu
  input_path <- fs::path(root, input)
  output_path <- fs::path(root, output)
  xu_agb_raw <- terra::rast(input_path) 
  #conversion from MgC/ha to Mg/ha
  xu_agb <- xu_agb_raw * 2.2 
  units(xu_agb) <- "Mg/ha"
  names(xu_agb) <- 2000:2019
  varnames(xu_agb) <- "AGB"
  
  # Write to COG
  terra::writeRaster(xu_agb, output_path, filetype = "COG", overwrite = TRUE)
  return(output_path)
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

Eventually, these functions may become part of a `targets` pipeline that
will only re-run the pre-processing function if there have been changes
in the function or the raw data file(s).
