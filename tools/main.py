import gc
import os
import struct
from os.path import join

from common import SpriteState, State
from heightmap import HeightMapTool


class GFXFile:

    def __init__(self, file_name, gfx_name, num) -> None:
        super().__init__()
        self.file_name = file_name
        self.gfx_name = gfx_name
        self.num = num


def write_pas_str(b: bytearray, val: str):
    b.append(len(val))
    b.extend(val.encode('latin-1'))


class Tool(object):

    def __init__(self) -> None:
        super().__init__()

        self.gfx_files: [GFXFile] = []

        self.cur_sprite = 1

        self.sprites = {}
        self.sprites_arr = []
        self.sprite_states = {}
        self.sprite_states_arr: [SpriteState] = []
        self.states = {}
        self.states_arr: [State] = []

    def __enter__(self):

        self.collect_gfx_files("gfx3")

        self.constFile = open("src/res/res.pas", "wt")
        self.enumFile = open("src/res/res_enum.pas", "wt")

        self.write_res('unit res;')

        self.write_res('interface')
        self.write_res('uses common, res_enum;')

        self.write_enum('unit res_enum;')
        self.write_enum('interface')
        return self

    def __exit__(self, exception_type, exception_value, traceback):

        def _write_enum(arr, name, write_func):
            self.write_enum('type')
            self.write_enum(f'\t{name} = (')

            for elem in arr:
                is_last = arr.index(elem) == len(arr) - 1
                comma = [',', ''][is_last]
                self.write_enum(f'\t\t{write_func(elem)}{comma}')

            self.write_enum('\t);')

        def sprite_state_write_func(elem):
            return f'SPRITE_STATE_{elem.name}'

        def entity_state_write_func(elem):
            return f'STATE_{elem.name}'

        _write_enum(self.sprite_states_arr, 'spriteStates', write_func=sprite_state_write_func)
        _write_enum(self.states_arr, 'entityStates', write_func=entity_state_write_func)

        self.write_res('const')

        with open("gfxlist.dat", "wb") as f:
            data = bytearray()
            data.extend(struct.pack("<H", len(self.gfx_files)))
            g: GFXFile
            for g in self.gfx_files:
                write_pas_str(data, g.gfx_name)
                self.write_res(f'\tSPRITE_{g.gfx_name.replace("-", "_")} = {g.num};')

            f.write(data)

        # self.write_res('type')

        self.write_res('const')
        self.write_res(f'sprite_states: array[0..{len(self.sprite_states) - 1}] of TSpriteState = (')
        sprite_state: SpriteState
        for sprite_state in self.sprite_states_arr:
            is_last = self.sprite_states_arr.index(sprite_state) == len(self.sprite_states_arr) - 1

            left_name = f"SPRITE_{sprite_state.left}"
            right_name = f"SPRITE_{sprite_state.right}"
            if not sprite_state.left:
                left_name = "0"

            if not sprite_state.right:
                right_name = "0"

            self.write_res(f"\t(sprites: ({left_name}, {right_name})){[',', ''][is_last]}")
        self.write_res(');')

        self.write_res(f'entity_states: array[0..{len(self.states) - 1}] of TEntityState = (')
        entity_state: State
        for entity_state in self.states_arr:
            is_last = self.states_arr.index(entity_state) == len(self.states_arr) - 1

            self.write_res(f'\t{{ STATE_{entity_state.name} }}')
            self.write_res(
                f"\t(duration: {entity_state.duration}; nextState: STATE_{entity_state.next_state}; spriteState: SPRITE_STATE_{entity_state.sprite_state}; func: {entity_state.func}){[',', ''][is_last]}")
        self.write_res(');')

        self.write_res('implementation')
        self.write_res('begin')
        self.write_res('end.')
        self.constFile.close()

        self.write_enum('implementation')
        self.write_enum('begin')
        self.write_enum('end.')
        self.enumFile.close()

    def collect_gfx_files(self, path):
        num = 1
        for f in sorted(os.listdir(path)):
            infile = join(path, f)

            # outfile = join("GFX3", os.path.splitext(f)[0]) + ".png"
            frame_name = os.path.splitext(os.path.basename(infile))[0]

            print(infile, frame_name)
            self.gfx_files.append(GFXFile(infile, frame_name, num))

            num += 1

    def write_res(self, s):
        print(s)
        self.constFile.write(f'{s}\n')

    def write_enum(self, s):
        print(s)
        self.enumFile.write(f'{s}\n')

    def sprite_state(self, name, left, right):
        name = name.replace(".", "_")
        left = left.replace(".", "_")
        right = right.replace(".", "_")

        _sprite_state = SpriteState(name, left, right)
        self.sprite_states[name] = _sprite_state
        self.sprite_states_arr.append(_sprite_state)

    def state(self, name, duration, next_state, sprite_state, func=0):
        name = name.replace(".", "_")
        next_state = next_state.replace(".", "_")
        sprite_state = sprite_state.replace(".", "_")
        _state = State(name, duration, next_state, sprite_state, func=func)
        self.states[name] = _state
        self.states_arr.append(_state)


