import os
import struct
from os import listdir, walk
from os.path import isfile, join

import PIL.Image


class SpriteState:

    def __init__(self, name, left, right) -> None:
        super().__init__()
        self.name = name
        self.left = left
        self.right = right


class State:
    def __init__(self, name, duration, next_state, sprite_state) -> None:
        super().__init__()

        self.name = name
        self.duration = duration
        self.next_state = next_state
        self.sprite_state = sprite_state


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

cur_sprite = 0

sprites = {}
sprites_arr = []
sprite_states = {}
sprite_states_arr: [SpriteState] = []
states = {}
states_arr: [State] = []

def BSAVE(file_name: str, _bytes: bytearray):
    with open(file_name, "wb") as f:
        f.write(bytes([0xfd]))  # magic
        f.write(bytes([0, 0]))  # segment
        f.write(bytes([0, 0]))  # offset
        f.write(bytes(struct.pack("<H", len(_bytes)))) # length
        f.write(_bytes)

def png_to_data():
    global cur_sprite
    # data0 = open("datatest.dat", "wb")


    data = bytearray()

    path = "GFX3"
    for f in sorted(listdir(path)):
        infile = join(path, f)

        # outfile = join("GFX3", os.path.splitext(f)[0]) + ".png"
        print(infile)
        frame_name = os.path.splitext(os.path.basename(infile))[0]
        # print(os.path.splitext(infile))

        img = PIL.Image.open(infile)
        print("Frame name", frame_name, img.size, "BASIC array offset: ", len(data) >> 1)

        basic_frame_name = f'SPRITE_{frame_name}'.replace('_', '.').replace('-', '.')

        # print(f"CONST {basic_frame_name} = {len(data) >> 1}\r")
        # res_file.write(f"CONST {basic_frame_name} = {len(data) >> 1}\n")
        img_data = img.getdata()

        sprites[basic_frame_name] = (cur_sprite, len(data) >> 1)
        sprites_arr.append((basic_frame_name, cur_sprite, len(data) >> 1))

        cur_sprite += 1

        # print("Length before data:", len(data), "num pixels:", len(img_data))
        data.extend(struct.pack("<H", img.size[0] * 8))
        data.extend(struct.pack("<H", img.size[1]))

        for d in img_data:
            color = pal.index(d)
            # data0.write(bytes([color]))
            data.append(color)
            # print(d, pal.index(d))

        # print(data)
        # print("Current length", len(data), len(data) & 1)

        # Pad

        if len(data) & 1 != 0:
            data.append(0)
            # print("--- added padding ---")

        # print(len(data))
        # exit(0)

        # with open(infile) as f:
    # https://rpg.hamsterrepublic.com/ohrrpgce/BSAVE_Header

    BSAVE("datatest.dat", data)

    # data0.write(bytes([0xfd]))
    # data0.write(bytes([0, 0]))  # segment
    # data0.write(bytes([0, 0]))  # offset
    # data0.write(bytes(struct.pack("<H", len(data))))
    # print("Final length (shorts): ", len(data) >> 1)
    # data0.write(data)
    # data0.close()
    # res_file.close()



def sprite_state(name, left, right):
    _sprite_state = SpriteState(name, left, right)
    sprite_states[name] = _sprite_state
    sprite_states_arr.append(_sprite_state)


def state(name, duration, next_state, sprite_state):
    _state = State(name, duration, next_state, sprite_state)
    states[name] = _state
    states_arr.append(_state)


if __name__ == "__main__":
    png_to_data()
    print(sprites)

    res_file = open("src/res/CONST.BI", "wt")

    sprite_state("PLAYER.STAND", "SLS", "SRS")
    sprite_state("PLAYER.WAIT0", "SWAIT1", "SWAIT1")
    sprite_state("PLAYER.WAIT1", "SWAIT2", "SWAIT2")

    state("PLAYER.WAIT1", 30, "PLAYER.WAIT2", "PLAYER.WAIT0")
    state("PLAYER.WAIT2", 30, "PLAYER.WAIT1", "PLAYER.WAIT1")

    data = bytearray()

    def write_res(s: str):
        print(s)
        res_file.write(f"{s}\n")

    for sprite in sprites_arr:
        print("Sprite...", sprite)
        # offset
        data.extend(struct.pack("<H", sprite[2]))
        # buffer number (always 0 for now)
        data.extend(struct.pack("<H", 0))

        write_res(f"CONST {sprite[0]} = {sprite[1]}")

    ss: SpriteState
    for ss in sprite_states_arr:
        idx = sprite_states_arr.index(ss)
        write_res(f"CONST SPRITESTATE.{ss.name} = {idx}")
        # print(sprites[f"SPRITE.{ss.left}"], sprites[f"SPRITE.{ss.right}"])
        data.extend(struct.pack("<H", sprites[f"SPRITE.{ss.left}"][0]))
        data.extend(struct.pack("<H", sprites[f"SPRITE.{ss.right}"][0]))

    state: State
    print(states)
    print(states_arr)
    for state in states_arr:
        idx = states_arr.index(state)
        next_state_index = states_arr.index(states[state.next_state])

        # sprite_state_idx = sprite_states_arr.index(f"SPRITESTATE.{state.sprite_state}")
        _sprite_state = sprite_states[state.sprite_state]
        sprite_state_idx = sprite_states_arr.index(_sprite_state)

        write_res(f"CONST STATE.{state.name} = {idx}")
        print(f"{state.duration}, {next_state_index}, {sprite_state_idx}")

        data.extend(struct.pack("<H", state.duration))
        data.extend(struct.pack("<H", next_state_index))
        data.extend(struct.pack("<H", sprite_state_idx))

    BSAVE("res.dat", data)

    print(f"Sprites: 0 to {len(sprites) - 1}")
    print(f"Sprite States: 0 to {len(sprite_states) - 1}")
    print(f"States: 0 to {len(states) - 1}")

    res_file.close()
