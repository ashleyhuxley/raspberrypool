# Filename:    heatcontrol.py
# Author:      Ashley Huxley
# Description: Controls the Heater and Pump relays. Run as a cron job every 1 minute.


import pytz
from temp import poolSensor, airSensor
import sys
import uuid
from datetime import datetime, timedelta
import RPi.GPIO as GPIO
from azure.cosmosdb.table.tableservice import TableService
from azure.cosmosdb.table.models import Entity

GPIO.setmode(GPIO.BCM)

# Pin assignments for heater and pump relays
heaterPin = 18
pumpPin = 17

GPIO.setup(heaterPin, GPIO.OUT)
GPIO.setup(pumpPin, GPIO.OUT)

# How long the pool takes to heat up in degees per hour. Adjust as necessary.
rate = 1;

table_service = TableService(account_name='', account_key='')

# Function to decide whether the heater should be on based on the setting in Azure.
def heaterOn(setting):
	now = datetime.utcnow().replace(tzinfo=pytz.UTC)
	st = setting.StartTime.replace(tzinfo=pytz.UTC)
	et = setting.EndTime.replace(tzinfo=pytz.UTC)

	t = poolSensor.read_temp()

	if (now > et):
		return False

	if (now >= st):
		return t < setting.DesiredTemp
	else:
		if (t >= setting.DesiredTemp):
			return False

		tempIncrease = setting.DesiredTemp - t
		requiredTime = tempIncrease * rate
		readyTime = now + timedelta(hours=requiredTime)
		print('Estimated ready time: ' + str(readyTime))
		return readyTime > st

# Function to decide if the heater should be on based on the ambient air temp.
# Pump must always be on if heater is on.
def pumpOn(heaterOn):
	if (heaterOn):
		return True
	else:
		airTemp = airSensor.read_temp()
		poolTemp = poolSensor.read_temp()
		return airTemp > poolTemp

def log(sensor, value):
	last = table_service.get_entity('Setting', 'latest', sensor)
	if (last.IsOn != value):
		now = datetime.utcnow()
		log = Entity()
		log.PartitionKey = now.strftime('%Y%m%d-%H')
		log.RowKey = sensor.upper() + now.strftime('%Y%m%d-%H%M%S')
		log.SensorId = sensor
		log.IsOn = value
		log.LogTime = now
		table_service.insert_entity('Data', log)

	latest = Entity()
	latest.PartitionKey = 'latest'
	latest.RowKey = sensor
	latest.IsOn = value
	table_service.update_entity('Setting', latest)


setting = table_service.get_entity('Setting', 'heater', 'heater')

isHeaterOn = heaterOn(setting)
isPumpOn = pumpOn(isHeaterOn)

if (isHeaterOn):
	GPIO.output(heaterPin, GPIO.HIGH)
else:
	GPIO.output(heaterPin, GPIO.LOW)

if (isPumpOn):
	GPIO.output(pumpPin, GPIO.HIGH)
else:
	GPIO.output(pumpPin, GPIO.LOW)

log("heater", isHeaterOn)
log("pump", isPumpOn)