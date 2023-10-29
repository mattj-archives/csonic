import copy
import json
import random
import struct
import subprocess

import xml.etree.ElementTree as ET
from tempfile import TemporaryFile, NamedTemporaryFile
from xml.dom import minidom

import PIL.Image
from PIL import ImageDraw

from heightmap import HeightMapTool
from level_export import LevelExportTool
from tiledlib import Tileset, TiledLayer, TiledMap, TilesetImage, TilesetDef, Property


def write_tiles(tiles):
    # with NamedTemporaryFile() as f:
    with open("tiles.tmp", "wb") as f:
        for t in tiles:
            f.write(struct.pack("<H", t))

    print(f.name)
    return f.name


class LevelPaintTool:

    def generate_mask_image(self):
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

        return maskImage

    def __init__(self, map_file_name, out_map_file_name) -> None:
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

        tilemap = TiledMap.from_file(map_file_name)
        layer = tilemap.layer_for_name("Tile Layer 1")

        img_grass = PIL.Image.open("dev/grass2.png")

        self.tiles = layer.tiles

        tiles_file_name = write_tiles(self.tiles)
        print(f'wrote tiles to {tiles_file_name}')

        self.map_width = tilemap.width
        self.map_height = tilemap.height

        map_width_pixels = self.map_width * 24

        print("Generating mask image")

        if False:
            maskImage = self.generate_mask_image()
        else:

            cmd = f'./tools/mask_gen/mask_gen --size {self.map_width} {self.map_height} --height-file height.dat --tiles-file {tiles_file_name} --canvas-output canvas.tmp'
            print("Running", cmd)
            subprocess.run(cmd, shell=True, capture_output=True)

            with open("./tools/mask_gen/test.raw", "rb") as f:
                rawData = f.read()
                # maskImage = PIL.Image.frombuffer('1', (self.map_width * 24, self.map_height * 24), rawData, 'raw', '1', 0, 1) #1 bpp
                maskImage = PIL.Image.frombuffer('L', (self.map_width * 24, self.map_height * 24), rawData)
                # maskImage.show()

            # return

        mask_data = maskImage.getdata()
        print("BG fill")
        if False:
            canvas = PIL.Image.new(mode='RGBA', size=(self.map_width * 24, self.map_height * 24))
        else:
            with open("canvas.tmp", "rb") as f:
                rawData = f.read()
                canvas = PIL.Image.frombuffer('RGBA', (self.map_width * 24, self.map_height * 24), rawData)
                # canvas.show()

        # Draw the background mask first


        canvas_data = list(canvas.getdata())

        if False:
            for py in range(0, self.map_height * 24):
                # print(py)
                ty = py // 24
                for px in range(0, self.map_width * 24):
                    if mask_data[py * map_width_pixels + px] != 0:
                        # draw.point((px, py), (0, 127, 0, 255))
                        tx = px // 24

                        canvas_data[py * map_width_pixels + px] = (0, 0xaa, 0, 255)
                        # if (tx + ty) % 2 == 0:
                        #     canvas_data[py * map_width_pixels + px] = (0, 0x7f, 0, 255)
                        # else:
                        #     canvas_data[py * map_width_pixels + px] = (0, 0xaa, 0, 255)

            canvas.putdata(canvas_data)

        # return
        print("BG overlay")
        draw = ImageDraw.Draw(canvas)
        for ty in range(0, self.map_height):
            for tx in range(0, self.map_width):
                tile_num = self.tiles[ty * self.map_width + tx]
                if tile_num == 0:
                    continue

                tile_top = ty * 24
                tile_left = tx * 24
                tile_bottom = ty * 24 + 24

                tile_heights = self.heights[tile_num - 1]

                for px in range(0, 24):
                    if tile_heights[px] == 0:
                        continue

                    pt_x = tile_left + px

                    if tile_num < 576:
                        # Only draw the pixel if there is no pixel above it
                        pt_y = tile_bottom - tile_heights[px]

                        if mask_data[(pt_y - 1) * map_width_pixels + pt_x] == 0:

                            if False:
                                draw.point((pt_x, pt_y), (255, 255, 255, 255))

                                # Shadow
                                draw.line(
                                    [(pt_x, pt_y), (pt_x, pt_y + self.shadow_lower[pt_x % terrain_pattern_width])],
                                    fill=(102, 57, 49))

                                pt0 = (pt_x, pt_y + self.grass_upper[pt_x % terrain_pattern_width])
                                pt1 = (pt_x, pt_y + self.grass_lower[pt_x % terrain_pattern_width])
                                # Green (grass)
                                if pt_x % 8 < 4:
                                    draw.line([pt0, pt1], fill=(106, 190, 48))
                                else:
                                    draw.line([pt0, pt1], fill=(86, 170, 28))
                            else:

                                for py in range(0, img_grass.size[1]):

                                    pix = img_grass.getpixel((pt_x % img_grass.size[0], py))
                                    if pix[3] != 0:
                                        draw.point((pt_x, pt_y + py), pix)



                    else:
                        pt_y = tile_top + tile_heights[px] - 1

                        for y2 in range(pt_y, pt_y - 3, -1):
                            c = canvas.getpixel((pt_x, y2))
                            c = (c[0] - 30, c[1] - 30, c[2] - 30, 255)
                            draw.point((pt_x, y2), c)

                            # canvas_data[pt_y * map_width_pixels + pt_x] = (255, 255, 255, 255)

        canvas_data = list(canvas.getdata())

        print("Generating tileset / hashes")

        tile_hashes = {}
        tile_count = 0

        tileset_image = PIL.Image.new(mode='RGBA', size=(16 * 24, 16 * 24))

        new_tile_indices = [0 for _ in range(self.map_width * self.map_height)]

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
                    idx = tile_count
                    tile_count += 1
                else:
                    idx = tile_hashes[h][0]

                new_tile_indices[ty * self.map_width + tx] = idx

        print(new_tile_indices)

        tileset_image.save("dev/TEST_rendered.png")

        tileset = Tileset(name="TEST_rendered",
                          tilewidth=24,
                          tileheight=24,
                          tilecount=16 * 16,
                          columns=16,
                          backgroundcolor="#00000000")

        tileset.properties.append(Property(name="tileset_type", _type="string", value="_rendered"))

        tileset.image = TilesetImage(source="TEST_rendered.png", trans="00ffff", width=16 * 24, height=16 * 24)
        next_firstgid = tilemap.get_next_firstgid()

        tileset_def = get_map_tilesetdef_with_property(tilemap, "tileset_type", "_rendered")

        if tileset_def:
            tilemap.tilesets.remove(tileset_def)

        tileset_def = TilesetDef(firstgid=next_firstgid, source=None, tileset=tileset)
        tilemap.tilesets.append(tileset_def)

        bg_layer = tilemap.layer_for_name("_rendered")
        if bg_layer:
            tilemap.layers.remove(bg_layer)

        bg_layer = TiledLayer(100, "_rendered", tilemap.width, tilemap.height, locked=1, visible=1)

        bg_layer.tiles = [tileset_def.firstgid + x for x in new_tile_indices]

        tilemap.layers.append(bg_layer)

        tilemap.clean_firstgids()
        tilemap.write_to_file(out_map_file_name)

        # tileset_image.show()
        # canvas.show()

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

        if tile_num < 576:
            return tile_bottom - tile_heights[x % 24] <= tile_top + (y % 24)
        else:
            return tile_top + tile_heights[x % 24] > tile_top + (y % 24)


