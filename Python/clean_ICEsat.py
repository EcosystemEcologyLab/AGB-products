# coding=utf-8
from __init__ import *

datadir = join(data_root, 'ICESat-2 Boreal Biomass')
res = 0.01 # 1km
originX = -180
endX = 180
originY = 90
endY = -90
pixelWidth, pixelHeight = res, -res
rows = int((endY - originY) / pixelHeight)
cols = int((endX - originX) / pixelWidth)

def lon_lat_to_pix(lon_list, lat_list, isInt=True):
    pix_list = []
    for i in range(len(lon_list)):
        lon = lon_list[i]
        lat = lat_list[i]
        if lon > 180 or lon < -180:
            success_lon = 0
            c = np.nan
        else:
            c = (lon - originX) / pixelWidth
            if isInt == True:
                c = int(c)
            success_lon = 1

        if lat > 90 or lat < -90:
            success_lat = 0
            r = np.nan
        else:
            r = (lat - originY) / pixelHeight
            if isInt == True:
                r = int(r)
            success_lat = 1
        if success_lat == 1 and success_lon == 1:
            pix_list.append((r, c))
        else:
            pix_list.append(np.nan)

    pix_list = tuple(pix_list)
    return pix_list

def pix_dic_to_spatial_arr(spatial_dic):
    spatial_arr = []
    for r in tqdm(range(rows)):
        temp = []
        for c in range(cols):
            key = (r, c)
            if key in spatial_dic:
                val_pix = spatial_dic[key]
                temp.append(val_pix)
            else:
                temp.append(np.nan)
        spatial_arr.append(temp)
    spatial_arr = np.array(spatial_arr, dtype=float)
    return spatial_arr

def gpkg_point_to_tif():
    input = join(datadir,'gpkg','IS2ATBABD_20190501_20210930_v01.gpkg')
    outdir = join(datadir,'tif')
    mkdir(outdir)
    output = join(outdir,'ICEsat_AGB_temporary_file.tif')
    if os.path.isfile(output):return

    lon_col = 'lon'
    lat_col = 'lat'
    year_col = 'YEAR'
    doy_col = 'DOY'
    lc_col = 'seg_landcov'
    value_col = 'AGB_mean_mg_ha'
    layer = fiona.open(input)
    # print(len(layer));exit()
    for feature in layer:
        geometry = feature['geometry']
        properties = feature['properties']
        for p in properties:
            print(p, properties[p])
        break

    flag = 0
    spatial_dict = {}
    for feature in tqdm(layer):
        geometry = feature['geometry']
        properties = feature['properties']
        lon = properties[lon_col]
        lat = properties[lat_col]
        pix = lon_lat_to_pix([lon], [lat])[0]
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

    spatial_dict_mean = {}
    for pix in tqdm(spatial_dict,desc='mean'):
        vals = spatial_dict[pix]
        vals = np.array(vals)
        spatial_dict_mean[pix] = np.nanmean(vals)
    spatial_array = pix_dic_to_spatial_arr(spatial_dict_mean)
    grid_nan = np.isnan(spatial_array)
    grid = np.logical_not(grid_nan)
    spatial_array[np.logical_not(grid)] = -999999
    array2raster(output, originX, originY, pixelWidth, pixelHeight, spatial_array)

def transform_to_COG():
    input = join(datadir, 'tif', 'ICEsat_AGB_temporary_file.tif')
    output = join(datadir, 'tif','ICEsat-AGB_2020.tif')
    if os.path.isfile(output): return output
    gdal.Translate(output, input,format="COG")
    print('done',output)
    return output


def main():
    gpkg_point_to_tif()
    transform_to_COG()

if __name__ == '__main__':
    main()