# coding=utf-8

from Python_codes.__init__ import *

class GFW:
    def __init__(self):
        self.datadir = join(data_root, 'GFW')
        pass

    def run(self):
        self.resample()
        self.merge_tiles()
        self.clip_AZ()
        self.clip_CA()
        pass

    def resample(self):
        res = 0.0024  # 240m
        fdir = join(self.datadir,'tiles')
        outdir = join(self.datadir,'tiles_resample')
        T.mkdir(outdir)
        for f in T.listdir(fdir):
            if not f.endswith('.tif'):continue
            fpath = join(fdir, f)
            out_f = join(outdir, f)
            wkt_str = self.wkt_84()
            SRS = osr.SpatialReference()
            SRS.ImportFromWkt(wkt_str)
            dataset = gdal.Open(fpath)
            gdal.Warp(out_f, dataset, xRes=res, yRes=res, srcSRS=SRS, dstSRS=SRS)
        pass

    def merge_tiles(self):
        # fdir = join(self.datadir,'tiles_resample')
        fdir = join(self.datadir,'tiles')
        outdir = join(self.datadir,'merged')
        T.mkdir(outdir)
        outf = join(outdir,'merged.tif')
        tiles_list = []
        for f in T.listdir(fdir):
            if not f.endswith('.tif'):continue
            fpath = join(fdir, f)
            tiles_list.append(fpath)
        parameters = ['', '-o', outf] + tiles_list
        gdal_merge.gdal_merge(parameters)

    def clip_AZ(self):
        shp_path = join(this_root, 'shp', 'AZ_shp', 'az.shp')
        fdir = join(self.datadir,'merged')
        outdir = join(self.datadir,'merged_clip')
        T.mkdir(outdir)
        for f in T.listdir(fdir):
            if not f.endswith('.tif'):continue
            fpath = join(fdir, f)
            out_f = join(outdir, 'GFW_AZ.tif')
            ToRaster().clip_array(fpath, out_f, shp_path)
        pass

    def clip_CA(self):
        shp_path = join(this_root, 'shp', 'CA_shp', 'ca.shp')
        fdir = join(self.datadir,'merged')
        outdir = join(self.datadir,'merged_clip')
        T.mkdir(outdir)
        for f in T.listdir(fdir):
            if not f.endswith('.tif'):continue
            fpath = join(fdir, f)
            out_f = join(outdir, 'GFW_CA.tif')
            ToRaster().clip_array(fpath, out_f, shp_path)
        pass

    def wkt_84(self):
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
