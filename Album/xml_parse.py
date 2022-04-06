#!/usr/bin/env python3
# -*- coding: utf-8 -*-


# XML
#   parse: https://www.geeksforgeeks.org/xml-parsing-python/
# basic:            https://www.geeksforgeeks.org/xml-parsing-python/
# get text:    https://stackoverflow.com/questions/4573237/how-to-extract-xml-attribute-using-python-elementtree

import sys
import getopt
import xml.etree.ElementTree as ET

# xmlfile = "/home/pi/Album/setting.xml"
xmlfile = "setting.xml"

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

def get_value(branch: list):    
    # create element tree object
    tree = ET.parse(xmlfile)  
    # get root element
    root = tree.getroot()

    tmp = root
    for match in branch:
        tmp = tmp.find(match)

    return tmp.text
    
def set_value(branch: list, value: str):    
    # create element tree object
    tree = ET.parse(xmlfile)  
    # get root element
    root = tree.getroot()

    tmp = root
    for match in branch:
        tmp = tmp.find(match)

    tmp.text=value    
    tree.write(xmlfile)

def get_motion_dark_delay():      
    return float(get_value(["motion_sensor", "dark_delay"]))

def set_motion_dark_delay(value):  
    set_value(["motion_sensor", "dark_delay"], str(value))
    
def get_light_dark_delay():      
    return float(get_value(["light_sensor", "dark_delay"]))

def set_light_dark_delay(value):  
    set_value(["light_sensor", "dark_delay"], str(value))
    
def get_light_threshold():      
    return float(get_value(["light_sensor", "threshold"]))

def set_light_threshold(value):  
    set_value(["light_sensor", "threshold"], str(value))

def main():
    optlist, _ = getopt.getopt(sys.argv[1:], 'm:b:t:')
    MOTION_DARK_DELAY = get_motion_dark_delay()
    BRIGHTNESS_DARK_DELAY = get_light_dark_delay()
    BRIGHTNESS_THRESHOLD = get_light_threshold()

    # MOTION_DARK_DELAY:        How many seconds of no motion detected before the display going dark
    #                           Flag: -m
    set_motion_dark_delay(format_arg(get_opt(optlist, "-m"), MOTION_DARK_DELAY))

    # BRIGHTNESS_DARK_DELAY:    How many seconds of too bright detected before the display going dark
    #                           Flag: -b
    set_light_dark_delay(format_arg(get_opt(optlist, "-b"), BRIGHTNESS_DARK_DELAY))

    # BRIGHTNESS_THRESHOLD:     The threshold to determine how much is too bright
    #                           The threshold is compared with the voltage, and lower than threshold
    #                           is considered too bright.
    #                           Flag: -t
    set_light_threshold(format_arg(get_opt(optlist, "-t"), BRIGHTNESS_THRESHOLD))

if __name__ == "__main__":
    main()