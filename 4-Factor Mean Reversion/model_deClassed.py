import sys
import os
import datetime
import math
import statistics
import numpy as np
from sklearn import linear_model

def scan_folder():
        '''
        Scan the _dir folder and record all files inside into _files.
        '''
        print("Start!")

        for file in os.listdir(_dir):
                if file.endswith(".csv"):
                        _files.append(file)

        print("%d files found." % (len(_files)))


def load_data():
        '''
        Load the files listed in _files into _data.
        Generate a new key for each stock.
        Store stock data as a list of tuple in ascending order of date.
        (0 Name, 1 Date, 2 Open, 3 High, 4 Low, 5 Close, 6 Volume, 7 Adj Close)
        '''

        print("\nLoading files into memory...")
        quotes_count = 0
        counter, counter_p = 0, 0
        discarded = []

        for file in _files:
                with open(_dir+file) as f:
                        name = file.strip(".csv")
                        quotes = []
                        for line in f:
                                if len(line) < 10:
                                        continue
                                elif not line.startswith('"20'):
                                        continue
                                line = line.strip("\n").strip('"').split(",")
                                date = line[0].split("-")
                                date = datetime.date(int(date[0]), int(date[1]), int(date[2]))
                                # Name,Date,Open,High,Low,Close,Volume,Adj Close
                                quotes.append((name, date, float(line[1]), float(line[2]), float(line[3]), float(line[4]), float(line[5]), float(line[6])))
                        quotes.sort(key=lambda x: x[1])
                        if len(quotes) > 21:
                                _data[name] = quotes
                                quotes_count += len(quotes)
                        else:
                                discarded.append(name)
                
                counter += 1
                if counter//10 != counter_p or counter==len(_files):
                        counter_p += 1
                        sys.stdout.write("\rCompleted: %d/%d (%1.0f%%)" % (counter, len(_files), 100*counter/len(_files)))
                        sys.stdout.flush()

        sys.stdout.write("\n")
        print("%d files loaded into memory (%d quotes recorded)." % (len(_data), quotes_count))
        print("%d files discarded for having too few data: " % (len(discarded)), end="")
        print(discarded)


def process_data():
        '''
        Compute the required fields.
        Record the required fields into _daily_quotes.
        Create a new key for each day.
        Store stock data as a list of tuple.
        (0 Name, 
         1 Overnight Return "Ris", 
         2 Intercept "itc", 
         3 Price "prc", 
         4 Momentum "mom", 
         5 Intraday Votality "hlv", 
         6 Volume "vol"
         7 Liquidity "liq"
         8 Intraday_return "ir"
         9 Residual -> to be implemented later
         10 Weight -> to be implemented later) 
        '''
        #(0 Name, 1 Date, 2 Open, 3 High, 4 Low, 5 Close, 6 Volume, 7 Adj Close)
        print("\nComputing factors...")

        counter, counter_p = 0, 0
        temp_vol = 0 # To record last non-zero vol factor

        for stock in _data:
                d = _data[stock] # loop the dictionary data, stock is the key
                for i in range(21, len(d)):
                        # Compute factors(betas) based on formula
                        ris = math.log(d[i][2]/d[i-1][5])   # Overnight returns
                        itc = 1   # Intercept
                        prc = math.log(d[i-1][5])   # Size
                        mom = math.log(d[i-1][5]/d[i-1][2])   # Momentum
                        uis = sum(((d[i-j][3]-d[i-j][4])/d[i-j][5])**2 for j in range(1, 22))/21
                        if uis != 0:
                                hlv = 0.5*math.log(uis)   # Intraday Votality
                        else: 
                                hlv = 0
                        vis = sum(d[i-j][6] for j in range(1, 22))/21
                        if vis != 0:
                                vol = math.log(vis)   # Volume
                                temp_vol = vol
                        else:
                                vol = temp_vol   # If volume is zero, use the last non-zero vol factor.
                        liq = d[i-1][5]*d[i-1][6]   # Liquidity
                        ir = d[i][5]/d[i][2]-1   # Intraday return

                        # Record factors into _daily_quotes
                        rec = (d[0][0], ris, itc, prc, mom, hlv, vol, liq, ir)
                        if d[i][1] in daily_quotes:
                                _daily_quotes[d[i][1]].append(rec)
                        else:
                                _daily_quotes[d[i][1]] = [rec,]

                counter += 1
                if counter//10 != counter_p or counter==len(_data):
                        counter_p += 1
                        sys.stdout.write("\rCompleted: %d/%d (%1.0f%%)" % (counter, len(_data), 100*counter/len(_data)))
                        sys.stdout.flush()

        sys.stdout.write("\n")


