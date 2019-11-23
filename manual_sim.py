from __future__ import unicode_literals, print_function
import sys
import traceback
#import os
import random
import datetime as dt

#import matplotlib
import matplotlib.pyplot as plt
#import matplotlib.colors as colors
#import matplotlib.cm as cmx
import mplleaflet

#import get_radar_rain_fn as get_radar_rain
#from mpl_toolkits.basemap import Basemap
import pandas as pd
import numpy as np

from math import radians, cos, sin, asin, sqrt
from pyproj import Proj, transform

import scipy.integrate as integrate
import scipy.interpolate as interpolate
import scipy.spatial.qhull as qhull
from scipy.interpolate import interp1d
from pathlib import Path
def split_at(s, c, n):
    '''Function for splitting strings (first arg). The last argument is the position of the
        selected seperator (second arg) in the string.'''
    words = s.split(c)
    return c.join(words[:n]), c.join(words[n:])

#sys.path.append("/Users/adameshel/Documents/Python_scripts/wrf_hydro_pyscripts/") 
#from helper_functions import split_at

def fast_interpolate(values, tri, uv, d=2, fill_value=0.0):
    simplex = tri.find_simplex(uv)
    vertices = np.take(tri.simplices, simplex, axis=0)
    temp = np.take(tri.transform, simplex, axis=0)
    delta = uv- temp[:, d]
    bary = np.einsum('njk,nk->nj', temp[:, :d, :], delta)
    wts = np.hstack((bary, 1.0 - bary.sum(axis=1, keepdims=True))) # weights
    ret = np.einsum('nj,nj->n', np.take(values, vertices), wts)
    ret[np.any(wts < 0, axis=1)] = fill_value
    return ret


def haversine(lon1, lat1, lon2, lat2):
    """Calculate the great circle distance between two points
    on the earth (specified in decimal degrees)
    """
    # convert decimal degrees to radians
    lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])
    # haversine formula
    dlon = lon2 - lon1
    dlat = lat2 - lat1
    a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
    c = 2 * asin(sqrt(a))
    km = 6367 * c
    return km


def power_law_a_b(f_GHz, pol, approx_type='ITU'):
    ### function from pycomlink library: https://github.com/pycomlink ###
    """Approximation of parameters for A-R relationship
    
    f_GHz : int, float or np.array of these Frequency of the microwave link in GHz (1GHz to 100GHz)
    pol : str Polarization of the microwave link 'h'/'H'/'v'/'V'
    approx_type : str, optional
            Approximation type (the default is 'ITU', which implies parameter
            approximation using a table recommanded by ITU)
            
    Returns a,b : float Parameters of A-R relationship      
    References
    ----------
    .. [4] ITU, "ITU-R: Specific attenuation model for rain for use in 
        prediction methods", International Telecommunication Union, 2013 
         
    """
    f_GHz = np.asarray(f_GHz)
    if f_GHz.min() < 1 or f_GHz.max() > 100:
        raise ValueError('Frequency must be between 1 Ghz and 100 GHz.')
    else:
        if pol == 'V' or pol == 'v':
            f_a = interp1d(ITU_table[0, :], ITU_table[2, :], kind='cubic')
            f_b = interp1d(ITU_table[0, :], ITU_table[4, :], kind='cubic')
        elif pol == 'H' or pol == 'h':
            f_a = interp1d(ITU_table[0, :], ITU_table[1, :], kind='cubic')
            f_b = interp1d(ITU_table[0, :], ITU_table[3, :], kind='cubic')
        else:
            ValueError('Polarization must be V, v, H or h.')
        a = f_a(f_GHz)
#        a = 1
        b = f_b(f_GHz)
    return a, b

