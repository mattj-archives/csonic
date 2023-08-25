import json

import PIL.Image


class HeightMapTool:

    def __init__(self) -> None:
        super().__init__()

    def get_floor_heights(self, img, tx, ty) -> []:
        heights = [0 for _ in range(0, 24)]
        for x in range(0, 24):
            for y in range(ty * 24, ty * 24 + 24):
                if img[y * img.size[0] + (tx * 24 + x)][3] == 255:
                    h = 24 - (y - ty * 24)
                    heights[x] = h
                    break

        return heights

    def get_ceiling_heights(self, img, tx, ty) -> []:
        heights = [0 for _ in range(0, 24)]
        for x in range(0, 24):
            tile_top = ty * 24
            tile_bottom = ty * 24 + 23
            for y in range(tile_bottom, ty * 24 - 1, -1):
                if img[y * img.size[0] + (tx * 24 + x)][3] == 255:
                    h = (y - tile_top) + 1
                    print(f'tile {tx}, {ty}: ceiling height at x: {tx * 24 + x} y:{y}, tile bottom: {tile_bottom}', h)
                    heights[x] = h
                    break

        return heights

    def run(self):
        img = PIL.Image.open("dev/height.png")
        data = img.getdata()
        print(data.size)
        heights = []

        for ty in range(0, 24):
            for tx in range(0, 24):
                heights.append(self.get_floor_heights(data, tx, ty))

        for ty in range(24, 24 * 2):
            for tx in range(0, 24):
                heights.append(self.get_ceiling_heights(data, tx, ty))

        print("heights:", heights)

        with open("dev/height.json", "wt") as heightsjson:
            heightsjson.write(json.dumps(heights))

        with open("height.dat", "wb") as f:
            for h in heights:
                f.write(bytes(h))