def normalise_factors():
        '''
        hlv and vol will be normalized.
        '''
        print("\nNormalizing factors...")

        counter, counter_p = 0, 0

        for day in _daily_quotes:
                hlv, vol = [], []
                for quote in _daily_quotes[day]:
                        hlv.append(quote[5])
                        vol.append(quote[6])

                hlv_mean = statistics.mean(hlv)
                vol_mean = statistics.mean(vol)

                for i in range(len(_daily_quotes[day])):
                        data = _daily_quotes[day][i] # this data is not dictionary _data
                        r_hlv = data[5]-hlv_mean
                        r_vol = data[6]-vol_mean
                        _daily_quotes[day][i] = (data[0], data[1], data[2], data[3], data[4], r_hlv, r_vol, data[7], data[8])

                reference_gain[day] = sum(x[8] for x in _daily_quotes[day])/len(_daily_quotes[day])

                counter += 1
                if counter//10 != counter_p or counter==len(_daily_quotes):
                        counter_p += 1
                        sys.stdout.write("\rCompleted: %d/%d (%1.0f%%)" % (counter, len(_daily_quotes), 100*counter/len(_daily_quotes)))
                        sys.stdout.flush()

        sys.stdout.write("\n")


def select_samples():
        '''
        For each day, keep only n samples based on liquidity in _daily_quotes.
        '''
        print("\nSelecting samples...")

        counter, counter_p = 0, 0

        for day in _daily_quotes:
                if len(_daily_quotes[day]) > _num_stocks:
                        _daily_quotes[day].sort(key=lambda x: x[7], reverse=True)
                        _daily_quotes[day] = daily_quotes[day][:_num_stocks]

                counter += 1
                if counter//10 != counter_p or counter==len(_daily_quotes):
                        counter_p += 1
                        sys.stdout.write("\rCompleted: %d/%d (%1.0f%%)" % (counter, len(_daily_quotes), 100*counter/len(_daily_quotes)))
                        sys.stdout.flush()

        sys.stdout.write("\n")


def compute_coeff():
        '''
        Compute coefficients using linear regression.
        0 itc
        1 prc
        2 mom
        3 hlv
        4 vol
        '''
        print("\nComputing regression coefficients...")

        counter, counter_p = 0, 0

        for day in _daily_quotes:
                clf = linear_model.LinearRegression()
                data = _daily_quotes[day]

                y = list(x[1] for x in data)
                x = list([x[2], x[3], x[4], x[5], x[6]] for x in data)

                clf.fit(x, y)

                coeffs = clf.coef_.copy()
                coeffs[0] = clf.intercept_
                daily_coeffs[day] = coeffs
                daily_stats[day] = {'score': clf.score(x, y), 'ssize':len(data)}

                counter += 1
                if counter//10 != counter_p or counter==len(_daily_quotes):
                        counter_p += 1
                        sys.stdout.write("\rCompleted: %d/%d (%1.0f%%)" % (counter, len(_daily_quotes), 100*counter/len(_daily_quotes)))
                        sys.stdout.flush()

        sys.stdout.write("\n")


def write_results_to_file():
        print("\nWriting coefficients to file...")

        entries = []
        for day in daily_coeffs:
                entry = [day,]
                entry.extend(_daily_coeffs[day])
                entry.append(_daily_stats[day]['score'])
                entry.append(_daily_stats[day]['ssize'])
                entries.append(entry)
        entries.sort(key=lambda x:x[0])

        with open("coeffs.txt", 'w') as f:
                f.write("Date\t\tint\tprc\tmom\thlv\tvol\tR^2\ts_size\n")
                for entry in entries:
                        f.write("%s\t%1.3f\t%1.3f\t%1.3f\t%1.3f\t%1.3f\t%1.3f\t%d\n"%(entry[0].isoformat(), entry[1], entry[2], entry[3], entry[4], entry[5], entry[6], entry[7]))

        with open("coeffs_full_length.txt", 'w') as f:
                f.write("Date,int,prc,mom,hlv,vol,R^2,s_size\n")
                for entry in entries:
                        f.write("%s,%1.8f,%1.8f,%1.8f,%1.8f,%1.8f,%1.8f,%d\n"%(entry[0].isoformat(), entry[1], entry[2], entry[3], entry[4], entry[5], entry[6], entry[7]))

        print("Done!")


