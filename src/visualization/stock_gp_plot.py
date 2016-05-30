import datetime

import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

import GPy
import quandl

STOCKS_FILE = 'test_stocks.csv'
END_DATE    = datetime.datetime.utcnow()
START_DATE  = END_DATE - datetime.timedelta(days=365*10)

END_DATE    = END_DATE.strftime('%Y-%m-%d')
START_DATE  = START_DATE.strftime('%Y-%m-%d')

print('==> Start Date: {}'.format(START_DATE))
print('==>   End Date: {}'.format(END_DATE))

def gp_plot(X_,Y_, kernel=None, optimize=True,
        filename=None, title='', xlabel='',
        ylabel='', num_restarts=1):
    plot = 0

    # go through each quarter and plot
    for i in range(X_.shape[0], 0, -90):
        end   = i
        start = np.max([0, i - 90])
        X = X_[start:end]
        Y = Y_[start:end]
        if not kernel:
            kernel = GPy.kern.RBF(X.shape[1], variance=10., lengthscale=10.)
        m = GPy.models.GPRegression(X,Y,kernel)

        if optimize:
            m.optimize_restarts(num_restarts=num_restarts)

        fig = plt.figure(figsize=(10,6))
        plt.plot(X,Y,'-', color='black', alpha=0.5)
        
        X_test = np.linspace(
            np.min(X),
            np.max(X),
            1000
        ).reshape(-1,1)
        Y_test, sigma_test = m.predict(X_test)

        plt.plot(X_test, Y_test, '-', label='Mean', color='red', alpha=0.8)

        lower = (Y_test - 2*sigma_test).reshape(-1)
        upper = (Y_test + 2*sigma_test).reshape(-1)
        plt.gca().fill_between(X_test.flat, lower, upper,
                                            color='grey', alpha=0.4)
        plt.xlim(np.min(X),np.max(X))
        plt.title(title)
        plt.legend()
        plt.xlabel(xlabel)
        plt.ylabel(ylabel)

        if filename:
            plt.savefig(filename + '_{}.png'.format(plot))
        else:
            plt.show()
        plt.close(fig)

        plot += 1


with open(STOCKS_FILE, 'r') as stocks:
    kernel = GPy.kern.RBF(1, variance=50., lengthscale=10.)
    for stock in stocks:
        stock = stock.rstrip()
        # handle commenting out in CSV
        if stock.startswith('#'):
            continue

        dataset = stock.split('/')[0]
        ticker = stock.split('/')[1]
        print('==> Stock <{}>'.format(stock))
        data = quandl.get(stock,
                authtoken="xasu1RyBBuDTY-xVPUu8",
                start_date=START_DATE,
                end_date=END_DATE)
        
        X = (data.index.get_values().reshape(-1,1) - np.datetime64(START_DATE)).astype('timedelta64[D]')
        X = X / np.timedelta64(1,'D')
        X = X.astype(float)
        Y = None
        if dataset == 'WIKI':
            Y = data['Adj. Close'].as_matrix().reshape(-1,1)
        elif ticker == 'COMP':
            Y = data['Index Value'].as_matrix().reshape(-1,1)
        else:
            Y = data['Close'].as_matrix().reshape(-1,1)

        gp_plot(X,Y, kernel=kernel, optimize=True, num_restarts=5,
                filename='stock_gp/{}'.format(ticker),
                title='{}'.format(ticker), xlabel='Days Since {}'.format(START_DATE),
                ylabel='Adj. Close Price')
