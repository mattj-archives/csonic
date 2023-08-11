import re
import struct

with open("levels/1_1.l2", "wb") as outfile:
    with open("levels/1_1.lev", "rt") as f:
        for line in f:
            line = [int(x) for x in re.sub(" +", " ", line.strip()).split(" ")]

            print(line)
            for v in line:
                outfile.write(struct.pack("<h", v))