ITU_table = np.array([
  [1.000e+0, 2.000e+0, 4.000e+0, 6.000e+0, 7.000e+0, 8.000e+0, 1.000e+1, 
   1.200e+1, 1.500e+1, 2.000e+1, 2.500e+1, 3.000e+1, 3.500e+1, 4.000e+1, 
   4.500e+1, 5.000e+1, 6.000e+1, 7.000e+1, 8.000e+1, 9.000e+1, 1.000e+2],
  [3.870e-5, 2.000e-4, 6.000e-4, 1.800e-3, 3.000e-3, 4.500e-3, 1.010e-2,
   1.880e-2, 3.670e-2, 7.510e-2, 1.240e-1, 1.870e-1, 2.630e-1, 3.500e-1, 
   4.420e-1, 5.360e-1, 7.070e-1, 8.510e-1, 9.750e-1, 1.060e+0, 1.120e+0],
  [3.520e-5, 1.000e-4, 6.000e-4, 1.600e-3, 2.600e-3, 4.000e-3, 8.900e-3,
   1.680e-2, 3.350e-2, 6.910e-2, 1.130e-1, 1.670e-1, 2.330e-1, 3.100e-1,
   3.930e-1, 4.790e-1, 6.420e-1, 7.840e-1, 9.060e-1, 9.990e-1, 1.060e+0],
  [9.120e-1, 9.630e-1, 1.121e+0, 1.308e+0, 1.332e+0, 1.327e+0, 1.276e+0,
   1.217e+0, 1.154e+0, 1.099e+0, 1.061e+0, 1.021e+0, 9.790e-1, 9.390e-1,
   9.030e-1, 8.730e-1, 8.260e-1, 7.930e-1, 7.690e-1, 7.530e-1, 7.430e-1],
  [8.800e-1, 9.230e-1, 1.075e+0, 1.265e+0, 1.312e+0, 1.310e+0, 1.264e+0, 
   1.200e+0, 1.128e+0, 1.065e+0, 1.030e+0, 1.000e+0, 9.630e-1, 9.290e-1,
   8.970e-1, 8.680e-1, 8.240e-1, 7.930e-1, 7.690e-1, 7.540e-1, 7.440e-1]])
 
    
def force_quantization(values, Q = 0.3):
    ''' force quantization Q on values (an array/matrix),
    this is done after noise was added to the values '''
    if type(values) is not np.ndarray:
        # values is a scalar and not a vector/matrix
        values = np.array([values])
    
    return Q*np.round(values/Q)


def path_loss_atten(length, freq, gain = 0):
    ''' calculate the attenuation of a link due to path loss
    see en.wikipedia.org/wiki/Free-space_path_loss for details '''    
    # convert=length*freq*(10**12) #conversion units - GHz*km to Hz*m
    # length in KM, freq in GHz, gain in dB
    path_loss = 20*np.log10(length*freq) + 92.45 + gain
    return path_loss


def add_noise(values, percent, dist, flag = 0):
    ''' add gaussian/rayleigh noise to an array of values 
    values - an array of attenuation values (numpy array).
    dist - the noise distribution, gaussian or rayleigh.
    percent(0 up to 1) - the standard deviation (sigma) is set to be
    a percent of  the mean(values).
    flag- change the default dist. of the noise by assigning 1'''
    
    if type(values) is not np.ndarray:
        # values is a scalar and not a vector/matrix
        values = np.array([values])
    
    mean = np.mean(values)
    sigma = percent * mean
    negative_values = np.full(values.shape,False)
    
    if flag!=0:
        sigma = np.sqrt((0.1**2.0)/12.0) # this number is np.sqrt((0.1**2)/12)
    if dist == 'Gaussian':
        noise = np.random.normal(loc = 0, scale = sigma, size = values.shape)
    elif dist == 'Rayleigh':
        noise = np.random.rayleigh(sigma,values.shape)
    else:
        noise = np.full(values.shape,0)

    
    values = noise + values # add noise to the attenuation values
    negative_values[values < 0] = True # indicator array for negative values
    values[values < 0] = 0 # set all negative values to 0
    
    return values, negative_values


