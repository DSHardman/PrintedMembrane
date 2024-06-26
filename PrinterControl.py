import numpy as np
import random
import time
import serial
from datetime import datetime

Cornerposition = (43.6, 19.6, 12)
targetforce = 0.3  # In N
retractheight = 15
step = 0.05
waittime = 5
savestring = "RawData/PartRadial2"

Ender = serial.Serial("COM10", 115200)
Forces = serial.Serial("COM9", 115200)
time.sleep(2)

def waitforposition():
    Ender.flush()
    Ender.write(str.encode("M114 R\r\n"))
    while True:
        line = Ender.readline()
        if line.find(b'Count') != -1:
            break
    return

def takereading(targetforce):
    starttime = datetime.now()
    Ender.write(str.encode("G1 Z" + str(Cornerposition[2]) + " F400\r\n"))
    waitforposition()
    Forces.flushInput()
    while 1:
        try:
            force = float(Forces.readline())
            break
        except ValueError:
            print("No force, trying again")
    n = 1
    while (force < targetforce):
        Ender.write(str.encode("G1 Z" + str(Cornerposition[2] - n*step) + " F400\r\n"))
        waitforposition()
        Forces.flushInput()

        while 1:
            try:
                force = float(Forces.readline())
                break
            except ValueError:
                print("No force, trying again")
        n += 1
        if n*step > 5:  # Do not descend further than 5 mm
            break
    midtime = datetime.now()
    time.sleep(waittime)
    Ender.write(str.encode("G1 Z" + str(Cornerposition[2] + retractheight) + " F400\r\n"))
    waitforposition()
    endtime = datetime.now()
    return starttime, midtime, endtime


def setup():
    Ender.write(str.encode("G28\r\n"))
    Ender.write(str.encode("G1 Z"+str(Cornerposition[2]+retractheight)+" F400\r\n"))
    Ender.write(str.encode("G1 X "+str(Cornerposition[0])+" Y "+str(Cornerposition[1])+" F1000\r\n"))
    waitforposition()

