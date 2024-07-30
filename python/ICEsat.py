# coding=utf-8

from Python_codes.__init__ import *

class ICEsat:

    def __init__(self):
        self.datadir = join(data_root, 'ICESat-2 Boreal Biomass')
        res = 0.01
        self.D = DIC_and_TIF(pixelsize=res)
        pass

    def run(self):
        self.point_to_dict()
        self.dict_to_tif()
        pass

    def point_to_dict(self):
        outdir = join(self.datadir,'point_to_dict')
        T.mkdir(outdir)
        lon_col = 'lon'
        lat_col = 'lat'
        year_col = 'YEAR'
        doy_col = 'DOY'
        lc_col = 'seg_landcov'
        value_col = 'AGB_mean_mg_ha'
        fpath = join(self.datadir,'gpkg','IS2ATBABD_20190501_20210930_v01.gpkg')
        layer = fiona.open(fpath)
        # print(len(layer));exit()
        for feature in layer:
            geometry = feature['geometry']
            properties = feature['properties']
            for p in properties:
                print(p, properties[p])
            break

        value_dict_all = {}
        flag = 0
        spatial_dict = {}
        for feature in tqdm(layer):
            geometry = feature['geometry']
            properties = feature['properties']
            lon = properties[lon_col]
            lat = properties[lat_col]
            pix = self.D.lon_lat_to_pix([lon], [lat])[0]
            if not pix in spatial_dict:
                spatial_dict[pix] = []
            year = properties[year_col]
            value = properties[value_col] # AGB_mean_mg_ha
            spatial_dict[pix].append(value)
            value_dict = {
                'lon': lon,
                'lat': lat,
                'year': year,
                'value': value
            }
        # outf = join(outdir,'spatial_dict')
        T.save_distributed_perpix_dic(spatial_dict, outdir)
        # T.save_npy(spatial_dict, outf)

    def dict_to_tif(self):
        outdir = join(self.datadir,'tif')
        T.mkdir(outdir)
        fdir = join(self.datadir,'point_to_dict')
        spatial_dict = {}
        for f in tqdm(T.listdir(fdir)):
            fpath = join(fdir,f)
            spatial_dict_i = T.load_npy(fpath)
            for pix in spatial_dict_i:
                vals = spatial_dict_i[pix]
                spatial_dict[pix] = np.nanmean(vals)
        outf = join(outdir,'ICEsat_AGB.tif')
        self.D.pix_dic_to_tif(spatial_dict, outf)