def rain_to_atten(rain_func, length, xa, ya, xb, yb, ITU_a, ITU_b):
    ''' calculate the attentuation from 
    the rain rate[mm/h] along a link using the power law.
    
    rain_func - the rain rate in mm/h at a certain point (x,y) on the world map.
    length - the link's length in meters.
    (xa,ya) - location of site_a of the link.
    (xb,yb) - location of site_b of the link.
    ITU_a - power law parameter calculated 
    for the links's frequency and polarization.
    ITU_b - power law parameter calculated 
    for the links's frequency and polarization.'''
    
    #parameterization for rain function#
    def R(t):
        return rain_func(xa + (t/length)*(xb - xa), ya + (t/length)*(yb - ya))
    
    #attenuation per meter function#
    def dA(t):
        return ITU_a * (R(t)**ITU_b)
    
    # integrate the rain rate along the link's length
    if length > 0.01: 
        # this is a preliminary way of inserting gauges in mid links in 
        #addition to links. T
        A = integrate.quad(dA, 0, length)
    else:
        A = np.array([rain_func(xa , ya)])
    return A[0]  # A[1] is the error
    
    #return A[0]  # A[1] is the error


def atten_to_rain(A, length, ITU_a, ITU_b):
    ''' calculate the average* rain rate from
    the attentuation of a link using the inverse power law. 
    
    A - the attenuation of the link (without free path loss)
    length - the link's length in meters.
    ITU_a - power law parameter calculated 
    for the links's frequency and polarization.
    ITU_b - power law parameter calculated 
    for the links's frequency and polarization.'''
    
    # use inverse power law to calculate the average rain rate R from the attenuation A
    # R = (A/(length*a))**(1/b)
    
    return (A/(length*ITU_a))**(1.0/ITU_b)  
    
def fog_to_atten(fog_func, length, xa, ya, xb, yb,
                 frequency, temperature=25, formula='rayleigh'):
    ''' calculate the attentuation from fog along a link.
    based on "Atmospheric Attenuation due to Humidity"
    Vilnius University, Faculty of Physics
    https://pdfs.semanticscholar.org/0622/3ee45d1ee7f1347e4851e14b834fcba7a1e4.pdf
    
    fog_func - the water content along the link [g/m^3]
    length - the link's length in meters.
    (xa,ya) - location of site_a of the link.
    (xb,yb) - location of site_b of the link.
    frequency - the frequency of the link [GHz]
    temperature - temperature in range -8 to 25 [celsius]
    formula - the approximation to use, either "rayleight" or "mie"
    '''
    # wavelength - wavelength of the link [mm] in range 3mm to 3cm
    refractive_index = 1.0 # unitless
    speed_of_light = 299792458.0 / refractive_index  # meter/sec
    wavelength = (speed_of_light / frequency) * 10 # in milimeters
                                          
    #parameterization for fog function (water content)#
    def dA(t):
        return fog_func(xa + (t/length)*(xb - xa), ya + (t/length)*(yb - ya))
    
    # dA is the attenuation per meter per g/meter^3 function
    
    if formula == 'mie': # based on mie scattering
        coeff = -1.347 + 0.0372*wavelength + 18.0/wavelength - 0.022*temperature
    elif formula == 'rayleigh': # based on rayleigh approx
        T = temperature + 273.15 # T in kelvin
        theta = (300.0/T)
        theta_power = 7.8087 - (0.01565*frequency) - (3.0730e-4*(frequency**2))
        coeff = 6.0826e-4 * frequency**(-1.8963) * (theta ** theta_power)
        
    # integrate the fog along the link's length
    A = integrate.quad(dA, 0, length) * coeff
    
    return A[0]  # A[1] is the error


def atten_to_fog(A, length, frequency, temperature=25, formula='rayleigh'):
    ''' calculate the average* fog from
    the attentuation of a link.
    
    rain_func - the rain rate in mm/h at a certain point (x,y) on the world map.
    length - the link's length in meters.
    (xa,ya) - location of site_a of the link.
    (xb,yb) - location of site_b of the link.
    
    A - the attenuation of the link (without free path loss)
    frequency - the frequency of the link [GHz]
    temperature - temperature in range -8 to 25 [celsius]
    formula - the approximation to use, either "rayleight" or "mie"
    '''
    # wavelength - wavelength of the link [mm] in range 3mm to 3cm
    refractive_index = 1.0 # unitless
    speed_of_light = 299792458.0 / refractive_index  # meter/sec
    wavelength = (speed_of_light / frequency) * 10 # in milimeters
         
    
    if formula == 'mie': # based on mie scattering
        coeff = -1.347 + 0.0372*wavelength + 18.0/wavelength - 0.022*temperature
    elif formula == 'rayleigh': # based on rayleigh approx
        T = temperature + 273.15 # T in kelvin
        theta = (300.0/T)
        theta_power = 7.8087 - (0.01565*frequency) - (3.0730e-4*(frequency**2))
        coeff = 6.0826e-4 * frequency**(-1.8963) * (theta ** theta_power)
        
    return A / (length * coeff)