def main():


    # Random probing at 0.3N
    targetforce = 0.3  # In N
    for i in range(1000):
        print(i)
        x = 18.16*random.random() + 1  # 22.86 side length
        y = 25.78*random.random() + 1  # 30.48 side length
        Ender.write(str.encode("G1 X "+str(Cornerposition[0]+x)+" Y "+str(Cornerposition[1]+y)+" F800\r\n"))
        waitforposition()
        times = takereading(targetforce)
        with open(savestring+'0_3.txt', 'a') as file:
            file.write('%s, %s, %s, %s, %s\n' % (str(x), str(y), times[0], times[1], times[2]))
        time.sleep(waittime)

    # Random depth probing
    for i in range(10000):
        targetforce = 1.0*random.random()  # Random force up to 1.0 N
        print(i)
        x = 18.16*random.random() + 1  # 22.86 side length
        y = 25.78*random.random() + 1  # 30.48 side length
        Ender.write(str.encode("G1 X "+str(Cornerposition[0]+x)+" Y "+str(Cornerposition[1]+y)+" F800\r\n"))
        waitforposition()
        times = takereading(targetforce)
        with open(savestring+'random.txt', 'a') as file:
            file.write('%s, %s, %s, %s, %s, %s\n' % (str(x), str(y), str(targetforce), times[0], times[1], times[2]))
        time.sleep(waittime)

    # # Random probing at 0.5N
    # targetforce = 0.5  # In N
    # for i in range(595, 1000):
    #     print(i)
    #     x = 18.16*random.random() + 1  # 22.86 side length
    #     y = 25.78*random.random() + 1  # 30.48 side length
    #     Ender.write(str.encode("G1 X "+str(Cornerposition[0]+x)+" Y "+str(Cornerposition[1]+y)+" F800\r\n"))
    #     waitforposition()
    #     times = takereading(targetforce)
    #     with open(savestring+'0_5.txt', 'a') as file:
    #         file.write('%s, %s, %s, %s, %s\n' % (str(x), str(y), times[0], times[1], times[2]))
    #     time.sleep(waittime)
    #
    # # Random probing at 0.7N
    # targetforce = 0.7  # In N
    # for i in range(1000):
    #     print(i)
    #     x = 18.16 * random.random() + 1  # 22.86 side length
    #     y = 25.78 * random.random() + 1  # 30.48 side length
    #     Ender.write(str.encode("G1 X " + str(Cornerposition[0] + x) + " Y " + str(Cornerposition[1] + y) + " F800\r\n"))
    #     waitforposition()
    #     times = takereading(targetforce)
    #     with open(savestring + '0_7.txt', 'a') as file:
    #         file.write('%s, %s, %s, %s, %s\n' % (str(x), str(y), times[0], times[1], times[2]))
    #     time.sleep(waittime)
    #
    # # Random probing at 1N
    # targetforce = 1.0  # In N
    # for i in range(1000):
    #     print(i)
    #     x = 18.16 * random.random() + 1  # 22.86 side length
    #     y = 25.78 * random.random() + 1  # 30.48 side length
    #     Ender.write(str.encode("G1 X " + str(Cornerposition[0] + x) + " Y " + str(Cornerposition[1] + y) + " F800\r\n"))
    #     waitforposition()
    #     times = takereading(targetforce)
    #     with open(savestring + '1_0.txt', 'a') as file:
    #         file.write('%s, %s, %s, %s, %s\n' % (str(x), str(y), times[0], times[1], times[2]))
    #     time.sleep(waittime)
    #
    # # Repetition data: 3 points, 4 forces, 5 repetitions
    # xs = [5, 5, 10]
    # ys = [5, 15, 15]
    # for i in range(5):
    #     for j in range(3):
    #
    #         x = xs[j]
    #         y = ys[j]
    #
    #         targetforce = 0.3
    #         Ender.write(str.encode("G1 X " + str(Cornerposition[0] + x) + " Y " + str(Cornerposition[1] + y) + " F800\r\n"))
    #         waitforposition()
    #         times = takereading(targetforce)
    #         with open(savestring + 'repeats.txt', 'a') as file:
    #             file.write('%s, %s, %s, %s, %s\n' % (str(x), str(y), times[0], times[1], times[2]))
    #         time.sleep(waittime)
    #
    #         targetforce = 0.5
    #         Ender.write(str.encode("G1 X " + str(Cornerposition[0] + x) + " Y " + str(Cornerposition[1] + y) + " F800\r\n"))
    #         waitforposition()
    #         times = takereading(targetforce)
    #         with open(savestring + 'repeats.txt', 'a') as file:
    #             file.write('%s, %s, %s, %s, %s\n' % (str(x), str(y), times[0], times[1], times[2]))
    #         time.sleep(waittime)
    #
    #         targetforce = 0.7
    #         Ender.write(str.encode("G1 X " + str(Cornerposition[0] + x) + " Y " + str(Cornerposition[1] + y) + " F800\r\n"))
    #         waitforposition()
    #         times = takereading(targetforce)
    #         with open(savestring + 'repeats.txt', 'a') as file:
    #             file.write('%s, %s, %s, %s, %s\n' % (str(x), str(y), times[0], times[1], times[2]))
    #         time.sleep(waittime)
    #
    #         targetforce = 1.0
    #         Ender.write(str.encode("G1 X " + str(Cornerposition[0] + x) + " Y " + str(Cornerposition[1] + y) + " F800\r\n"))
    #         waitforposition()
    #         times = takereading(targetforce)
    #         with open(savestring + 'repeats.txt', 'a') as file:
    #             file.write('%s, %s, %s, %s, %s\n' % (str(x), str(y), times[0], times[1], times[2]))
    #         time.sleep(waittime)

setup()
main()