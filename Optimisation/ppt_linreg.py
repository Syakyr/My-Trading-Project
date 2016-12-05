# This is to find the relationship of the inputs and the output from the optimisation from MT4.
#    Inputs: TPPip, LAP1300, BrkOutPip1300, ChanFactor1300, AnalysisMin1300, HourEnd1300
#    Output: P/DD

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

def get_r2(X, Y):
    w = np.linalg.solve( X.T.dot(X), X.T.dot(Y) )
    Yhat = X.dot(w)

    d1 = Y - Yhat
    d2 = Y - Y.mean()
    r2 = 1 - d1.dot(d1) / d2.dot(d2)
    return (r2, w)

df = pd.read_csv('ppt2_linreg.csv')
df['1'] = 1

# for i in range(1,7):
#     for j in range(2,10):
#         df[str(df.columns[i]+'^'+str(j))] = df.apply(lambda row: row[df.columns[i]]**j, axis=1)


data = df.as_matrix()

X = data[:,1:]
Y = data[:,0]

r2, w = get_r2(X, Y)

# print(df[ df['P/DD'] > 800])
print(df.columns)
print(w)
print("R2 (total) is %f" % r2)

# for i in range(1,7):
#     Xph = df[[df.columns[i],'1']].as_matrix()
#     print("R2 (%s) is %f" % (df.columns[i],get_r2(Xph, Y)))

# # Plot the scatter
# for i in range(1,7):
#     plt.scatter(data[:,i], Y)
#     plt.title("P/DD against %s" % df.columns[i])  # Title of the graph
#     plt.xlabel(df.columns[i])  # x label
#     plt.ylabel("P/DD")  # y label
#     plt.show()