def export_daily_quotes():
        print("\nExporting data to files...")

        counter, counter_p = 0, 0
        if not os.path.exists("./Daily/"):
                os.makedirs("./Daily/")
        if not os.path.exists("./DailyFullLength/"):
                os.makedirs("./DailyFullLength/")

        for day in _daily_quotes:
                with open("./Daily/"+day.isoformat()+".txt", 'w') as f:
                        f.write("Code\tR\tprc\tmom\thlv\tvol\n")
                        for x in _daily_quotes[day]:
                                f.write("%s\t%1.4f\t%1.4f\t%1.4f\t%1.4f\t%1.4f\n"%(x[0],x[1],x[3],x[4],x[5],x[6]))

                with open("./DailyFullLength/"+day.isoformat()+".txt", 'w') as f:
                        f.write("Code,R,prc,mom,hlv,vol\n")
                        for x in self._daily_quotes[day]:
                                f.write("%s,%1.8f,%1.8f,%1.8f,%1.8f,%1.8f\n"%(x[0],x[1],x[3],x[4],x[5],x[6]))

                counter += 1
                if counter//10 != counter_p or counter==len(_daily_quotes):
                        counter_p += 1
                        sys.stdout.write("\rCompleted: %d/%d (%1.0f%%)" % (counter, len(_daily_quotes), 100*counter/len(_daily_quotes)))
                        sys.stdout.flush()

        sys.stdout.write("\n")
        print("Done!")