def gaussian(intensity, c_x, c_y, std_x, std_y, rotation):
    """Returns a gaussian function with the given parameters"""
    std_x = float(std_x)
    std_y = float(std_y)
    
    Theta = np.deg2rad(rotation)
    
    a = ((np.cos(Theta)**2) / (2*std_x**2)) + ((np.sin(Theta)**2) / (2*std_y**2));
    b = -((np.sin(2*Theta)) / (4*std_x**2)) + ((np.sin(2*Theta)) / (4*std_y**2));
    c = ((np.sin(Theta)**2) / (2*std_x**2)) + ((np.cos(Theta)**2) / (2*std_y**2));
        
    # define the rotated gauss function
    def rot_g(x,y):
        g = intensity*np.exp(-(a*(x - c_x)**2 + 2*b*(x - c_x)*(y - c_y) + c*(y - c_y)**2))
        return g

    return rot_g


def gen_spots(man_sim, intensity, std_min, std_max, spots, x_min, x_max, y_min, y_max):
    ''' intensity - max value for all spots,
    std_min - min spot standard dev,
    std_max - max spot standard dev,
    spots - number of spots
    x_min, x_max, y_min, y_max - the range of possible '''
    
    lons = np.random.uniform(x_min+(x_max-x_min)*15/100, x_max-(x_max-x_min)*15/100, spots)    
    lats = np.random.uniform(y_min+(y_max-y_min)*15/100, y_max-(y_max-y_min)*15/100, spots)
    stds = np.random.uniform(std_min, std_max, spots)
    
#    lons = np.random.uniform(x_min, x_max, spots)    
#    lats = np.random.uniform(y_min, y_max, spots)
#    stds = np.random.uniform(std_min, std_max, spots)
    
    # Determine one known spot relative to map edges
#    lons = np.array([(x_min+(x_max-x_min)*0.3)])    
#    lats = np.array([(y_min+(y_max-y_min)*0.3)])
#    stds = np.random.uniform(std_min, std_max, spots)
    
    # Determine one known spot with lats lons and std
#    lons_float, lats_float = man_sim.degrees_to_meters(34.9007093, 32.27838319)
#    lons = np.array([lons_float])
#    lats = np.array([lats_float])
#    stds = np.array([4210.75215056])

#     Determine one known spot in the middle
#    lons = np.array([(x_min+(x_max-x_min) * 0.3)])    
#    lats = np.array([(y_min+(y_max-y_min) * 0.3)])
#    stds = np.array([2763.61243823])
    
    
    # Determine three known spots
#    lons = np.array([(x_min+(x_max-x_min)*0.3), (x_min+(x_max-x_min)*0.625), (x_min+(x_max-x_min)*0.339)])    
#    lats = np.array([(y_min+(y_max-y_min)*0.435), (y_min+(y_max-y_min)*0.898), (y_min+(y_max-y_min)*0.199)])
#    stds = np.array([4000, 5000, 6000])
    
    gen_spots = np.column_stack((lons, lats, stds))
    df_spots = pd.DataFrame(data = gen_spots, columns = ['center_x', 'center_y', 'std'])
    return df_spots


def spotty(man_sim, output_file_name, intensity, std_min, std_max, spots, x_min, x_max, y_min, y_max):
    df_spots = gen_spots(man_sim, intensity, std_min, std_max, spots, x_min, x_max, y_min, y_max)
    
    X_m, Y_m = man_sim.meters_to_degrees(df_spots['center_x'].values, 
                                                     df_spots['center_y'].values)
    directory = split_at(output_file_name,'/',-1)[0] + '/'
    f = open(directory + "/list_of_runParam.txt", "a+")
    f.write("gaussian_char.:\r\n")
    f.write("    lon:"+ str(X_m) + "\r\n")
    f.write("    lat:"+ str(Y_m) + "\r\n")
    f.write("    std:"+ str(df_spots['std'].values) + "[m]\r\n\n")
    
    
        
    iter_spots = list(zip(df_spots['center_x'], df_spots['center_y'], df_spots['std']))
    
    def spotty_func(x,y):
        return np.max([gaussian(intensity, c_x, c_y, std, std, 0)(x,y) for c_x, c_y, std in iter_spots])
    
    return spotty_func
 
    

