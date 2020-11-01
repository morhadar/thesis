# %%
# flake8: noqa: F403
# %load_ext autoreload
# %autoreload 2
# %matplotlib inline
import pandas as pd
import folium
# import pyproj
import numpy as np
import matplotlib.pyplot as plt
import math
from pathlib import Path

# %%
def concat_omnisol_export_files(csv_list):
    frames =[]
    for f in csv_list:
        frames.append(pd.read_csv(f)) 
    df = pd.concat(frames, ignore_index=True)
    return df

def draw_link_on_map(mymap, df, color='purple'):
    for _ , link in df.iterrows():
        if math.isnan(link['Rx Site Latitude']) or math.isnan(link['Hop Length (KM)']) or link['Hop Length (KM)']==0:
            print('No metadata for link')  # TODO -  print(f'No metadata for link{link['Link Id']}') invalid syntax for some reason.
            continue
        else:
            folium.PolyLine([(link['Rx Site Latitude'], link['Rx Site Longitude']),
                             (link['Tx Site Latitude'],  link['Tx Site Longitude'])], 
                            color=color, opacity=0.7, popup=str(link['Link ID'])).add_to(mymap)
    return mymap

def create_rehovot_map(zoom_start=14):
    def _draw_rectangle_of_rehovot(mymap):
        rehovot_bounds_bltr = [[31.86704, 34.77173], [31.91921, 34.83712]] #[[bottom(lat min), left(long min)], [top(lat max), right(long max)]]
        folium.Rectangle(bounds=rehovot_bounds_bltr, color='#ff7800', fill=True, fill_color='#ffff00', fill_opacity=0.2).add_to(mymap)
        return mymap
    mymap = folium.Map(location=[31.89227, 34.80112], zoom_start=zoom_start, tiles='Stamen Terrain', control_scale=True)
    return _draw_rectangle_of_rehovot(mymap)

def convert_my_meta_data_format_to_omnisol_format(df):
    return df.rename(columns={'hop_name':'Link ID',
                              'length':'Hop Length (KM)',
                              'site1_longitude':'Rx Site Longitude',
                              'site1_latitude':'Rx Site Latitude',
                              'site2_longitude':'Tx Site Longitude',
                              'site2_latitude':'Tx Site Latitude'} )

## from Adam:
def add_rg(mymap, lon_lat_array, popup_string, color='black'):
    # plot RGs' locations
    #TODO - allow chosing color
    folium.Marker(location=lon_lat_array, color=color, popup=popup_string, radius=2, weight=0).add_to(mymap)
    return mymap

def add_radar_marker(mymap):
    radar_lon_lat = [32.006667,34.815000]
    folium.Marker(radar_lon_lat, popup='IMS Radar').add_to(mymap)
    return mymap

def plot_radar_angle(mymap, angles,az_length=0.4):
    az_length = 0.4   
    for _, angle in enumerate(angles):
        end_lat = radar_lon_lat[0] + az_length * math.cos(math.radians(angle))
        end_lon = radar_lon_lat[1] + az_length * math.sin(math.radians(angle))
        folium.PolyLine([radar_lon_lat, [end_lat, end_lon]],
                        color='brown',
                       dash_array='10',
                       popup=str(angle)).add_to(mymap)
    return mymap


# %% draw maps:
#read meta-data:
csv_list = list(Path('data/raw_data/metadata_exported_from_Omnisol_alllinks_around_Rehovot_in_various_dates').glob('*all_links*'))
df = concat_omnisol_export_files(csv_list).drop_duplicates(subset=['Link ID'])
df_smbit_omnisol = df[df['Link Carrier'] == 'SMBIT'] #TODO - partial list from Omnisol
df_cellular = df[~(df['Link Carrier'] == 'SMBIT')]
df_smbit = convert_my_meta_data_format_to_omnisol_format(pd.read_excel('data/raw_data/smbit/meta_data.xlsx'))