def simulate_transactions():
        print("\nTesting results...")
        
        counter, counter_p = 0, 0

        daily_gains = []
        daily_weight_multiplier = {}
        daily_t_stats = {}
        total_fees = 0 # only applicable to sell orders
        transaction_fee_multiplier = 0.0000218 # * value sold
        FINRA_multiplier = 0.000119 # * quantity sold

        # Compute daily gains
        for day in daily_quotes:
                coeffs = daily_coeffs[day]
                data = daily_quotes[day]
                sum_residuals = 0
                day_gain = 0
                sum_epsilon2 = 0

                # Finding weight multiplier
                for i in range(len(data)):
                        # resid = Ris    -itc      -prc              -mom              -hlv              -vol
                        epsilon = data[i][1]-coeffs[0]-data[i][3]*coeffs[1]-data[i][4]*coeffs[2]-data[i][5]*coeffs[3]-data[i][6]*coeffs[4]
                        sum_residuals += abs(epsilon)
                        sum_epsilon2 += epsilon**2
                        data[i] = (data[i][0], data[i][1], data[i][2], data[i][3], data[i][4], data[i][5], data[i][6], data[i][7], data[i][8], epsilon)

                if sum_residuals != 0:
                        weight_multiplier = -1/sum_residuals
                        daily_weight_multiplier[day] = weight_multiplier
                else:
                        weight_multiplier = 0
                
                # Compute dollar holdings for each stock
                for i in range(len(data)):
                        weight = weight_multiplier * data[i][9]
                        data[i] = (data[i][0], data[i][1], data[i][2], data[i][3], data[i][4], data[i][5], data[i][6], data[i][7], data[i][8], data[i][9], weight)

                        gain = weight * data[i][8]  # percentage gain = weight * intraday return
                        # weight is the dollar amount of this stock
                        transaction_fee = transaction_fee_multiplier * abs(weight) + FINRA_multiplier * abs(weight) / data[i][3] # volume = dollar amount / price
                        total_fees += transaction_fee
                        if abs(gain) > 0.2:
                                print("%s %s weight:%1.4f ir:%1.4f gain:%1.4f transaction fees:%1.4f"%(day.isoformat(), data[i][0], weight, data[i][8], gain, total_fees))
                        day_gain += gain - transaction_fee

                if weight_multiplier != 0:
                        daily_gains.append((day, day_gain, total_fees))

                        # Compute T-stats
                        t_hat = (sum_epsilon2/self._num_stocks)**0.5
                        coeffs = self._daily_coeffs[day]
                        x = np.array(list([x[2], x[3], x[4], x[5], x[6]] for x in self._daily_quotes[day]))
                        x_t = np.transpose(x)
                        product = np.dot(x_t, x)
                        temp = np.linalg.inv(product)
                        lam = list(temp[i][i]*t_hat for i in range(5)) # diagonal entries
                        t_stats = list(coeffs[i]/lam[i] for i in range(5))
                        daily_t_stats[day] = t_stats

                counter += 1
                if counter//10 != counter_p or counter==len(self._daily_quotes):
                        counter_p += 1
                        sys.stdout.write("\rCompleted: %d/%d (%1.0f%%)" % (counter, len(self._daily_quotes), 100*counter/len(self._daily_quotes)))
                        sys.stdout.flush()

        sys.stdout.write("\n")


        # Compute final result
        daily_gains.sort(key=lambda x:x[0])
        result = {}
        result['total days'] = len(daily_gains)
        result['winning days'] = sum(1 for x in daily_gains if x[1]>0)
        result['losing days'] = sum(1 for x in daily_gains if x[1]<0)
        result['win rate'] = result['winning days']/result['total days']
        result['average win'] = sum(x[1] for x in daily_gains if x[1]>0)/result['winning days']
        result['average loss'] = sum(-x[1] for x in daily_gains if x[1]<0)/result['losing days']
        result['profit factor'] = sum(x[1] for x in daily_gains if x[1]>0)/sum(-x[1] for x in daily_gains if x[1]<0)
        
        result['arithmetic average daily return'] = sum(x[1] for x in daily_gains)/result['total days']
        result['cumulative return'] = sum(x[1] for x in daily_gains)
        result['max daily return'] = max(x[1] for x in daily_gains)
        result['max daily drawdown'] = min(x[1] for x in daily_gains)

        result['daily return stdev'] = statistics.stdev(list(x[1] for x in daily_gains))
        result['information ratio'] = result['arithmetic average daily return']/result['daily return stdev']
        result['sharpe ratio'] = result['information ratio']*(252**0.5)
        result['total transaction fee'] = sum(x[2] for x in daily_gains)
        result['daily transaction fee'] = result['total transaction fee'] / result['total days']
        
        result['reference cumulative return'] = 0
        for key in self._reference_gain:
                result['reference cumulative return'] += self._reference_gain[key]

        result['cumulative compounded return'] = 1
        for x in daily_gains:
                result['cumulative compounded return'] *= 1+x[1]
        result['cumulative compounded return'] -= 1
        
        result['max consecutive wins'] = 0
        result['max consecutive losses'] = 0
        result['max drawdown'] = 1

        record = []
        current_value = 1
        current_comp_value = 1
        current_ref_value = 1
        wins_count, losses_count, drawdown_count = 0, 0, 1

        for i in range(len(daily_gains)):
                current_value += daily_gains[i][1]
                current_comp_value *= (1+daily_gains[i][1])
                current_ref_value += self._reference_gain[daily_gains[i][0]]
                record.append((daily_gains[i][0], daily_gains[i][1], current_value, current_comp_value, current_ref_value))
                if daily_gains[i][1]>0:
                        wins_count += 1
                        losses_count = 0
                        drawdown_count = 1
                        if wins_count > result['max consecutive wins']:
                                result['max consecutive wins'] = wins_count
                else:
                        wins_count = 0
                        losses_count += 1
                        drawdown_count *= (1+daily_gains[i][1])
                        if losses_count > result['max consecutive losses']:
                                result['max consecutive losses'] = losses_count
                        if drawdown_count < result['max drawdown']:
                                result['max drawdown'] = drawdown_count

        result['max drawdown'] = 1 - result['max drawdown']

        result['average_t_stats'] = [0,0,0,0,0]
        for day in daily_t_stats:

                for i in range(5):
                        result['average_t_stats'][i] += abs(daily_t_stats[day][i])
        for i in range(5):
                result['average_t_stats'][i] = result['average_t_stats'][i]/result['total days']


        self._results = result

        # Print result to file

        with open("result.txt",'w') as f:
                for key in result:
                        f.write("%s = %s\n"%(key, str(result[key])))

                f.write("\nDate\t\tReturn\t\tVal\t\tVal(Comp)\tRef\tTrn\n")

                for i in range(len(daily_gains)):
                        f.write("%s\t%1.3f%%\t\t%1.5f\t\t%1.5f\t\t%1.5f\t\t1.5f\n"%(daily_gains[i][0].isoformat(), daily_gains[i][1]*100, record[i][2], record[i][3], record[i][4], daily_gains[i][2]))

        print("Done!")

# Initialize
_files = []
_dir = "./Quotes2/"
_data = {}
_daily_quotes = {}
_daily_coeffs = {}
_daily_stats = {}
_results = {}
_reference_gain = {}
_num_stocks = int(input("Input the number of stocks : "))
scan_folder()
load_data()
process_data()
normalise_factors()
select_samples()
compute_coeff()
write_results_to_file()
simulate_transactions()

#d.export_daily_quotes()
os.system('pause')
