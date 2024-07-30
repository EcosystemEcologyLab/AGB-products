# coding=utf-8

from Python_codes.__init__ import *

class Harmonized_Forest_Biomass_Spawn:

    def __init__(self):
        self.datadir = join(data_root, 'Harmonized Forest Biomass Spawn')
        pass

    def run(self):
        self.clip_AZ()
        self.clip_CA()
        pass

    def clip_AZ(self):
        shp_path = join(this_root, 'shp', 'AZ_shp', 'az.shp')
        fdir = join(self.datadir,'tif')
        outdir = join(self.datadir,'tif_clip')
        T.mkdir(outdir)
        for f in T.listdir(fdir):
            if not f.endswith('.tif'):continue
            fpath = join(fdir, f)
            out_f = join(outdir, 'HFBS_AZ.tif')
            ToRaster().clip_array(fpath, out_f, shp_path)
        pass

    def clip_CA(self):
        shp_path = join(this_root, 'shp', 'CA_shp', 'ca.shp')
        fdir = join(self.datadir,'tif')
        outdir = join(self.datadir,'tif_clip')
        T.mkdir(outdir)
        for f in T.listdir(fdir):
            if not f.endswith('.tif'):continue
            fpath = join(fdir, f)
            out_f = join(outdir, 'HFBS_CA.tif')
            ToRaster().clip_array(fpath, out_f, shp_path)
        pass