#draw maps:
smbit_map = draw_link_on_map(create_rehovot_map(), df_smbit)  # TODO - how to use deepcopy of rehovot map instead of creating it again and again
smbit_map.save('materials/thesis_book/smbit_link_map.html')

cellular_map = draw_link_on_map(create_rehovot_map(), df_cellular[df_cellular['Sampling Period Description']=='24 Hours'])
cellular_map = draw_link_on_map(cellular_map, df_cellular[~(df_cellular['Sampling Period Description']=='24 Hours')], color='orange')
cellular_map.save('materials/thesis_book/cellular_link_map.html')

rg_map = add_rg(create_rehovot_map(zoom_start=12), [31.78931, 34.79973],'Hafetz Haim','red')
rg_map = add_rg(rg_map, [32.0073, 34.81395], 'Beit Dagan', 'red')
rg_map = add_rg(rg_map, [31.83161, 34.95598], 'Nahshon', 'red')
rg_map = add_rg(rg_map, [31.81398, 34.7191], 'Kvutzat Yavne', 'red')
rg_map.save('materials/thesis_book/rain_gauges_map.html')

# %% distribution of lengths:
bins = np.arange(0,4.5,0.1)
# df_smbit[['Hop Length (KM)']].plot.hist(bins=bins, title="Rehovot Smart City Network Hops' length distributaion").set(xlabel='Length [km]', ylabel='Count')
# df_cellular[['Hop Length (KM)']].plot.hist(bins=bins, title="Cellular Networks Hops' length distributaion").set(xlabel='Length [km]', ylabel='Count')

plt.figure(figsize=(8,6))
plt.hist(df_smbit['Hop Length (KM)'].values, bins=bins, alpha=0.5, label="Rehovot Smart City Network")
plt.hist(df_cellular['Hop Length (KM)'].values, bins=bins, alpha=0.5, label="Cellular Networks")
plt.xlabel('Length [km]', size=14)
plt.ylabel('Count', size=14)
plt.title("Hops' length distributaion")
plt.legend(loc='upper right')
plt.savefig('materials/thesis_book/hops_length_distribution.png')


# %% distribution of frequencies:
bins = np.arange(10,90,1)
# df_smbit[['Hop Length (KM)']].plot.hist(bins=bins, title="Rehovot Smart City Network Hops' length distributaion").set(xlabel='Length [km]', ylabel='Count')
# df_cellular[['Hop Length (KM)']].plot.hist(bins=bins, title="Cellular Networks Hops' length distributaion").set(xlabel='Length [km]', ylabel='Count')

plt.figure(figsize=(8,6))
plt.hist(np.concatenate((df_smbit['uplink_frequency'].values, df_smbit['downlink_frequency'].values)), bins=bins, alpha=0.5, label="Rehovot Smart City Network")
plt.hist((df_cellular['Link Frequency [MHz]'].values/1000), bins=bins, alpha=0.5, label="Cellular Networks")
plt.xlabel('Frequency [GHz]', size=14)
plt.ylabel('Count', size=14)
plt.title("Hops' frequencies distributaion")
plt.legend(loc='upper right')
plt.savefig('materials/thesis_book/hops_frequencies_distribution.png')


# %% find Rehovot lat lon:
longitudes = np.concatenate((df_smbit['Rx Sit Longitude'].values, df_smbit['Tx Site Longitude'].values))
longitudes = longitudes[~ (longitudes==0)]

latitutde = np.concatenate((df_smbit['Rx Site Latitude'].values, df_smbit['Tx Site Latitude'].values))
latitutde = latitutde[~ (latitutde==0)]

tlbr = [longitudes.min(), latitutde.max(),  longitudes.max(), latitutde.min()]
print(tlbr)

bltr = [[latitutde.min(), longitudes.min()], [latitutde.max(),  longitudes.max()]]
print(bltr)
# %%
