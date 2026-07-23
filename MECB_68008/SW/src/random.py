#!/usr/bin/env python
import numpy as np

stuff = 0x0000

def r(stuff):
    a = stuff
    a <<= 10
    a &= 0xFFFF
    a += stuff
    a <<= 2
    a += stuff
    a += 0x3619
    stuff = (a & 0xFFFF)
    return stuff

values = np.zeros((65536))
for x in range(1000000):
    stuff = r(stuff)
    values[stuff] += 1

print(np.min(values), np.max(values))