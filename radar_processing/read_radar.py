from pathlib import Path
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Arrow, Circle
import cv2


def rehovot_latlong_borders():
    #links min/max locations:
    # min_lat = 31.87313  # south
    # max_lat = 31.91141  # north
    # min_long = 34.782139999999998  # west
    # max_long = 34.820099999999996  # east

    #min/max from map:
    min_lat = 31.8711   # south
    max_lat = 31.91122  # north
    min_long = 34.7738  # west
    max_long = 34.83594  # east

    NW = (max_lat, min_long)
    SW = (min_lat, min_long)
    NE = (max_lat, max_long)
    SE = (min_lat, max_long)

    return NW, SW, NE, SE

# def latlong2indexes(lat, lon):
def calc_index_on_map():
    """
    #calc the index of given lat_lon coordinate respectivly to top left of the image
    """
    return

def calc_point_of_interest(im):
    threshold = 0.5
    RIS = im.max()


if __name__ == "__main__":
    day = Path('data/ims/rainmaps_10min_2018/2018/11/06')
    files = day.glob('RR*.asc')

    # radar_location = 32.007, 34.81456004
    radar = Circle((280,280), radius=2, color='red')
    rehovot_latlong = rehovot_latlong_borders()

    # params for ShiTomasi corner detection
    feature_params = dict( maxCorners = 100,
                           qualityLevel = 0.2,
                           minDistance = 7,
                           blockSize = 21 )

    # Parameters for lucas kanade optical flow
    lk_params = dict( winSize  = (20,20),
                      maxLevel = 2,
                      criteria = (cv2.TERM_CRITERIA_EPS | cv2.TERM_CRITERIA_COUNT, 10, 0))

    # Create some random colors
    color = np.random.randint(0,1,(100,3))
    max_rain_rate = 20

    fig, ax = plt.subplots(1)
    ax.add_patch(radar)
    img_array = []
    RM_prev = pd.DataFrame(pd.read_csv(next(files), sep=' ', header=None)).values
    RM_prev = np.uint8((RM_prev/max_rain_rate) * 255)
    for f in files:
        print(f)
        ax.imshow(RM_prev)
        p0 = cv2.goodFeaturesToTrack(RM_prev, mask=None, **feature_params)
        RM_curr = pd.DataFrame(pd.read_csv(f, sep=' ', header=None)).values
        RM_curr = np.uint8((RM_curr/max_rain_rate) * 255)
        #### Farback:
        # flow = cv2.calcOpticalFlowFarneback(RM_prev,RM, None, 0.5, 3, 15, 3, 5, 1.2, 0)
        # ax[0].imshow(flow[:,:,1])
        # ax[0].quiver(x, y, flow[:,:,0], flow[:,:,1])

        if p0 is not None:
            #### LK:   
            p1, st, err = cv2.calcOpticalFlowPyrLK(RM_prev, RM_curr, p0, None, **lk_params)
            
            # Select good points
            good_new = p1[st==1]
            good_old = p0[st==1]
            
            # draw the tracks
            directions_str = 'alpha: '
            for i,(new,old) in enumerate(zip(good_new,good_old)):
                a,b = new.ravel()
                c,d = old.ravel()
                arrow = Arrow(c, d, a-c, b-d, color='yellow', width=5 )
                direction = int(np.arctan2(b-d, a-c) * 180/np.pi + 180)
                print(direction)
                directions_str += f'{direction} '
                ax.add_patch(arrow)

        ax.set_title(directions_str + '\n' + f.name)
        plt.show(block=False)
        plt.pause(.1)
        plt.savefig(f'results/radar/2018_11_06/{f.name[:-4]}.png')
        ax.cla()

        RM_prev = RM_curr
        # p0 = good_new.reshape(-1,1,2)

    cv2.destroyAllWindows()

