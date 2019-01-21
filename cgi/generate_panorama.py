#!/usr/bin/env python3

import io
import os
import sys
import cgi
from PIL import Image, ImageFilter, ImageDraw
from datetime import datetime
from dateutil import tz

CELL = 8
WRITE_TO_STDOUT = False

im = Image.new("RGB", (CELL*8, CELL*8), (0,0,0))
dr = ImageDraw.Draw(im)

def drawCell(x, y, v):
    x0 = x*CELL
    y0 = y*CELL
    x1 = (x+1)*CELL
    y1 = (y+1)*CELL
    r = 255 if ((v&(1<<0)) != 0) else 0
    g = 255 if ((v&(1<<1)) != 0) else 0
    b = 255 if ((v&(1<<2)) != 0) else 0
    dr.rectangle([x0, y0, x1, y1], fill=(r, g, b))

params = cgi.FieldStorage()
if "timezone" in params:
    offset = tz.tzoffset("IST", 3600*int(params["timezone"].value))

else:
    offset = None

now = datetime.now(tz=offset)
year   = now.year-1900
month  = now.month-1
day    = now.day
hour   = now.hour
minute = now.minute
second = now.second
ms     = int(now.microsecond/1000*64/1000)
weekday = now.isoweekday()%7
moonAge = (((now.year-2009)%19)*11+(now.month+1)+(now.day+1)) % 30

drawCell(0, 0, hour&0b111)
drawCell(1, 0, hour>>3)
drawCell(2, 0, minute&0b111)
drawCell(3, 0, minute>>3)
drawCell(4, 0, second&0b111)
drawCell(5, 0, second>>3)
drawCell(6, 0, ms&0b111)
drawCell(7, 0, ms>>3)

drawCell(0, 1, year&0b111)
drawCell(1, 1, (year>>3)&0b111)
drawCell(2, 1, (year>>6)&0b111)
drawCell(3, 1, month&0b111)
drawCell(4, 1, month>>3)
drawCell(5, 1, day&0b111)
drawCell(6, 1, day>>3)
drawCell(7, 1, weekday)

drawCell(0, 2, moonAge&0b111)
drawCell(1, 2, moonAge>>3)

i = io.BytesIO()
im.save(i, "PNG")
b = i.getvalue()

if not WRITE_TO_STDOUT:
    sys.stdout.write("Content-Type: image/png\n")
    sys.stdout.write("Content-Length: {}\n".format(len(b)))
    sys.stdout.write("\n")
    sys.stdout.flush()

sys.stdout.buffer.write(b)
