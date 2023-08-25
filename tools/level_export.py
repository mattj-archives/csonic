import struct

from tiledlib import TiledMap, TiledObjectGroup, TiledObject


class LevelExportTool:
    def __init__(self, infile_path, outfile_path):
        self.infile_path = infile_path
        self.outfile_path = outfile_path

    def run(self):
        print("--- LevelExportTool ---")
        tilemap = TiledMap.from_file(self.infile_path)

        # Tile structure, for now:
        # Tile type (byte), 0 = none, 1 = solid
        #   Determined from the "height"/collision layer
        # Heightmap reference ("description") for now
        # Visual tile from the final rendered tiles set

        layer = tilemap.layer_for_name("Tile Layer 1")
        if not layer:
            raise Exception("Tile Layer 1 not found")

        layer_rendered = tilemap.layer_for_name("_rendered")
        if not layer_rendered:
            raise Exception("_rendered layer not found")

        print(layer, tilemap.width, tilemap.height)

        outfile = open(self.outfile_path, "wb")
        outfile.write(bytes([tilemap.width, tilemap.height]))

        for y in range(0, tilemap.height):
            for x in range(0, tilemap.width):
                idx = layer.tiles[y * tilemap.width + x]
                vis_idx = layer_rendered.tiles[y * tilemap.width + x]
                vis = 0

                if idx != 0:
                    tile_type = 1
                    desc = idx - tilemap.tileset_for_gid(idx).firstgid
                    vis = vis_idx - tilemap.tileset_for_gid(vis_idx).firstgid
                    # print(desc, vis)
                else:
                    tile_type = 0
                    desc = 0

                outfile.write(bytes([tile_type]))
                outfile.write(struct.pack("<H", desc))
                outfile.write(struct.pack("<H", vis))

        og: TiledObjectGroup
        ob: TiledObject

        num_objects = 0
        buf = bytearray()
        if len(tilemap.object_groups) != 0:
            for og in tilemap.object_groups:
                for ob in og.objects:
                    # print(ob)

                    ts = tilemap.tileset_for_gid(ob.gid)
                    buf.extend(struct.pack("<H", ob.gid - ts.firstgid))
                    buf.extend(struct.pack("<H", int(ob.x)))
                    buf.extend(struct.pack("<H", int(ob.y)))
                    # print(ob.gid - ts.firstgid, int(ob.x), int(ob.y))

                    num_objects += 1

            # print(num_objects)

        outfile.write(struct.pack("<H", num_objects))

        if num_objects > 0:
            outfile.write(buf)

        outfile.close()


if __name__ == "__main__":
    LevelExportTool("dev/test1.tmx", "dev/out_test.l3").run()
    print("Level export. Converts TMX to game data.")
