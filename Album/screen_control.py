#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# argv parsing: https://docs.python.org/3/library/getopt.html

import sys
import getopt
import RPi.GPIO as GPIO 
import subprocess
import time
import board
import busio
import adafruit_ads1x15.ads1015 as ADS
from adafruit_ads1x15.analog_in import AnalogIn
import xml_parse

"""
Motion sensor setup
"""
# return the argument of the certain flag
def get_opt(optlist: list, target_opt: str):
    for opt in optlist:
        if opt[0] == target_opt:
            return opt[1]
    return None

def format_arg(arg, default):    
    if arg is None: 
        return default
    else:
        return float(arg)


gpio_mode = GPIO.BCM 
    # Note: In this code, the mode can't be BOARD. 
    #       Might due to other module imported in this code
GPIO.setmode(gpio_mode)
optlist, args = getopt.getopt(sys.argv[1:], 'm:b:t:a')

# MOTION_DARK_DELAY:        How many seconds of no motion detected before the display going dark
#                           Flag: -m
#                           Default: 300
MOTION_DARK_DELAY = format_arg(get_opt(optlist, "-m"), 300)

# BRIGHTNESS_DARK_DELAY:    How many seconds of too bright detected before the display going dark
#                           Flag: -b
#                           Default: 1.5
BRIGHTNESS_DARK_DELAY = format_arg(get_opt(optlist, "-b"), 1.5)

# BRIGHTNESS_THRESHOLD:     The threshold to determine how much is too bright
#                           The threshold is compared with the voltage, and lower than threshold
#                           is considered too bright.
#                           Flag: -t
#                           Default: 0.05
BRIGHTNESS_THRESHOLD = format_arg(get_opt(optlist, "-t"), 0.05)

AUTO = not (get_opt(optlist, "-a") is None)

# the pin that read input from motion sensor
# BOARD:   7
# BCM:     4
if gpio_mode == GPIO.BCM:
    PIR_PIN = 4
else:
    PIR_PIN = 7

IO_DELAY = 5
LOOP_DELAY = 0.1

"""
Light sensor and ADC setup
"""
# Create the I2C bus
i2c = busio.I2C(board.SCL, board.SDA)
# Create the ADC object using the I2C bus
ads = ADS.ADS1015(i2c)
# Create single-ended input on channel 0
chan = AnalogIn(ads, ADS.P0)

def main():
    GPIO.setup(PIR_PIN, GPIO.IN)
    sence_motion = True
    sence_dark = True
    turned_off = False
    last_motion_time = time.time()
    last_dark_time = time.time()
    while True:
        for _ in range(int(IO_DELAY / LOOP_DELAY)):
            if MOTION_DARK_DELAY <= 0:
                sence_motion = True
            else:
                if GPIO.input(PIR_PIN):
                    print("Sence motion!")
                    last_motion_time = time.time()
                    sence_motion = True            
                elif sence_motion and time.time() > (last_motion_time + MOTION_DARK_DELAY):
                    sence_motion = False
                    turned_off = True
                    turn_off()
            
            if BRIGHTNESS_THRESHOLD <= 0 or BRIGHTNESS_DARK_DELAY <= 0:
                sence_dark = True
            else:
                if chan.voltage >= BRIGHTNESS_THRESHOLD:
                    last_dark_time = time.time()
                    sence_dark = True
                elif sence_dark and time.time() > (last_dark_time + BRIGHTNESS_DARK_DELAY):
                    print("Too bright!")
                    sence_dark = False
                    turned_off = True
                    turn_off()
                
                if turned_off and sence_dark and sence_motion:      
                    turned_off = False      
                    turn_on()

            time.sleep(LOOP_DELAY)
        
        MOTION_DARK_DELAY = xml_parse.get_motion_dark_delay()
        BRIGHTNESS_DARK_DELAY = xml_parse.get_light_dark_delay()
        BRIGHTNESS_THRESHOLD = xml_parse.get_light_threshold()

def turn_on():
    CONTROL = "vcgencmd"
    CONTROL_UNBLANK = [CONTROL, "display_power", "1"]
    subprocess.call(CONTROL_UNBLANK)

def turn_off():
    CONTROL = "vcgencmd"
    CONTROL_BLANK = [CONTROL, "display_power", "0"]
    subprocess.call(CONTROL_BLANK)


if __name__ == '__main__':
    try:
        main()
    # except KeyboardInterrupt:
    except:
        turn_on()
        GPIO.cleanup()         