class ManualSim():
    def __init__(self, all_links, # all the available links in meta file
                 output_folder,
                 links_meta_input,
                 units="Degrees", # units of the coodinates (for XYZ matrices files) - "Degrees"/"Kilometers"
                 map_res=0.1, # resolution of XYZ matrices (pay attention to units !!!)
                 quantization=0.0, # e.g: 1.0dBm, 0.3dBm, 0.1dBm
                 include_path_loss=False, # True if you want to include the free-path-loss (zero-level)
                 ndist="Without", # "Without" / "Rayleigh" / "Gaussian" - noise distribution
                 npct=0.0): # noise intensity as a percentage of the attenuation of each link
                  
        f = open(output_folder + "/list_of_runParam.txt", "a+")
        f.write("links_meta_input:\r\n")
        f.write("    " + links_meta_input + "\r\n\n")
        f.write("map_resolution: "+ str(map_res) + ' ' + units + "\r\n")
        f.write("quantization: "+ str(quantization) + ' ' + "dBm\r\n")
        f.write("noise distribution: "+ str(ndist) + "\r\n")
        f.close
        # dataframe with cmls
        self.all_links = all_links
        
        # calculate links' length
        self.all_links['Length'] = self.all_links.apply(lambda r: haversine(r['xa'], r['ya'], r['xb'], r['yb']), axis=1)        
        
        # calculate ITU a, b parameters
        for i, r in self.all_links.iterrows():
            self.all_links.loc[i,'ITU_a1'], self.all_links.loc[i,'ITU_b1'] = power_law_a_b(r['Freq_1'], r['Polar_1'])
            self.all_links.loc[i,'ITU_a2'], self.all_links.loc[i,'ITU_b2'] = power_law_a_b(r['Freq_2'], r['Polar_2'])
        
        # initial rain values (zero rain for all links)
        self.all_links['Rain1'] = 0
        self.all_links['Rain2'] = 0
        
        self.units = units # can be "Degrees" or "Kilometers"
        self.map_res = map_res # map resolution in degrees or meters
        
        self.map_lat_min = min(self.all_links['ya'].min(), self.all_links['yb'].min()) - self.map_res
        self.map_lat_max = max(self.all_links['ya'].max(), self.all_links['yb'].max()) + self.map_res
        self.map_lon_min = min(self.all_links['xa'].min(), self.all_links['xb'].min()) - self.map_res
        self.map_lon_max = max(self.all_links['xa'].max(), self.all_links['xb'].max()) + self.map_res
        
        self.quantization = quantization
        self.include_path_loss = include_path_loss
        
        # noise paremeters
        self.npct = npct # noise intensity as a percentage of the attenuation of each cml
        self.ndist = ndist # can be "Without"/"Rayleigh"/"Gaussian"
        
        self.proj_degrees = Proj(init='epsg:4326')
        self.proj_meters = Proj(init='epsg:3395')
        
    def degrees_to_meters(self, lon, lat):
        x, y = transform(self.proj_degrees, self.proj_meters, lon, lat)
        return x, y

    def meters_to_degrees(self, x, y):
        lon, lat = transform(self.proj_meters, self.proj_degrees, x, y)
        return lon, lat                

    def fast_interpolate_2d(self, tri, z):
        try:
            def func1(u, v):
                u, v = np.asarray(u), np.asarray(v)
                uv = np.vstack((u.flatten(), v.flatten())).T
                interp = fast_interpolate(z.flatten(), tri, uv)
                if u.ndim > 1:
                    interp = interp.reshape(u.shape[0], u.shape[1])
                return interp
        except:
            print(traceback.format_exc())
        
        return func1
    
    
    def reset_cml_rain_map(self):
        ''' reset all cml rain to 0 (and re-draw cmls on map) '''
        for i, link in self.links.iterrows():
            self.links.loc[i, 'Rain1'] = 0
            self.links.loc[i, 'Rain2'] = 0

    
    def save_csv(self, csv_file_name):
        try:
            csv_file_name = csv_file_name + '.csv'
            self.links.to_csv(csv_file_name, index=False)
            print('* saved csv file: ' + csv_file_name)
        except:
            print('ERROR: can\'t save csv file.') 
            print(traceback.format_exc())       

    def draw_map(self, file_name):
        x = np.arange(self.map_lon_min, self.map_lon_max, self.map_res)
        y = np.arange(self.map_lat_min, self.map_lat_max, self.map_res)
                
        X, Y = np.meshgrid(x, y) 
        X_meters, Y_meters = self.degrees_to_meters(X, Y) # convert to meters

        func = np.vectorize(self.func)                                  
        Z = func(X_meters, Y_meters)
        
        plt.pcolormesh(X, Y, Z)
        for i, link in self.links.iterrows():
            x = np.array([link['xa'], link['xb']])
            y = np.array([link['ya'], link['yb']])
            plt.plot(x, y, color='k')
            
        mapfile = file_name + '.html'
        mplleaflet.save_html(fileobj=mapfile, tiles='mapbox bright')
        

    def save_XYZ_matrices(self, csv_file_name):
        try:
            resolution = self.map_res        
            map_lat_min = self.map_lat_min
            map_lat_max = self.map_lat_max
            map_lon_min = self.map_lon_min
            map_lon_max = self.map_lon_max
            
            func = np.vectorize(self.func) # vectorized rain function
            if self.units == 'Kilometers': # x,y grid in meters 
                res_meters = int(resolution * 1000) # from km to meters
                
                x_min, y_min = self.degrees_to_meters(map_lon_min, map_lat_min)
                x_max, y_max = self.degrees_to_meters(map_lon_max, map_lat_max)
                                
                x = np.arange(x_min, x_max, res_meters) # x = np.arange(self.x_min, self.x_max, res_meters)
                y = np.arange(y_min, y_max, res_meters) # y = np.arange(self.y_min, self.y_max, res_meters)
                
                X, Y = np.meshgrid(x, y)
                Z = func(X, Y)
            
            else: # x,y grid in degrees
                x = np.arange(map_lon_min, map_lon_max, resolution) # x = np.arange(self.min_lon, self.max_lon, resolution)
                y = np.arange(map_lat_min, map_lat_max, resolution) # y = np.arange(self.min_lat, self.max_lat, resolution)
                
                X, Y = np.meshgrid(x, y) 
                X_meters, Y_meters = self.degrees_to_meters(X, Y) # convert to meters                                  
                Z = func(X_meters, Y_meters)
            
            Z[Z<0.01] = 0.0 # set rain below 0.01 mm/hour to 0.0
            mats = [X, Y, Z] # the matrices to export
            filenames = []
            for i, axis in enumerate(['X', 'Y', 'Z']):
                # dont create more than one X and Y csv
                if Path(split_at(csv_file_name, '_', -2)[0] + '_000_000_Z.csv').is_file() \
                and (axis=='X' or axis=='Y'):
                    continue
                else:
                    filename = csv_file_name + '_' + axis + '.csv' # the output file name
                    filenames.append(filename)
                    
                    # convert matrix to dataframe and save to csv
                    matrix = pd.DataFrame(np.flipud(mats[i]))
                    matrix.to_csv(filename,
                                  index=False, header=False,
                                  float_format='%g')
                
            print("* saved X,Y,Z matrices of raw data (resolution {} {}):".format(resolution, self.units))
            print("{}".format(filenames))
        except:
            print('ERROR: can\'t save X,Y,Z matrices of raw data.') 
            print(traceback.format_exc())


    def rain_to_cml_atten(self):
        ''' loop over the links and calculate the attenuation for each link (2 channels) '''
        try:
            for i, link in self.links.iterrows():
                # convert lon/lat to x/y for link's sites
                xa, ya = self.degrees_to_meters(link['xa'], link['ya'])
                xb, yb = self.degrees_to_meters(link['xb'], link['yb'])
                
                # calculate free path loss for each channel
                channel_1_path_loss = path_loss_atten(link['Length'], link['Freq_1'])
                channel_2_path_loss = path_loss_atten(link['Length'], link['Freq_2'])
    
                # channel 1 (rain + free path loss + noise)
                self.links.loc[i, 'A_1'] = rain_to_atten(self.func, link['Length'],
                                                          xa=xa, ya=ya, xb=xb, yb=yb,
                                                          ITU_a=link['ITU_a1'], ITU_b=link['ITU_b1']) + channel_1_path_loss
                              
                # channel 2 (rain + free path loss + noise)
                self.links.loc[i, 'A_2'] = rain_to_atten(self.func, link['Length'],
                                                          xa=xa, ya=ya, xb=xb, yb=yb,
                                                          ITU_a=link['ITU_a2'], ITU_b=link['ITU_b2']) + channel_2_path_loss
                        
                # add noise to both channels
                if self.ndist != "Without":
                    # flag=1 is used to determine the standard deviation of the noise by np.sqrt(((0.1)**2)/12) 
                    self.links.loc[i, 'A_1'] = add_noise(self.links['A_1'][i], percent = self.npct, dist = self.ndist, flag=1)[0]
                    self.links.loc[i, 'A_2'] = add_noise(self.links['A_2'][i], percent = self.npct, dist = self.ndist, flag=1)[0]
                    
                # force quantization for attenutation measurements
                if self.quantization > 0.0:
                    self.links.loc[i, 'A_1'] = force_quantization(self.links['A_1'][i], Q = self.quantization)
                    self.links.loc[i, 'A_2'] = force_quantization(self.links['A_2'][i], Q = self.quantization)
                
                # calculate the average rain rate for the link (atten. measurements with noise)
                self.links.loc[i, 'Rain1'] = atten_to_rain(self.links.loc[i, 'A_1'] -  channel_1_path_loss,
                                                          link['Length'], ITU_a=link['ITU_a1'], ITU_b=link['ITU_b1'])
                
                self.links.loc[i, 'Rain2'] = atten_to_rain(self.links.loc[i, 'A_2'] -  channel_2_path_loss,
                                                          link['Length'], ITU_a=link['ITU_a2'], ITU_b=link['ITU_b2'])
                
                # remove free path loss from attenutation measurements
                if self.include_path_loss == False:
                    self.links.loc[i, 'A_1'] = self.links.loc[i, 'A_1'] - channel_1_path_loss
                    self.links.loc[i, 'A_2'] = self.links.loc[i, 'A_2'] - channel_2_path_loss 
                self.links.A_1[self.links.A_1 < 0] = 0
                self.links.A_2[self.links.A_2 < 0] = 0
                
                self.links.Rain1.fillna(0, inplace=True)
                self.links.Rain2.fillna(0, inplace=True)
        
        except:
            print('ERROR: can\'t calculate attenuations.')
            print(traceback.format_exc())
   

    def savefile(self, output_file_name):
        ''' save CSV (and cmlh5) and rain map'''
        # reset all cml rain to 0 (and re-draw cmls on map)
        self.reset_cml_rain_map()
                     
        # create columns to hold the attenuation for each link
        self.links['A_1'] = np.zeros(self.links.shape[0]) # atten. for channel 1
        self.links['A_2'] = np.zeros(self.links.shape[0]) # atten. for channel 2
         
        print('\n\nCalculating attenuations for all the links...')
        self.rain_to_cml_atten()  
        
        # save CSV file
        self.save_csv(output_file_name)
        
        # save rain map to X,Y,Z matrices
        self.save_XYZ_matrices(output_file_name)
        
        # save html map with rain and links
        self.draw_map(output_file_name)
    
    
    def activate_sim(self, output_file_name):
        
        # generate rain functions
        my_spots = [1] * 100#, 1, 1, 1, 1, 1, 1, 1, 1, 1]#, 20, 30, 40]
        
        my_intensity = 45 # mm/h
        my_std_min = 2000.0 # m
        my_std_max = 2000.0 # m
        std_frac = np.ones(len(my_spots))
        # comment in if you do not wish to controll increase the std with runs