if __name__ == "__main__":
    print("main")
    heightmap_tool = HeightMapTool()
    heightmap_tool.run()

    with Tool() as tool:

        def sprite_state(name, left, right):
            tool.sprite_state(name, left, right)


        def state(name, duration, next_state, sprite_state, func=0):
            tool.state(name, duration, next_state, sprite_state, func)


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

        sprite_state("RM.WAIT", "RM1", "RM1")
        sprite_state("RM.WALK", "RM3", "RM2")

        sprite_state("BPOT1", "P1", "P1")

        sprite_state("BOX.RING", "BOX.RNG", "BOX.RNG")
        sprite_state("BOX.STATIC", "BOX.ST", "BOX.ST")

        sprite_state("SPRING.YELLOW1", "SPRINGL1", "SPRINGL1")
        sprite_state("SPRING.YELLOW2", "SPRINGL2", "SPRINGL2")

        sprite_state("SPRING.RED1", "SPRINGR1", "SPRINGR1")
        sprite_state("SPRING.RED2", "SPRINGR2", "SPRINGR2")

        sprite_state("MPLAT", "MPLAT", "MPLAT")

        for i in range(1, 7):
            sprite_state(f"RING{i}", f"RING{i}", f"RING{i}")

        state("NONE", 60, "NONE", "NONE")

        state("PLAYER.RUN1", 2, "PLAYER.RUN2", "PLAYER.RUN1")
        state("PLAYER.RUN2", 2, "PLAYER.RUN1", "PLAYER.RUN2")
        state("PLAYER.STAND1", 30, "PLAYER.STAND1", "PLAYER.STAND")
        state("PLAYER.WAIT1", 30 / 5, "PLAYER.WAIT2", "PLAYER.WAIT0")
        state("PLAYER.WAIT2", 30 / 5, "PLAYER.WAIT1", "PLAYER.WAIT1")
        state("PLAYER.SPIN1", 2, "PLAYER.SPIN2", "PLAYER.SPIN1")
        state("PLAYER.SPIN2", 2, "PLAYER.SPIN1", "PLAYER.SPIN2")
        state("EXPLODE1", 4, "EXPLODE2", "EXPLODE5")
        state("EXPLODE2", 4, "EXPLODE3", "EXPLODE4")
        state("EXPLODE3", 4, "EXPLODE4", "EXPLODE3")
        state("EXPLODE4", 4, "EXPLODE5", "EXPLODE2")
        state("EXPLODE5", 4, "EXPLODE1", "EXPLODE1", 999)

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
        state("MOSQU.ATTACK1", 10, "MOSQU.ATTACK2", "MOSQU.ATTACK1", 0)  # First rotation
        state("MOSQU.ATTACK2", 10, "MOSQU.ATTACK3", "MOSQU.ATTACK2", 0)  # Second rotation
        state("MOSQU.ATTACK3", 10, "MOSQU.ATTACK3", "MOSQU.ATTACK2", 4)  # Moving down
        state("MOSQU.ATTACK4", 60, "MOSQU.ATTACK4", "MOSQU.ATTACK2")  # DONE

        state("RM.IDLE", 1, "RM.WAIT", "RM.WAIT")
        state("RM.WAIT", 10, "RM.WAIT", "RM.WAIT", 5)
        state("RM.WALK", 10, "RM.WALK", "RM.WALK", 5)

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

        state("SPRING1.IDLE", 30, "SPRING1.IDLE", "SPRING.YELLOW1")
        state("SPRING1.USE", 10, "SPRING1.IDLE", "SPRING.YELLOW2")

        state("SPRING2.IDLE", 30, "SPRING2.IDLE", "SPRING.RED1")
        state("SPRING2.USE", 10, "SPRING2.IDLE", "SPRING.RED2")

        state("MPLAT", 30, "MPLAT", "MPLAT")
