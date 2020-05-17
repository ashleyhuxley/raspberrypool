# Filename:    logtemp.py
# Author:      Ashley Huxley
# Description: Reads in temperatures from sensors and log to Azure storage. Run as a cron job every 1 minute.


import os
import time
import uuid
from datetime import datetime
from azure.cosmosdb.table.tableservice import TableService
from azure.cosmosdb.table.models import Entity
from temp import poolSensor, airSensor, outputSensor

table_service = TableService(account_name='', account_key='')

def log(sensor):
	temp = sensor.read_temp()
	now = datetime.utcnow()

	log = Entity()
	log.PartitionKey = now.strftime('%Y%m%d-%H')
	log.RowKey = sensor.name.upper() + now.strftime('%Y%m%d-%H%M%S')
	log.SensorId = sensor.name
	log.Value = temp
	log.LogTime = now

	latest = Entity()
	latest.PartitionKey = 'latest'
	latest.RowKey = sensor.name
	latest.Value = temp
	

	try:
		table_service.insert_entity('Data', log);
		table_service.update_entity('Setting', latest)
		print(log.RowKey)
	except:
        # Offline backup for when Azure cannot be reached
		f = open("/var/raspberrypool/offline.csv", "a+")
		f.write(sensor.name + "," + str(temp) + "," + str(now) + "\n")

log(poolSensor)
log(airSensor)
log(outputSensor)