#        std_frac = np.linspace(0.1, 1, len(my_spots)) %[MHADAR] - 
		loc_frac = 
        # or (not ready yet)
#        std_frac1 = np.linspace(0.1, 1, len(my_spots) / 2)
#        std_frac2 = np.linspace(0.1, 1, len(my_spots) / 2)
#        a = np.array([1,2,3])
#        b = np.array([4,5,6])
#        c = np.concatenate(np.array(list(zip(a,b))))
        
        rain_funcs = []
        directory = split_at(output_file_name,'/',-1)[0] + '/'
        f = open(directory + "/list_of_runParam.txt", "a+")
        f.write("std_multiplied_by_factors:"+ str(std_frac) + "\r\n")
        f.write("num_of_spots_per_scenario:"+ str(my_spots) + "\r\n")
        f.write("    intensity: "+ str(my_intensity) + " mm h-1\r\n")
        f.write("    std_min: "+ str(my_std_min) + " m\r\n")
        f.write("    std_max: "+ str(my_std_max) + " m\r\n")
        

        for n, rain_iter in enumerate(my_spots):#[2, 2, 2]:
            # define the rain function (a function of (x,y))
#            center_lon = (self.map_lon_min + self.map_lon_max) / 2.0
#            center_lat = (self.map_lat_min + self.map_lat_max) / 2.0
#            center_x, center_y = self.degrees_to_meters(center_lon, center_lat)
#                
#           self.func = gaussian(intensity=25 * (rain_iter+1),
#                                     c_x=center_x, c_y=center_y,
#                                     std_x=4000.0, std_y=6000.0,
#                                     rotation=0.0)
   
            x_min, y_min = self.degrees_to_meters(self.map_lon_min, self.map_lat_min)
            x_max, y_max = self.degrees_to_meters(self.map_lon_max, self.map_lat_max)
            
            temp_func = spotty(self,
                               output_file_name,
                               intensity=my_intensity,
                               std_min=my_std_min * std_frac[n],
                               std_max=my_std_max * std_frac[n],
                               spots=rain_iter,
                               x_min=x_min, x_max=x_max,
                               y_min=y_min, y_max=y_max)
            
            rain_funcs.append(temp_func)
        
        # sample a subset of the links and compute the attenuations for each rain_func in rain_funcs
        pcnt_of_links = 100 # percentage of links to use
        number_of_samples = 1
        f.write("pcnt_of_links: "+ str(pcnt_of_links) + " %\r\n")
        f.write("number_of_link_settings: "+ str(number_of_samples) + " \r\n")
        f.close
        for link_iter in range(number_of_samples):
            # select links to use in this iteration
            self.links = self.all_links.sample(frac=pcnt_of_links/100.0) # frac of links to use
            self.links = self.links.reset_index() # reset index to 0,1,2,...
            
            for rain_iter, rain_func in enumerate(rain_funcs):
                # get rain function
                self.func = rain_func
        
                # save all output files
                link_iter_serial = split_at(str(format(link_iter/1000, '.3f')),'.',1)[-1]
                rain_iter_serial = split_at(str(format(rain_iter/1000, '.3f')),'.',1)[-1]
                self.savefile(output_file_name + '_' + str(link_iter_serial) + '_' + str(rain_iter_serial))
        
        
    
if __name__ == "__main__":
    # run this code if manual_sim.py is run
    
    # set up all the data (all the links metadata, etc.)
    links_path = '/Volumes/0543970348/IE_directory/aviv/aviv_links.csv'
    links = pd.read_csv(links_path)
    output_folder = '/Volumes/0543970348/IE_directory/aviv/test/' # directory for all output files
    output_filename = 'sim_out' # output file name 
    f = open(output_folder + "/list_of_runParam.txt", "w+")
    f.close
    
    MS = ManualSim(links, output_folder, links_path, map_res=0.003, quantization=1)
    
    # run the simulation
    MS.activate_sim(output_folder + output_filename)
   
