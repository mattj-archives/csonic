import os
from posixpath import basename

import PIL
from PIL.Image import Image

# Original GFX files: BSAVE'd 25x25 (?) SCREEN 7 graphics
# ".2" files: Raw 25x25 8bpp image

# Step 1: Use CONVERT.BAS to convert the old .GFX files to ".2" files in the GFX2 directory
# Step 2: Use this script to convert the ".2" files to PNG files in the GFX3 directory
# TODO: Maybe support transparency?

hi = 0xff
pal = [
    [0, 0, 0],
    [0, 0, 0xAA],
    [0, 0xAA, 0],
    [0, 0xAA, 0xAA],
    [0xAA, 0, 0],
    [0xAA, 0, 0xAA],
    [0xAA, 0x55, 0],
    [0xAA, 0xAA, 0xAA],
    [100, 100, 100],

    [0x55, 0x55, hi],
    [0x55, hi, 0x55],
    [0x55, hi, hi],
    [hi, 0x55, 0x55],
    [hi, 0x55, hi],
    [hi, hi, 0x55],
    [hi, hi, hi],
]

from os import listdir, walk
from os.path import isfile, join
path = "GFX2"
for f in listdir(path):
    fn = join(path, f)

    infile = join(path, f)

    outfile = join("GFX3", os.path.splitext(f)[0]) + ".png"
    print(infile, outfile)

    with open(infile) as f:
        img = PIL.Image.new(mode='RGB', size=(25, 25))

        for y in range(0, 25):
            for x in range(0, 25):
                byte = f.read(1)

                b = ord(byte)

                if b != 0:
                    p = pal[b]
                    img.putpixel((x, y), (p[0], p[1], p[2]))

        img.save(outfile)
