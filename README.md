

The goal of this repository is to do some light pre-processing to
above-ground biomass data products and save them to the “snow” server in
a common format.

Preprocessing steps to be done:

- Name all layers appropriately

  - If they are years, use the year (e.g. `"2005"`)

  - If they represent a time range, use the time range
    (e.g. `"2005-2010"` or `"2009, 2012-2014"`)

  - If they are something other than AGB, append that to the year
    (e.g. `"2005_SD"` , `"2005_MEAN"`

- Convert to units of Mg/ha

- ❔Project to the same CRS

- ❔Rasterize vector products

- ❔Merge tiles into a single file
