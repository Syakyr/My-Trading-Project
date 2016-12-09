import numpy as np
import pandas as pd

# Set Variable
TimePeriod = 30
Threshold = 20

# Returns X, YBuy, YSell
def get_data():
    # Truncates the CSV to the timestamp, the pip distance and the binary 'output' Buy or Sell
    df = pd.read_csv('GBPUSD-1-1-16-11-30-16H1.csv')
    df['Timestamp'] = pd.to_datetime(df['Date'].map(str) + df['Timestamp'], format='%Y%m%d%H:%M:%S')
    df['PipDist'] = df.apply(lambda row: int((row['Close'] - row['Open']) * 100000), axis=1)
    df['Buy'] = df.apply(lambda row: int(row['PipDist'] > Threshold), axis=1)
    df['Sell'] = df.apply(lambda row: int(row['PipDist'] < -Threshold), axis=1)
    df = df[['Timestamp', 'PipDist', 'Buy', 'Sell']]

    data = df.as_matrix()

    # Get input X as n number of past PipDist, where n = TimePeriod
    pipdist = data[:, 1]
    N = len(pipdist) - TimePeriod
    X = np.zeros((N, TimePeriod))
    for i in range(0, N):
        X[i] = pipdist[i + 1:TimePeriod + i + 1]

    YBuy = data[:, 2][:N].astype(np.int32)  # Buy data
    YSell = data[:, 3][:N].astype(np.int32)  # Sell data

    # Regularisation (Normalisation)
    for i in range(TimePeriod):
        X[:, i] = (X[:, i] - X[:, i].mean()) / X[:, i].std()

    return X, YBuy, YSell

# Returns R-squared
def get_r2(X, Y):
    w = np.linalg.solve(X.T.dot(X), X.T.dot(Y))
    Yhat = X.dot(w)

    d1 = Y - Yhat
    d2 = Y - Y.mean()
    r2 = 1 - d1.dot(d1) / d2.dot(d2)
    return r2

X, YBuy, YSell = get_data()

WBuy  = np.linalg.solve( X.T.dot(X), X.T.dot(YBuy ) )
WSell = np.linalg.solve( X.T.dot(X), X.T.dot(YSell) )

D = X.shape[1] # Number of columns of X
W = np.random.randn(D) # Assumes random Gaussian distribution as the weight in linreg
b = 0 # bias term set to 0

def sigmoid(z): # Gives a value between 0 and 1
    return 1 / (1 + np.exp(-z))

def forward(X, W, b): # See P_Y_given_X
    return sigmoid(X.dot(W) + b)

P_YBuy_given_X = forward(X, WBuy, b) # The probability of Y is true given input of X
P_YSell_given_X = forward(X, WSell, b) # The probability of Y is true given input of X
predictions_Buy = np.round(P_YBuy_given_X)
predictions_Sell = np.round(P_YSell_given_X)

# How accurate is the classification prediction given we already have the answer that is Y
def classification_rate(Y, P):
    return np.mean(Y == P)

print ("Score is %f" % classification_rate(YBuy, predictions_Buy))
print ("Score is %f" % classification_rate(YSell, predictions_Sell))

# Score is not accurate since W is random from Gaussian distribution, not from linreg