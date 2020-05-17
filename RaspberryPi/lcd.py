# Filename:    lcd.py
# Author:      Ashley Huxley
# Description: Outputs temperature to LCD. Run as a cron job every 10 seconds.


from temp import poolSensor, airSensor, outputSensor
import board
import digitalio
import adafruit_character_lcd.character_lcd as characterlcd

p = round(poolSensor.read_temp(), 1)
a = round(airSensor.read_temp(), 1)
h = round(outputSensor.read_temp(), 1)

# Pin assignments for LCD
lcd_rs = digitalio.DigitalInOut(board.D26)
lcd_en = digitalio.DigitalInOut(board.D19)
lcd_d7 = digitalio.DigitalInOut(board.D27)
lcd_d6 = digitalio.DigitalInOut(board.D22)
lcd_d5 = digitalio.DigitalInOut(board.D24)
lcd_d4 = digitalio.DigitalInOut(board.D25)

# LCD Character Size
lcd_columns = 16
lcd_rows = 2

lcd = characterlcd.Character_LCD_Mono(lcd_rs, lcd_en, lcd_d4, lcd_d5, lcd_d6, lcd_d7, lcd_columns, lcd_rows)

# Custom symbols
deg = [	0x18,0x18,0x3,0x4,0x4,0x4,0x3,0x00 ]        # °C
sym_a = [ 0xe,0x1b,0x1f,0x1b,0x1b,0x0,0x1f,0x00 ]   # Underlined A (Air)
sym_p = [ 0x1e,0x1b,0x1e,0x18,0x18,0x0,0x1f,0x00 ]  # Underlined P (Pool)
sym_h = [ 0x1b,0x1b,0x1f,0x1b,0x1b,0x0,0x1f,0x00 ]  # Underlined H (Heater output)

lcd.create_char(0, deg)
lcd.create_char(1, sym_a)
lcd.create_char(2, sym_p)
lcd.create_char(3, sym_h)

lcd.message = '\x02 {0:0.1f}\x00 \x03 {2:0.1f}\x00\n\x01 {1:0.1f}\x00'.format(p, a, h)