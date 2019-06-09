import os
import sys
from pathlib import Path
import json
import pandas as pd
import h5py
import scipy.io

hop_link_mapping_file = Path('C:/Users/mhadar/Documents/personal/thesis_materials/data/smbit/meta_data_1.xlsx')
meta_data_file = Path('C:/Users/mhadar/Documents/personal/thesis_materials/data/smbit/meta_data_2.xlsx')
geo_location_file = Path('C:/Users/mhadar/Documents/personal/thesis_materials/data/smbit/meta_data_3.xlsx')
db_path3 = Path('../../thesis_materials/data/smbit/packet3_tmp/')

hop_link_mapping = pd.read_excel(meta_data_name_hops_mapping_file , sheet_name=0)
meta_data = pd.read_excel(meta_data_file , sheet_name=0)
geo_location = pd.read_excel(geo_location_file , sheet_name=0)

f = h5py.File('C:/Users/mhadar/Documents/personal/thesis/matlab/db.h5','a')
f['muni_leonardo']  
data = f.get('data/variable1') 
data = np.array(data) # For converting to numpy array
for key in f.keys():
    print(key)
print(f.keys())
    
#TODO -  make it appandable
f =  h5py.File("t1", "a")
db3 = {}
#f = pd.HDFStore('store4.h5', mode='a')
#init
if(1):
    for i in meta_data.index:
        link_name = meta_data.get_value(i,'link_name');
        hop_num = "%.1f" % meta_data.get_value(i,'hop_num')
        #g = f.create_dataset('hop' + hop_num + '/' + link_name , pd.DataFrame() )
        db3[link_name] = pd.DataFrame()
       # g.attrs['length'] = meta_data.get_value(i,'length_KM')
        #g.attrs['iteam_id'] = meta_data.get_value(i,'item_id')
        #g.attrs['transmitter'] = meta_data.get_value(i,'transmitter')
        #g.attrs['transmitter_location'] = meta_data.get_value(i,'transmitter_location')
        #g.attrs['receiver'] = meta_data.get_value(i,'receiver')
        #g.attrs['receiver_location'] = meta_data.get_value(i,'receiver_location')
    
error_list =[]
for file in db_path3.glob('**/*.txt') :
    json_data = open(file).read().replace('\'' , '"') #workaround since our json files are not valid.
    if json_data == 'None':
        error_list.append(file)
        continue
    data = json.loads(json_data)
    data = pd.io.json.json_normalize(data)
    for i in data.index:
        link_name = data(i,'name')
        timestamp = int(data.get_value(i, 'siklu.rssavg.timestamp'))
        rssi = int((data.get_value(i, 'siklu.rssavg.lastvalue')) #TODO - make sure this is indeed int
        db3[link_name] = dictina
    
f.close()
f2.close()

    
    


#for month_dir in [db_path3 / x  for x in db_months]:
#    [day_dir for day_dir in month_dir.iterdir() if day_dir.is_dir()]
#    for [file for file in day_dir.iterdir() is file.isfile()]:
#t = month_dir.glob('/*')
#
#t = 'smbitData_2018_05_08_11_56_19_265450.txt'
##with open(t,"r") as fp:
##    a = json.loads(fp)
##    print(a)
#    
#json_data=open(t).read().replace("'", '"')
#
#data = json.loads(json_data)
#print(data)
#pd.io.json.json_normalize(data)