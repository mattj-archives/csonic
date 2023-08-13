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
    def __init__(self, name, duration, next_state, sprite_state, func=0) -> None:
        super().__init__()

        self.name = name
        self.duration = int(duration)
        self.next_state = next_state
        self.sprite_state = sprite_state
        self.func = func


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


def state(name, duration, next_state, sprite_state, func=0):
    _state = State(name, duration, next_state, sprite_state, func=func)
    states[name] = _state
    states_arr.append(_state)


if __name__ == "__main__":
    png_to_data()
    print(sprites)

    res_file = open("src/res/CONST.BI", "wt")

    sprite_state("NONE", "", "")
    sprite_state("PLAYER.RUN1", "SL1", "SR1")
    sprite_state("PLAYER.RUN2", "SL2", "SR2")
    sprite_state("PLAYER.STAND", "SLS", "SRS")
    sprite_state("PLAYER.WAIT0", "SWAIT1", "SWAIT1")
    sprite_state("PLAYER.WAIT1", "SWAIT2", "SWAIT2")
    sprite_state("PLAYER.SPIN1", "SPIN1", "SPIN1")
    sprite_state("PLAYER.SPIN2", "SPIN2", "SPIN2")

    for i in range(1, 6):
        sprite_state(f"EXPLODE{i}", f"E{i}", f"E{i}")

    for i in range(1, 7):
        sprite_state(f"CHILI{i}", f"CHILI{i}", f"CHILI{i}")

    sprite_state("MOSQU.NORMAL", "MOSQU1", "MOSQU2")
    sprite_state("MOSQU.ATTACK1", "MOSQU3", "MOSQU3")
    sprite_state("MOSQU.ATTACK2", "MOSQU4", "MOSQU4")

    sprite_state("BPOT1", "P1", "P1")

    sprite_state("BOX.RING", "BOX.RNG", "BOX.RNG")
    sprite_state("BOX.STATIC", "BOX.ST", "BOX.ST")

    for i in range(1, 7):
        sprite_state(f"RING{i}", f"RING{i}", f"RING{i}")

    state("NONE", 60, "NONE", "NONE")

    state("PLAYER.RUN1", 2, "PLAYER.RUN2", "PLAYER.RUN1")
    state("PLAYER.RUN2", 2, "PLAYER.RUN1", "PLAYER.RUN2")
    state("PLAYER.STAND1", 30, "PLAYER.STAND1", "PLAYER.STAND")
    state("PLAYER.WAIT1", 30/5, "PLAYER.WAIT2", "PLAYER.WAIT0")
    state("PLAYER.WAIT2", 30/5, "PLAYER.WAIT1", "PLAYER.WAIT1")
    state("PLAYER.SPIN1", 2, "PLAYER.SPIN2", "PLAYER.SPIN1")
    state("PLAYER.SPIN2", 2, "PLAYER.SPIN1", "PLAYER.SPIN2")
    state("EXPLODE1", 40, "EXPLODE2", "EXPLODE5")
    state("EXPLODE2", 40, "EXPLODE3", "EXPLODE4")
    state("EXPLODE3", 40, "EXPLODE4", "EXPLODE3")
    state("EXPLODE4", 40, "EXPLODE5", "EXPLODE2")
    state("EXPLODE5", 40, "EXPLODE1", "EXPLODE1", 999)

    state("BOX.RING1", 20, "BOX.RING2", "BOX.RING")
    state("BOX.RING2", 4, "BOX.RING1", "BOX.STATIC")

    state("BPOT_IDLE", 1, "BPOT1", "BPOT1", 0)
    state("BPOT1", 10, "BPOT2", "BPOT1", 1)
    state("BPOT2", 10, "BPOT3", "BPOT1", 1)
    state("BPOT3", 10, "BPOT4", "BPOT1", 1)
    state("BPOT4", 10, "BPOT5", "BPOT1", 2)
    state("BPOT5", 10, "BPOT6", "BPOT1", 2)
    state("BPOT6", 10, "BPOT1", "BPOT1", 2)

    state("MOSQU.IDLE", 1, "MOSQU.PATROL", "MOSQU.NORMAL", 0)
    state("MOSQU.PATROL", 10, "MOSQU.PATROL", "MOSQU.NORMAL", 3)
    state("MOSQU.ATTACK1", 10, "MOSQU.ATTACK2", "MOSQU.ATTACK1", 0) # First rotation
    state("MOSQU.ATTACK2", 10, "MOSQU.ATTACK3", "MOSQU.ATTACK2", 0) # Second rotation
    state("MOSQU.ATTACK3", 10, "MOSQU.ATTACK3", "MOSQU.ATTACK2", 4) # Moving down
    state("MOSQU.ATTACK4", 60, "MOSQU.ATTACK4", "MOSQU.ATTACK2") # DONE

    state("RING1", 2, "RING2", "RING1")
    state("RING2", 2, "RING3", "RING2")
    state("RING3", 2, "RING4", "RING3")
    state("RING4", 2, "RING5", "RING4")
    state("RING5", 2, "RING6", "RING5")
    state("RING6", 2, "RING1", "RING6")

    state("CHILI1", 2, "CHILI2", "CHILI1")
    state("CHILI2", 2, "CHILI3", "CHILI2")
    state("CHILI3", 2, "CHILI4", "CHILI3")
    state("CHILI4", 2, "CHILI5", "CHILI4")
    state("CHILI5", 2, "CHILI6", "CHILI5")
    state("CHILI6", 2, "CHILI1", "CHILI6")

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

        sprite_index = 0

        try:
            sprite_index = sprites[f"SPRITE.{ss.left}"][0]
        except:
            pass

        data.extend(struct.pack("<H", sprite_index))

        sprite_index = 0

        try:
            sprite_index = sprites[f"SPRITE.{ss.right}"][0]
        except:
            pass

        data.extend(struct.pack("<H", sprite_index))

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
        data.extend(struct.pack("<H", state.func))

    BSAVE("res.dat", data)

    write_res("TYPE Sprite")
    write_res("\toffs as integer")
    write_res("\tbufNum as integer")
    write_res("End Type")

    write_res("TYPE SpriteState")
    write_res("\tSprites(0 to 1) as integer")
    write_res("End Type")

    write_res("TYPE State")
    write_res("\tduration as integer")
    write_res("\tnextState as integer")
    write_res("\tspriteState as integer")
    write_res("\tfunc as integer")
    write_res("End Type")

    write_res("TYPE TRes")
    write_res(f"\tSprites(0 to {len(sprites)-1}) as Sprite")
    write_res(f"\tSpriteStates(0 to {len(sprite_states)-1}) as SpriteState")
    write_res(f"\tStates(0 to {len(states)-1}) as State")
    write_res("End Type")
    print(f"Sprites: 0 to {len(sprites) - 1}")
    print(f"Sprite States: 0 to {len(sprite_states) - 1}")
    print(f"States: 0 to {len(states) - 1}")

    res_file.close()