def get_map_tilesetdef_with_property(map: TiledMap, name, value):
    ts: TilesetDef

    for ts in map.tilesets:
        for prop in ts.tileset.properties:
            if prop.name == name and prop.value == value:
                return ts

    return None


def testAddLayer():
    # Tileset.from_file("dev/Height.tsx")

    # map = TiledMap.from_file("dev/testmap.tmx")
    map = TiledMap.from_file("dev/test1.tmx")
    tsd = get_map_tilesetdef_with_property(map, "tileset_type", "_rendered")
    print(tsd)
    # map.tilesets[0].newfirstgid = 300
    # map.tilesets[1].newfirstgid = 500
    # map.apply_new_firstgids()
    # with open("dev/test1.tmx", "wt") as f:
    #     _bytes = ET.tostring(map.to_xml(), xml_declaration=True, encoding='UTF-8')
    #
    #     xmlstr = minidom.parseString(_bytes).toprettyxml(indent="   ")
    #
    #     f.write(xmlstr)
    print(ET.tostring(map.to_xml(), xml_declaration=True, encoding='UTF-8'))
    map.write_to_file("dev/test1b.tmx")
    return

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

    l = TiledLayer.from_element(layer1)

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
    layer_data.text = ','.join(['0' for i in range(64 * 32)])
    layer.append(layer_data)

    root.append(layer)

    newtree.write("dev/test1.tmx", xml_declaration=True, encoding='UTF-8')


if __name__ == "__main__":
    # testAddLayer()

    HeightMapTool().run()

    LevelPaintTool("dev/testmap.tmx", "dev/testmap1.tmx")
    LevelExportTool("dev/testmap1.tmx", "dev/out_testmap1.l3").run()

    # LevelPaintTool("dev/test1.tmx", "dev/test1.tmx")
