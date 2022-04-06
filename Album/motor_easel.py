#!/usr/bin/env python
# -*- coding: utf-8 -*-

import RPi.GPIO as GPIO
import time
import sys

CONTROL_PIN = [32, 22, 18, 16]

def main():
    if len(sys.argv) > 1: 
        if sys.argv[1] == "--help" or sys.argv[1] == "-h":
            print("This program is for turing easel.")
            print("\tAgruments:\t-h --help\tShow the helper page for this program.")
            print("\t\t1\tTurn the easel out.")
            print("\t\t0\tTurn the easel in.")
        else:
            if sys.argv[1] != "1" and sys.argv[1] != "0":
                print("Wrong aregument. See help page by motor_easel.py -h")
                sys.exit()
            GPIO.setmode(GPIO.BOARD)

            for pin in CONTROL_PIN:
                GPIO.setup(pin, GPIO.OUT)
                GPIO.output(pin, False)
                print("{} is set.".format(pin))

            if sys.argv[1] == "1":
                halfstep_seq = [   
                    [1,0,0,1],
                    [0,0,0,1],
                    [0,0,1,1],
                    [0,0,1,0],
                    [0,1,1,0],
                    [0,1,0,0],
                    [1,1,0,0],
                    [1,0,0,0]
                ]
            elif sys.argv[1] == "0":    
                halfstep_seq = [   
                    [1,0,0,0],
                    [1,1,0,0],
                    [0,1,0,0],
                    [0,1,1,0],
                    [0,0,1,0],
                    [0,0,1,1],
                    [0,0,0,1],
                    [1,0,0,1]
                ]
            print(halfstep_seq)

            if len(sys.argv) > 2 and float(sys.argv[2]) <= 0.075:
                turn = float(sys.argv[2])
            else:
                turn = 0.075
                
            np = int(512 * turn)
            print(np)
            for _ in range(np):
                for halfstep in range(8):
                    for pin in range(4):
                        # print(control_pins[pin], halfstep_seq[halfstep][pin])
                        if halfstep_seq[halfstep][pin] == 1:
                            GPIO.output(CONTROL_PIN[pin], True)
                        else:
                            GPIO.output(CONTROL_PIN[pin], False)
                    time.sleep(0.00067) # 0.00067

            for pin in CONTROL_PIN:
                GPIO.output(pin, False)
            GPIO.cleanup()
    else: print("Need argument. See help page by motor_easel.py -h")

if __name__ == '__main__':
    try:
        main()
    # except KeyboardInterrupt:
    except:
        GPIO.cleanup()       


