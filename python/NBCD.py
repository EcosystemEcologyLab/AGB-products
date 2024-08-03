# coding=utf-8

from Python_codes.__init__ import *

class NBCD:
    def __init__(self):
        self.datadir = join(data_root, 'Natl Biomass Carbon Dataset')
        pass

    def run(self):
        self.clip_CA()
        pass

    def reproj(self):
        res = 0.0024 # 240m
        fpath = join(self.datadir,r'NBCD2000_V2_1161\NBCD2000_V2_1161\data\NBCD_countrywide_biomass_240m_raster\NBCD_countrywide_biomass_mosaic.tif')
        outdir = join(self.datadir, 'reproj')
        T.mkdir(outdir, force=True)
        outf = join(outdir, 'NBCD_biomass_wgs84.tif')
        src_wkt = self.wkt_NBCD()
        dst_wkt = self.wkt_84()
        srcSRS = osr.SpatialReference()
        srcSRS.ImportFromWkt(src_wkt)

        dstSRS = osr.SpatialReference()
        dstSRS.ImportFromWkt(dst_wkt)
        dataset = gdal.Open(fpath)
        gdal.Warp(outf, dataset, xRes=res, yRes=res, srcSRS=srcSRS, dstSRS=dstSRS)

        pass

    def clip_AZ(self):
        shp_path = join(this_root,'shp','AZ_shp','az.shp')
        fpath = join(self.datadir, 'reproj', 'NBCD_biomass_wgs84.tif')
        outdir = join(self.datadir, 'clip')
        T.mkdir(outdir, force=True)
        outf = join(outdir, 'NBCD_biomass_wgs84_AZ.tif')
        ToRaster().clip_array(fpath, outf, shp_path)

        pass

    def clip_CA(self):
        shp_path = join(this_root,'shp','CA_shp','ca.shp')
        fpath = join(self.datadir, 'reproj', 'NBCD_biomass_wgs84.tif')
        outdir = join(self.datadir, 'clip')
        T.mkdir(outdir, force=True)
        outf = join(outdir, 'NBCD_biomass_wgs84_CA.tif')
        ToRaster().clip_array(fpath, outf, shp_path)

        pass

    def wkt_NBCD(self):
        wkt_str = '''PROJCRS["USA_Contiguous_Albers_Equal_Area_Conic",
    BASEGEOGCRS["NAD83",
        DATUM["North American Datum 1983",
            ELLIPSOID["GRS 1980",6378137,298.257222101,
                LENGTHUNIT["metre",1]]],
        PRIMEM["Greenwich",0,
            ANGLEUNIT["degree",0.0174532925199433]],
        ID["EPSG",4269]],
    CONVERSION["USA_Contiguous_Albers_Equal_Area_Conic",
        METHOD["Albers Equal Area",
            ID["EPSG",9822]],
        PARAMETER["Latitude of false origin",37.5,
            ANGLEUNIT["degree",0.0174532925199433],
            ID["EPSG",8821]],
        PARAMETER["Longitude of false origin",-96,
            ANGLEUNIT["degree",0.0174532925199433],
            ID["EPSG",8822]],
        PARAMETER["Latitude of 1st standard parallel",29.5,
            ANGLEUNIT["degree",0.0174532925199433],
            ID["EPSG",8823]],
        PARAMETER["Latitude of 2nd standard parallel",45.5,
            ANGLEUNIT["degree",0.0174532925199433],
            ID["EPSG",8824]],
        PARAMETER["Easting at false origin",0,
            LENGTHUNIT["metre",1],
            ID["EPSG",8826]],
        PARAMETER["Northing at false origin",0,
            LENGTHUNIT["metre",1],
            ID["EPSG",8827]]],
    CS[Cartesian,2],
        AXIS["(E)",east,
            ORDER[1],
            LENGTHUNIT["metre",1]],
        AXIS["(N)",north,
            ORDER[2],
            LENGTHUNIT["metre",1]],
    USAGE[
        SCOPE["Not known."],
        AREA["United States (USA) - CONUS onshore - Alabama; Arizona; Arkansas; California; Colorado; Connecticut; Delaware; Florida; Georgia; Idaho; Illinois; Indiana; Iowa; Kansas; Kentucky; Louisiana; Maine; Maryland; Massachusetts; Michigan; Minnesota; Mississippi; Missouri; Montana; Nebraska; Nevada; New Hampshire; New Jersey; New Mexico; New York; North Carolina; North Dakota; Ohio; Oklahoma; Oregon; Pennsylvania; Rhode Island; South Carolina; South Dakota; Tennessee; Texas; Utah; Vermont; Virginia; Washington; West Virginia; Wisconsin; Wyoming."],
        BBOX[24.41,-124.79,49.38,-66.91]],
    ID["ESRI",102003]]'''
        return wkt_str

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
