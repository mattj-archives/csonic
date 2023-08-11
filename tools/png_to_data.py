import os
import struct
from os import listdir, walk
from os.path import isfile, join

import PIL.Image

hi = 0xff
pal = [
    (0, 0, 0),
    (0, 0, 0xAA),
    (0, 0xAA, 0),
    (0, 0xAA, 0xAA),
    (0xAA, 0, 0),
    (0xAA, 0, 0xAA),
    (0xAA, 0x55, 0),
    (0xAA, 0xAA, 0xAA),
    (100, 100, 100),

    (0x55, 0x55, hi),
    (0x55, hi, 0x55),
    (0x55, hi, hi),
    (hi, 0x55, 0x55),
    (hi, 0x55, hi),
    (hi, hi, 0x55),
    (hi, hi, hi),
]

data0 = open("datatest.dat", "wb")
res_file = open("src/res/CONST.BI", "wt")

data = bytearray()

path = "GFX3"
for f in sorted(listdir(path)):
    fn = join(path, f)

    infile = join(path, f)

    # outfile = join("GFX3", os.path.splitext(f)[0]) + ".png"
    print(infile)
    frame_name = os.path.splitext(os.path.basename(infile))[0]
    # print(os.path.splitext(infile))

    img = PIL.Image.open(infile)
    print("Frame name", frame_name, img.size, "BASIC array offset: ", len(data) >> 1)

    basic_frame_name = f'FRAME_{frame_name}'.replace('_', '.').replace('-', '.')

    print(f"CONST {basic_frame_name} = {len(data) >> 1}\r")
    res_file.write(f"CONST {basic_frame_name} = {len(data) >> 1}\n")
    img_data = img.getdata()

    print("Length before data:", len(data), "num pixels:", len(img_data))
    data.extend(struct.pack("<H", img.size[0] * 8))
    data.extend(struct.pack("<H", img.size[1]))

    for d in img_data:
        color = pal.index(d)
        # data0.write(bytes([color]))
        data.append(color)
        # print(d, pal.index(d))

    # print(data)
    print("Current length", len(data), len(data) & 1)

    # Pad

    if len(data) & 1 != 0:
        data.append(0)
        # print("--- added padding ---")

    # print(len(data))
    # exit(0)

    # with open(infile) as f:
# https://rpg.hamsterrepublic.com/ohrrpgce/BSAVE_Header

data0.write(bytes([0xfd]))
data0.write(bytes([0, 0]))  # segment
data0.write(bytes([0, 0]))  # offset
data0.write(bytes(struct.pack("<H", len(data))))
print("Final length (shorts): ", len(data)>>1)
data0.write(data)
data0.close()
res_file.close()
