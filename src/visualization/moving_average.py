import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
from datetime import datetime
import sys

seed = int(sys.argv[1]) if len(sys.argv) > 1 else 42
np.random.seed(seed)

def holt_winters_ewma( x, span, beta ):
    N = x.size
    alpha = 2.0 / ( 1 + span )
    s = np.zeros(( N, ))
    b = np.zeros(( N, ))
    s[0] = x[0]
    for i in range( 1, N ):
        s[i] = alpha * x[i] + ( 1 - alpha )*( s[i-1] + b[i-1] )
        b[i] = beta * ( s[i] - s[i-1] ) + ( 1 - beta ) * b[i-1]
    return s

# of reviews each business has
print('==> Loading reviews.csv')
reviews = pd.read_csv('../../reviews.csv', sep='~')
reviews = reviews.ix[reviews.groupby('business_id')[['business_id']].transform(len).sort('business_id',ascending=[0]).index]

# only use top 200 reviewed businesses
reviews = reviews.loc[:200]
reviews['date'] = pd.to_datetime(reviews['date'])


# select top k businesses to plot reviews over time
k = 7
print('==> Finding top {} reviewed businesses'.format(k))
businesses = np.random.choice(reviews['business_id'].unique(), size=k)

# plot exponentially weighted moving average
# of reviews
print('==> Plotting reviews over time')
fig = plt.figure(figsize=(10.75,6))

# point halflife in exponentially weighted average
points = 1000
for business in businesses:
    print('--  Plotting business {}'.format(business))
    b = reviews[reviews['business_id']==business]
    t = b['date'].astype(datetime)
    #y = holt_winters_ewma(b['stars'].as_matrix(), span=points, beta=0.3)
    y = pd.ewma(b['stars'], halflife=points)
    plt.plot_date(t,y, '-', label=b['name'].as_matrix()[0][:10])

plt.xlabel('Time')
plt.ylabel('Ratings')
#plt.title('Holt Winters Moving Average of Ratings')
plt.title('Exponentially Weighted Moving Average of Ratings')
plt.legend(loc='center left', bbox_to_anchor=(1,0.5))

plt.tight_layout()
plt.subplots_adjust(right=0.7925)
plt.savefig('ratings_ts_{}.png'.format(seed))

print('==> Complete.')
