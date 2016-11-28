import pandas as pd
import urllib.request
import os

# current working directory
sys_cwd = os.path.dirname(os.path.realpath(__file__))

# url for company list csv file (from nasdaq.com)
src_url = {
	"AMEX": "http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=amex&render=download",
	"NASDAQ": "http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nasdaq&render=download",
	"NYSE": "http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nyse&render=download",
}

# update company list using the urls in src_url dictionary, saving csv files into companylist folder
def get_company_list():
	if not os.path.exists("./companylist/"):
		os.makedirs("./companylist/")
	for url in src_url:
		f_name = sys_cwd + "/companylist/" + url + ".csv"
		f_url = src_url[url]
		with urllib.request.urlopen(f_url) as response, open(f_name, 'wb') as out_file:
			out_file.write(response.read())
			print("updated company list for %s"%(url))

# retrieve historical quotes csv file from the company given its symbol, from yahoo finance.
def get_quotes(symbol, silent=False, no_override=True):
	if not os.path.exists("./quotes/"):
		os.makedirs("./quotes/")
	f_name = sys_cwd + "/quotes/" + symbol + ".csv"
	if os.path.exists(f_name) and no_override:
		return True
	f_url = "http://chart.finance.yahoo.com/table.csv?s=" + symbol + "&a=0&b=1&c=2013&d=11&e=31&f=2099&g=d&ignore=.csv"
	try:
		with urllib.request.urlopen(f_url) as response, open(f_name, 'wb') as out_file:
			out_file.write(response.read())
			if not silent:
				print("updated quotes for %s"%(symbol))
			return True
	except urllib.error.HTTPError:
		if not silent:
			print("invalid symbol %s"%(symbol))
		return False

# retrieve historical quotes csv file for all companies listed in selected exchange, using companylist file named ex.csv, from yahoo finance
def get_all_quotes(exchange):
	if exchange not in src_url:
		print("unsupported exchange %s"%(exchange))
		return False
	f_name = sys_cwd + "/companylist/" + exchange + ".csv"
	stock_data = pd.read_csv(f_name)
	count, count_succ, count_compl = len(stock_data["Symbol"]), 0, 0
	for sym in stock_data["Symbol"]:
		if get_quotes(sym, silent=True):
			count_succ += 1
		count_compl += 1
		print("updating quotes from %s ... %d / %d"%(exchange, count_compl, count), end="\r")
	print("update quotes for %s, %d successes, %d failures"%(exchange, count_succ, count - count_succ))
	input("Completed. Press any key to continue...")
	return True

# if __name__ == "__main__":
# 	get_company_list()
# 	get_all_quotes("NASDAQ")
get_all_quotes("NASDAQ")