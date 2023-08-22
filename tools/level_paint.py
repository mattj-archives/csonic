import copy
import json
import random

import xml.etree.ElementTree as ET
import PIL.Image
from PIL import ImageDraw


class LevelPaintTool:

    def __init__(self, map_file_name) -> None:
        super().__init__()

        self.grass_upper = []
        self.grass_lower = []
        self.shadow_lower = []

        terrain_pattern_width = 24 * 4

        for i in range(0, terrain_pattern_width):
            # self.grass_upper.append(-random.randint(0, 2))
            self.grass_upper.append(0)
            self.grass_lower.append(random.randint(4, 8))
            self.shadow_lower.append(self.grass_lower[i] + random.randint(3, 6))

        with open("dev/height.json") as f:
            s = f.read()
            self.heights = json.loads(s)
            # print(self.heights)

        tree = ET.parse(map_file_name)
        root = tree.getroot()

        layer = root.find('.//layer[@name="Tile Layer 1"]')

        # Get the data element containing the tile data
        data = layer.find('data')

        # Split the tile data into a list of integers
        self.tiles = [int(x) for x in data.text.strip().split(',')]
        print(self.tiles)

        self.map_width = 64  # 168
        self.map_height = 24  # 54

        maskImage = PIL.Image.new(mode='1', size=(self.map_width * 24, self.map_height * 24))

        for ty in range(0, self.map_height):
            for tx in range(0, self.map_width):
                tile_num = self.tiles[ty * self.map_width + tx]
                if tile_num == 0:
                    continue

                tile_left = tx * 24
                tile_top = ty * 24

                for py in range(0, 24):
                    for px in range(0, 24):
                        if self.is_masked_pixel(tile_left + px, tile_top + py):
                            maskImage.putpixel((tile_left + px, tile_top + py), 1)

        # maskImage.show()

        map_width_pixels = self.map_width * 24

        mask_data = maskImage.getdata()
        canvas = PIL.Image.new(mode='RGB', size=(self.map_width * 24, self.map_height * 24))

        # Draw the background mask first

        canvas_data = list(canvas.getdata())

        for py in range(0, self.map_height * 24):
            print(py)
            ty = py // 12
            for px in range(0, self.map_width * 24):
                if mask_data[py * map_width_pixels + px] == 1:
                    # draw.point((px, py), (0, 127, 0, 255))
                    tx = px // 12

                    if (tx + ty) % 2 == 0:
                        canvas_data[py * map_width_pixels + px] = (0, 0x7f, 0, 255)
                    else:
                        canvas_data[py * map_width_pixels + px] = (0, 0xaa, 0, 255)

        canvas.putdata(canvas_data)

        draw = ImageDraw.Draw(canvas)
        for ty in range(0, self.map_height):
            for tx in range(0, self.map_width):
                tile_num = self.tiles[ty * self.map_width + tx]
                if tile_num == 0:
                    continue

                tile_left = tx * 24
                tile_bottom = ty * 24 + 24

                tile_heights = self.heights[tile_num - 1]

                for px in range(0, 24):
                    if tile_heights[px] == 0:
                        continue

                    # Only draw the pixel if there is no pixel above it
                    pt_x = tile_left + px
                    pt_y = tile_bottom - tile_heights[px]

                    if mask_data[(pt_y - 1) * map_width_pixels + pt_x] == 0:
                        draw.point((pt_x, pt_y), (255, 255, 255, 255))

                        # Shadow
                        draw.line([(pt_x, pt_y), (pt_x, pt_y + self.shadow_lower[pt_x % terrain_pattern_width])],
                                  fill=(102, 57, 49))

                        pt0 = (pt_x, pt_y + self.grass_upper[pt_x % terrain_pattern_width])
                        pt1 = (pt_x, pt_y + self.grass_lower[pt_x % terrain_pattern_width])
                        # Green (grass)
                        if pt_x % 8 < 4:
                            draw.line([pt0, pt1], fill=(106, 190, 48))
                        else:
                            draw.line([pt0, pt1], fill=(86, 170, 28))

                        # canvas_data[pt_y * map_width_pixels + pt_x] = (255, 255, 255, 255)

        canvas_data = list(canvas.getdata())

        print("Generating tileset / hashes")

        tile_hashes = {}
        tile_count = 0

        tileset_image = PIL.Image.new(mode='RGB', size=(16 * 24, 16 * 24))

        # Generate hashes for each tile
        for ty in range(0, self.map_height):
            for tx in range(0, self.map_width):
                b = bytearray()
                tile_left = tx * 24
                tile_top = ty * 24

                tileset_x = 24 * (tile_count % 16)
                tileset_y = 24 * (tile_count // 16)

                for py in range(0, 24):
                    for px in range(0, 24):
                        pixel = canvas_data[(tile_top + py) * map_width_pixels + (tile_left + px)]
                        b.extend(pixel)

                        tileset_image.putpixel((tileset_x + px, tileset_y + py), pixel)

                h = hash(bytes(b))
                # print(f'hash for {tx}, {ty}: {h}')
                if h not in tile_hashes:
                    # print('add...')
                    tile_hashes[h] = [tile_count, tx, ty]
                    tile_count += 1

        tileset_image.show()
        canvas.show()

    def is_masked_pixel(self, x, y):
        tx = x // 24
        ty = y // 24

        tile_num = self.tiles[ty * self.map_width + tx]

        if tile_num == 0:
            return False

        tile_top = ty * 24
        tile_bottom = ty * 24 + 24
        tile_heights = self.heights[tile_num - 1]

        if tile_heights[x % 24] == 0:
            return False

        return tile_bottom - tile_heights[x % 24] <= tile_top + (y % 24)


def testAddLayer():
    tree = ET.parse("dev/testmap.tmx")
    root = tree.getroot()
    newtree = copy.deepcopy(tree)
    newroot = newtree.getroot()

    layers = newroot.findall("./layer")

    print(layers)

    for c in layers:
        newroot.remove(c)

    print(ET.tostring(newroot))

    layer1 = root.find('.//layer[@name="Tile Layer 1"]')
    layer1.set("id", "1")
    newroot.append(layer1)

    # Get the data element containing the tile data
    # data = layer.find('data')

    layer = ET.Element("layer")

    newroot.append(layer)

    layer.set("name", "_rendered")
    layer.set("id", "2")
    layer.set("width", "64")
    layer.set("height", "32")

    layer_data = ET.Element("data")
    layer_data.set("encoding", "csv")
    layer_data.text = ','.join(['0' for i in range(64*32)])
    layer.append(layer_data)

    root.append(layer)

    newtree.write("dev/test1.tmx", xml_declaration=True, encoding='UTF-8')


if __name__ == "__main__":
    testAddLayer()

    # LevelPaintTool("dev/testmap.tmx")
