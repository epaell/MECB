#!/usr/bin/env python

# source: https://github.com/asweigart/pybresenham/blob/master/pybresenham/__init__.py
def plot(x,y):
    print(f"({x},{y})",end="")

# Bresenham’s Line Algorithm
def line(x1, y1, x2, y2):
    dy = abs(y2 - y1)
    dx = abs(x2 - x1)
    print(f"dx={dx}, dy={dy}")
    isSteep = (dy>dx)
    if isSteep:
        x1, y1 = y1, x1
        x2, y2 = y2, x2
    isReversed = (x1 > x2)

    if isReversed:
        x1, x2 = x2, x1
        y1, y2 = y2, y1

        deltax = x2 - x1
        deltay = abs(y2-y1)
        error = (deltax >> 1)
        print(f"R deltax={deltax}, deltay={deltay}, error={error}")
        y = y2
        ystep = None
        if y1 < y2:
            ystep = 1
        else:
            ystep = -1
        for x in range(x2, x1 - 1, -1):
            if isSteep:
                plot (y, x)
            else:
                plot (x, y)
            error -= deltay
            if error>=0:
                print(f"RE{deltax:02X} {deltay:02X} {error:02X}")
            else:
                print(f"RE{deltax:02X} {deltay:02X} {0x100+error:02X}")
            if error <= 0:
                y -= ystep
                error += deltax
                print(f"R*{deltax:02X} {deltay:02X} {error:02X}")
    else:
        deltax = x2 - x1
        deltay = abs(y2-y1)
        error = (deltax >> 1)
        print(f"NR deltax={deltax}, deltay={deltay}, error={error}")
        y = y1
        ystep = None
        if y1 < y2:
            ystep = 1
        else:
            ystep = -1
        for x in range(x1, x2 + 1):
            if isSteep:
                print("S", end="")
                plot (y, x)
            else:
                print("N", end="")
                plot (x, y)
            error -= deltay
            if error>=0:
                print(f"E{deltax:02X} {deltay:02X} {error:02X}")
            else:
                print(f"E{deltax:02X} {deltay:02X} {0x100+error:02X}")
            if error < 0:
                y += ystep
                error += deltax
                print(f"*{deltax:02X} {deltay:02X} {error:02X}")

def circle(x, y, radius):
    # Mid-point/Bresenham's Circle algorithm from https://www.daniweb.com/programming/software-development/threads/321181/python-bresenham-circle-arc-algorithm
    # and then modified to remove duplicates.

    switch = 3 - (2 * radius)
    cx = 0
    cy = radius
    while cx <= cy:
        # first quarter first octant
        plot(cx + x,-cy + y)
        # first quarter 2nd octant
        plot(cy + x,-cx + y)
        # second quarter 3rd octant
        plot(cy + x,cx + y)
        # second quarter 4.octant
        plot(cx + x,cy + y)
        print("H")
        # third quarter 5.octant
        plot(-cx + x,cy + y)
        # third quarter 6.octant
        plot(-cy + x,cx + y)
        # fourth quarter 7.octant
        plot(-cy + x,-cx + y)
        # fourth quarter 8.octant
        plot(-cx + x,-cy + y)
        print("E")
        if switch < 0:
            switch = switch + (4 * cx) + 6
        else:
            switch = switch + (4 * (cx - cy)) + 10
            cy = cy - 1
        cx = cx + 1

def circle2(x, y, radius):
    switch = 3 - (2 * radius)
    cx = 0
    cy = radius
    plot(-cy + x,-cx + y)
    while cx <= cy:
        # Duplicates are formed whenever cx or cy is 0, or when cx == cy.
        # I've rearranged the original code to minimize if statements,
        # though it makes the code a bit inscrutable.
        plot(cx + x, -cy + y) # 1st quarter 1st octant
        if cx != cy:
            plot(cy + x, -cx + y) # 1st quarter 2nd octant
        if cx != 0:
            plot(cy + x,  cx + y) # 2nd quarter 3rd octant
            if cy != 0:
                plot(-cx + x,  cy + y) # 3rd quarter 5th octant
                plot(-cy + x, -cx + y) # 4th quarter 7th octant
                if cx != cy:
                    plot(-cy + x,  cx + y) # 3rd quarter 6th octant
                    plot(-cx + x, -cy + y) # 4th quarter 8th octant
        if cy != 0 and cx != cy:
            plot(cx + x,  cy + y) # 2nd quarter 4th octant

        if switch < 0:
            switch += (4 * cx) + 6
        else:
            switch += (4 * (cx - cy)) + 10
            cy -= 1
        cx += 1

# Driver code
if __name__ == '__main__':
    npix = 2
    for x in range(npix+1):
        line(x, 0, x, npix)
    for x in range(npix+1):
        line(x, npix, x, 0)
    for y in range(npix+1):
        line(0, y, npix, y)
    for y in range(npix+1):
        line(npix, y, 0, y)
    # Function call
#    line(x1, y1, x2, y2)
#    circle2(10, 10, 7)

# This code is contributed by ash264
