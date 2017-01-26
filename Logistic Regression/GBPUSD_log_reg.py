import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.utils import shuffle

# Set Variable
TimePeriod = 100
Threshold = 25
csvfile = 'GBPUSD-1-1-16-11-30-16H1.csv'

# Returns X, YBuy, YSell
def get_data():
    # Truncates the CSV to the timestamp, the pip distance and the binary 'output' Buy or Sell
    df = pd.read_csv(csvfile)
    df['Timestamp'] = pd.to_datetime(df['Date'].map(str) + df['Timestamp'], format='%Y%m%d%H:%M:%S')
    df['PipDist'] = df.apply(lambda row: int((row['Close'] - row['Open']) * 100000), axis=1)
    df['Buy'] = df.apply(lambda row: int(row['PipDist'] > Threshold), axis=1)
    df['Sell'] = df.apply(lambda row: int(row['PipDist'] < -Threshold), axis=1)
    df = df[['Timestamp', 'PipDist', 'Buy', 'Sell']]

    # Stats
    TradeSignals = (len(df[df['Buy'] == 1]['Buy']) + len(df[df['Sell'] == 1]['Sell']))
    DataPoints   = len(df['Buy'])

    print("Total Trade Signals: %i" % TradeSignals)
    print("Total Data Points: %i" % DataPoints)
    print("Percentage Points: %.2f" % (TradeSignals/DataPoints*100))

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

# Initialises the data sets
XBuy, YBuy, YSell = get_data()
XSell = XBuy.copy()
XBuy, YBuy = shuffle(XBuy, YBuy)
XSell, YSell = shuffle(XSell, YSell)

# Creates Test and Train sets
XBuy_train  = XBuy[:-100]
YBuy_train  = YBuy[:-100]
XBuy_test   = XBuy[-100:]
YBuy_test   = YBuy[-100:]
XSell_train = XSell[:-100]
YSell_train = YSell[:-100]
XSell_test  = XSell[-100:]
YSell_test  = YSell[-100:]

D     = XBuy.shape[1]       # Number of columns of XBuy / XSell
WBuy  = np.random.randn(D)  # Assumes random Gaussian distribution as the weight
WSell = WBuy.copy()
bBuy  = 0                   # bias term set to 0
bSell = 0                   # bias term set to 0

def sigmoid(z): # Gives a value between 0 and 1
    return 1 / (1 + np.exp(-z))

def forward(X, W, b): # See P_Y_given_X
    return sigmoid(X.dot(W) + b)

# How accurate is the classification prediction given we already have the answer that is Y
def classification_rate(Y, P):
    return np.mean(Y == P)

def cross_entropy(T, pY):
    return (-np.mean(T.astype(np.float128)*np.log(pY.astype(np.float128)).astype(np.float128) - (1 - T.astype(np.float128))*np.log(1 - pY.astype(np.float128)).astype(np.float128)).astype(np.float128))

trainBuy_costs = []
testBuy_costs  = []
trainSell_costs = []
testSell_costs  = []
learning_rate = 0.001

# print("i\tBuy Train\tBuy Test\tSell Train\tSell Test")

for i in range(20):

    pYBuy_train = forward(XBuy_train, WBuy, bBuy)
    pYBuy_test = forward(XBuy_test, WBuy, bBuy)
    pYSell_train = forward(XSell_train, WSell, bSell)
    pYSell_test = forward(XSell_test, WSell, bSell)

    cBuy_train  = cross_entropy(YBuy_train, pYBuy_train)
    cBuy_test   = cross_entropy(YBuy_test, pYBuy_test)
    cSell_train = cross_entropy(YSell_train, pYSell_train)
    cSell_test  = cross_entropy(YSell_test, pYSell_test)
    trainBuy_costs.append(cBuy_train)
    testBuy_costs.append(cBuy_test)
    trainSell_costs.append(cSell_train)
    testSell_costs.append(cSell_test)

    WBuy  -= learning_rate * XBuy_train.T.dot(pYBuy_train - YBuy_train)
    bBuy  -= learning_rate * (pYBuy_train - YBuy_train).sum()
    WSell -= learning_rate * XSell_train.T.dot(pYSell_train - YSell_train)
    bSell -= learning_rate * (pYSell_train - YSell_train).sum()

    # if i % 2 == 0:
    #     print("%i: %f, %f, %f, %f" % (i, cBuy_train, cBuy_test, cSell_train, cSell_test))

array1 = np.array(np.logical_and(YBuy_train, pYBuy_train.round()))
array2 = np.array(np.logical_and(YSell_train, pYSell_train.round()))

print(len(YBuy_train))
print (len(np.extract(array1 == True, array1)))
print (len(np.extract(array2 == True, array2)))

print ("Final Buy train classification rate: %f"  % classification_rate(YBuy_train, pYBuy_train.round()))
print ("Final Buy test classification rate: %f"   % classification_rate(YBuy_test, pYBuy_test.round()))
print ("Final Sell train classification rate: %f" % classification_rate(YSell_train, pYSell_train.round()))
print ("Final Sell test classification rate: %f"  % classification_rate(YSell_test, pYSell_test.round()))

# legend1, = plt.plot(trainBuy_costs, label='Train Buy Cost')
# legend2, = plt.plot(testBuy_costs,  label='Test Buy Cost')
# legend3, = plt.plot(trainSell_costs, label='Train Sell Cost')
# legend4, = plt.plot(testSell_costs,  label='Test Sell Cost')
#
# plt.legend([legend1, legend2, legend3, legend4])
#
# plt.show()