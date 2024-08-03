# coding=utf-8

import os
from osgeo import gdal
from osgeo import osr
import osgeo_utils.gdal_merge as gdal_merge
import fiona
from tqdm import tqdm
import numpy as np

data_root = 'D:/projects/moore/'


def join(*args): # for windows
    args_new = []
    for path in args:
        path_new = path.replace('\\','/')
        args_new.append(path_new)
    outstr = '/'.join(args_new)
    return outstr

def mkdir(dir, force=True):
    if not os.path.isdir(dir):
        if force == True:
            os.makedirs(dir)
        else:
            os.mkdir(dir)

def array2raster(newRasterfn, longitude_start, latitude_start, pixelWidth, pixelHeight, array, ndv=-999999):
    cols = array.shape[1]
    rows = array.shape[0]
    originX = longitude_start
    originY = latitude_start
    # open geotiff
    driver = gdal.GetDriverByName('GTiff')
    if os.path.exists(newRasterfn):
        os.remove(newRasterfn)
    outRaster = driver.Create(newRasterfn, cols, rows, 1, gdal.GDT_Float32)
    outRaster.SetGeoTransform((originX, pixelWidth, 0, originY, 0, pixelHeight))
    outband = outRaster.GetRasterBand(1)

    outband.SetNoDataValue(ndv)
    outband.WriteArray(array)
    outRaster.SetProjection(wkt_84())
    # Close Geotiff
    outband.FlushCache()
    del outRaster


def raster2array(rasterfn):
    '''
    create array from raster
    Agrs:
        rasterfn: tiff file path
    Returns:
        array: tiff data, an 2D array
    '''
    raster = gdal.Open(rasterfn)
    geotransform = raster.GetGeoTransform()
    originX = geotransform[0]
    originY = geotransform[3]
    pixelWidth = geotransform[1]
    pixelHeight = geotransform[5]
    band = raster.GetRasterBand(1)
    array = band.ReadAsArray()
    array = np.asarray(array)
    del raster
    return array, originX, originY, pixelWidth, pixelHeight

def wkt_84():
    wkt_str = '''GEOGCRS["WGS 84",
ENSEMBLE["World Geodetic System 1984 ensemble",
    MEMBER["World Geodetic System 1984 (Transit)"],
    MEMBER["World Geodetic System 1984 (G730)"],
    MEMBER["World Geodetic System 1984 (G873)"],
    MEMBER["World Geodetic System 1984 (G1150)"],
    MEMBER["World Geodetic System 1984 (G1674)"],
    MEMBER["World Geodetic System 1984 (G1762)"],
    MEMBER["World Geodetic System 1984 (G2139)"],
    ELLIPSOID["WGS 84",6378137,298.257223563,
        LENGTHUNIT["metre",1]],
    ENSEMBLEACCURACY[2.0]],
PRIMEM["Greenwich",0,
    ANGLEUNIT["degree",0.0174532925199433]],
CS[ellipsoidal,2],
    AXIS["geodetic latitude (Lat)",north,
        ORDER[1],
        ANGLEUNIT["degree",0.0174532925199433]],
    AXIS["geodetic longitude (Lon)",east,
        ORDER[2],
        ANGLEUNIT["degree",0.0174532925199433]],
USAGE[
    SCOPE["Horizontal component of 3D system."],
    AREA["World."],
    BBOX[-90,-180,90,180]],
ID["EPSG",4326]]'''
    return wkt_str
