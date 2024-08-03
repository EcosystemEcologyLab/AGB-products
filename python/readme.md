# Python codes for pre-processing AGB products
## The 4 new datasets include:
- GFW
- Harmonized Forest Biomass Spawn
- ICESat-2 Boreal Biomass
- Natl Biomass Carbon Dataset

## Pre-processing steps were taken:

- Reproject to WGS-84
  - NBCD
- Merge tiles
  - GFW
- Turn point data to raster format
  - ICEsat
- Convert unit to Mg/ha
- Clip AZ/CA
- Saved as tif format

## Setup with the Python Dependencies
```bash
conda install numpy
conda install pandas
conda install gdal
conda install scipy
conda install netCDF4
conda install matplotlib
conda install finoa
pip install lytools
```

