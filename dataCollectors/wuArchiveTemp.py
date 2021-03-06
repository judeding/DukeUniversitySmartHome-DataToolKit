# -*- coding: utf-8 -*-
"""
Created on Tue Feb 10 14:04:37 2015

@author: Raghav Saboo and Sharrin Manor 
"""

import csv
import time
import urllib
import sys

## arguments to be provided when running the script from the prompt <python wuArchiveTemp.py dd mm yyyy numDays>

dd = str(sys.argv[1])
mm = str(sys.argv[2])
yyyy = str(sys.argv[3])
numDays = int(sys.argv[4])

#wuArchive(dd, mm, yyyy, numDays):
## dd/mm/yyyy format

dateStr = str(yyyy+'/'+mm+'/'+dd)
yearInt = int(dateStr[0:4])
monthInt = int(dateStr[5:7])

# if the month or day is less than ten, the zero before it gets cut off
dayInt = int(dateStr[8:10])

# open a file for writing.
csv_out = open("wuTempArchive.csv",'wb')

# create the csv writer object.
mywriter = csv.writer(csv_out)

###---------------------------------------------------------------------------------------------------------
while numDays !=0:
	url = 'http://www.wunderground.com/history/airport/KRDU/' +dateStr+ '/DailyHistory.html?format=1'
	print url
	data = urllib.urlopen(url)
#datareader = data.splitlines(data)
	reader = csv.reader(data)
	tempD = [row for row in reader]
	mywriter.writerows(tempD[2:])

	numDays = numDays-1

	if dayInt == 1:
		monthInt = monthInt-1
		#0 month means 12 this is fixed later below
		if (monthInt == 1) or (monthInt == 3) or (monthInt == 5) or (monthInt == 7) or (monthInt == 8) or (monthInt==10) or (monthInt==0):
			dayInt = 31
		elif (monthInt == 4) or (monthInt == 6) or (monthInt ==9) or (monthInt==11):
			dayInt = 30
		else:
			dayInt = 28

	else:
		dayInt = dayInt-1

	if monthInt == 0:
		monthInt = 12
		yearInt = yearInt - 1

## add zeros for the string numbers

	if dayInt < 10:
		dayStr = '0' + str(dayInt)
	else:
		dayStr = str(dayInt)


	if monthInt < 10:
		monthStr = '0' + str(monthInt)
	else:
		monthStr = str(monthInt)

	dateStr = str(yearInt)+'/'+monthStr+'/'+dayStr

csv_out.close()