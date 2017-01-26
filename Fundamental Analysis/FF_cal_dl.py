#!/usr/bin/env python

from __future__ import unicode_literals
import sys
import datetime
import getopt
# import codecs
import pprint
import lxml.html
import mechanize
import cookielib

# some utils
pp = pprint.PrettyPrinter()
debug = 0


#########################
# variables
#########################
START_YEAR = datetime.datetime.now().year
END_YEAR = START_YEAR
WEEKURL = r"http://www.forexfactory.com/calendar.php?week="
MONTHURL = r"http://www.forexfactory.com/calendar.php?month="
#OUTFILE = r"events.csv"
USAGE = "ffcal.py <-h> <-f {filename}> <-w {this|next|mmmdd.yyyy}> <-m {this|next|mmm.yyyy}>\n"
#########################


# our month list for the URL
monthslist = ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"]

# sets up the browser
br = mechanize.Browser()
cj = cookielib.LWPCookieJar()
br.set_cookiejar(cj)
br.addheaders = [('User-agent', 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.1) Gecko/2008071615 Fedora/3.0.1-1.fc9 Firefox/3.0.1')]

# set correct timezone
br.open("http://www.forexfactory.com/timezone.php")
formindex = 0
for form in br.forms():
    if "timezone.php" in form.action:
        form["timezoneoffset"] = ["0"]
        break
    formindex += 1

br.select_form(nr=formindex)
# br.submit()


def getData(html, outfile):
    """
    Gets data from one page of events
    """
    root = lxml.html.fromstring(html)
    #lines = root.find_class("calendar__row calendar_row calendar__row--grey")
    #if not lines:
    lines = root.find_class("calendar__row calendar_row")

    # curWeekDay = None
    curMonthDay = None
    time = curTime = ""
    # pp.pprint(lines)
    for event in lines:
        # pp.pprint(event)
        if len(event.xpath("td[@class='calendar__cell calendar__date date']")) > 0:
            date = event.xpath("td[@class='calendar__cell calendar__date date']")[0]
        else:
            sys.exit("BOOM")

        # get the day of the month
        weekDay = date.xpath("span")
        monthDay = date.xpath("span/span")
        if len(weekDay) > 0:
            # curWeekDay = weekDay[0].text
            # print "curWeekDay=[" + curWeekDay + "]"
            curMonthDay = monthDay[0].text
            if debug:
                print "curMonthDay=[" + curMonthDay + "]"

        # get the time
        curTime = time
        time = event.xpath("td[contains(@class, 'calendar__time')]")[0].text if len(event.xpath("td[contains(@class, 'calendar__time')]")) else ""
        if time == '' or time == None:
            time = curTime
        if debug:
            print "time=[" + str(time) + "]"

        # get currency
        currency = event.xpath("td[contains(@class, 'calendar__currency')]")[0].text if len(event.xpath("td[contains(@class, 'calendar__currency')]")) else ""
        if currency == None:
            continue
        if debug:
            print "currency=[" + currency + "]"

        # get impact
        impact = event.xpath("td[contains(@class, 'calendar__impact')]/div/span/@title")[0] if len(event.xpath("td[contains(@class, 'calendar__impact')]/div/span/@title")) else ""
        if debug:
            print "impact=[" + impact + "]"

        # get name of event
        nevent = event.xpath("td[contains(@class, 'calendar__event')]/div/span")[0].text if len(event.xpath("td[contains(@class, 'calendar__event')]/div/span")) else ""
        if debug:
            print "nevent=[" + nevent + "]"

        # get actual
        actual = event.xpath("td[contains(@class, 'calendar__actual')]/span")[0].text if len(event.xpath("td[contains(@class, 'calendar__actual')]/span")) else ""

        # retry if actual is in a span (can happen if they colorize it)
        # if actual is None or len(actual.strip()) == 0:
        #     actual = event.xpath("td[@class='actual']/span")[0].text if len(event.xpath("td[@class='actual']/span")) else ""
        actual = actual.strip().replace("\n", " ") if actual is not None else ""
        if debug:
            print "actual=[" + actual + "]"

        # get forecast
        forecast = event.xpath("td[contains(@class, 'calendar__forecast')]")[0].text if len(event.xpath("td[contains(@class, 'calendar__forecast')]")) else ""
        # retry if forecast is in a span (can happen if they colorize it)
        # if forecast is None or len(forecast.strip()) == 0:
        #    forecast = event.xpath("td[@class='forecast']/span")[0].text if len(event.xpath("td[@class='forecast']/span")) else ""
        forecast = forecast.strip().replace("\n", " ") if forecast is not None else ""
        if debug:
            print "forecast=[" + forecast + "]"

        # get previous
        previous = event.xpath("td[contains(@class, 'calendar__previous')]")[0].text if len(event.xpath("td[contains(@class, 'calendar__previous')]")) else ""
        # retry if previous is in a span (can happen if they colorize it)
        if previous is None or len(previous.strip()) == 0:
            previous = event.xpath("td[contains(@class, 'calendar__previous')]/span")[0].text if len(event.xpath("td[contains(@class, 'calendar__previous')]/span")) else ""
        previous = previous.strip().replace("\n", " ") if previous is not None else ""
        if debug:
            print "previous=[" + previous + "]\n"

        outfile.write("{};{};{};{};{};{};{};{}\n".format(curMonthDay, time, currency, impact, nevent, actual, forecast, previous))


OUTFILE = ""

try:
    opts, args = getopt.getopt(sys.argv[1:], "f:hm:w:")
except getopt.GetoptError:
    sys.stderr.write(USAGE)
    sys.exit(2)

for opt, arg in opts:

    if opt == "-h":
        sys.stderr.write(USAGE)
        sys.exit()

    if opt == "-f":
        OUTFILE = arg
    elif opt == "-w" or opt == "-m":
        outfile = open(OUTFILE, "w") if OUTFILE != "" else sys.stdout
        if opt == "-w":
            url = "{}{}".format(WEEKURL, arg)
        else:
            url = "{}{}".format(MONTHURL, arg)
        sys.stderr.write("Getting {} from {}\n".format(arg, url))
        br.open(url)
        html = br.response().read()
        getData(html, outfile)
        if outfile is not sys.stdout:
            outfile.close()
        sys.exit()

year = START_YEAR
outfile = open(OUTFILE, "w") if OUTFILE != "" else sys.stdout
while year <= END_YEAR:
    for month in monthslist:
        url = "{}{}.{}".format(MONTHURL, month, year)
        sys.stderr.write("Getting {} {} from {}\n".format(month.title(), year, url))
        br.open(url)
        html = br.response().read()
        getData(html, outfile)
    year += 1
if outfile is not sys.stdout:
    outfile.close()