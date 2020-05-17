# Filename:    lcd.py
# Author:      Ashley Huxley
# Description: Class to represent a DS18B20 temperature sensor and read in the values.


import time
import os

class Sensor:
    def __init__(self, name, id):
        self.name = name
        self.id = id

    def __read_file(self, device_file):
        f = open(device_file, 'r')
        lines = f.readlines()
        f.close()
        return lines

    def read_temp(self):
        device_file = '/sys/bus/w1/devices/' + self.id + '/w1_slave'
        lines = self.__read_file(device_file)
        while lines[0].strip()[-3:] != 'YES':
            time.sleep(0.2)
            lines = read_temp_raw()
        equals_pos = lines[1].find('t=')
        if equals_pos != -1:
            temp_string = lines[1][equals_pos+2:]
            temp_c = float(temp_string) / 1000.0
            return temp_c

# Add sensor IDs here
poolSensor = Sensor('pool', '')
airSensor = Sensor('air', '')
outputSensor = Sensor('output', '')

