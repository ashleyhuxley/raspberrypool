# Filename:    flush.py
# Author:      Ashley Huxley
# Description: Flushes the contents of offline backup file to Azure storage.


import os
import time
import sys
from datetime import datetime
from azure.cosmosdb.table.tableservice import TableService
from azure.cosmosdb.table.models import Entity

table_service = TableService(account_name='', account_key='')

def log(line):
	vals = line.split(",")
	now = datetime.strptime(vals[2], "%Y-%m-%d %H:%M:%S.%f")

	log = Entity()
	log.PartitionKey = now.strftime('%Y%m%d-%H')
	log.RowKey = vals[0].upper() + now.strftime('%Y%m%d-%H%M%S')
	log.SensorId = vals[0]
	log.Value = float(vals[1])
	log.LogTime = now
	print(log.RowKey)
	table_service.insert_or_replace_entity('Data', log);

def read_lines(file):
	f = open(file, 'r')
	lines = f.readlines()
	f.close()
	return lines

lines = read_lines("/var/raspberrypool/offline.csv")
for line in lines:
	log(line.rstrip())
