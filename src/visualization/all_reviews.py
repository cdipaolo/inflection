import pandas as pd
import numpy as np
import matplotlib
matplotlib.use('agg')
from matplotlib import pyplot as plt
from mpl_toolkits.basemap import Basemap
import colormaps as cmaps

PLOT_ON_MAP = True

plt.register_cmap(name='plasma', cmap=cmaps.plasma)
plt.set_cmap(cmaps.plasma)

print('==> Loading stars.csv into df')
reviews = pd.read_csv('data/processed/vegas_stars.csv', sep='~')
print(reviews.head())

## separate location from stars for plotting
print('==> Generating x-y coords for plotting')
x = reviews.loc[:,'longitude']
y = reviews.loc[:,'latitude']
stars = reviews.loc[:,'stars']

## plot all the reviews
print('==> Plotting Las Vegas reviews')

# get map of Las Vegas to plot onto
if PLOT_ON_MAP:
    print('==> Downloading Las Vegas map')
    vegas = Basemap(projection='cyl',
                llcrnrlat=35.90, llcrnrlon=-115.4,
                urcrnrlat=36.40, urcrnrlon=-114.95)
    vegas.arcgisimage(xpixels=700, verbose=True)

print('==> Plotting data')
if PLOT_ON_MAP:
    im = vegas.scatter(x,y, c=stars, edgecolors='', alpha=0.2, cmap='plasma')
else:
    im = plt.scatter(x,y, c=stars, edgecolors='', alpha=0.2, cmap='plasma')

print('==> Setting plot styles')
plt.title('Las Vegas Reviews')
plt.xlabel('longitude')
plt.ylabel('latitude')
cbar = plt.colorbar(im)
cbar.solids.set_edgecolor('face')

plt.tight_layout()
plt.savefig('reports/figures/vegas/vegas_reviews{}.png'.format('_map' if PLOT_ON_MAP else ''), bbox_inches='tight')
print('==> Complete.')
