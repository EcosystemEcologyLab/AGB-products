# coding=utf-8

from __init__ import *

datadir = join(data_root, 'Harmonized Forest Biomass Spawn')

def transform_to_COG():
    input = join(datadir, 'tif', 'aboveground_biomass_carbon_2010.tif')
    output = join(datadir, 'tif', 'HFBS_2010.tif')
    if os.path.isfile(output): return output
    gdal.Translate(output, input,format="COG")
    print('done',output)
    return output

if __name__ == '__main__':
    transform_to_COG()
    pass