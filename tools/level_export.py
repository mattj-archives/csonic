import struct

from tiledlib import TiledMap

if __name__ == "__main__":
    print("Level export. Converts TMX to game data.")

    outfile = open("dev/out_test.l3", "wb")

    tilemap = TiledMap.from_file("dev/test1.tmx")
    print(tilemap)

    # Tile structure, for now:
    # Tile type (byte), 0 = none, 1 = solid
    #   Determined from the "height"/collision layer
    # Heightmap reference ("description") for now
    # Visual tile from the final rendered tiles set

    layer = tilemap.layer_for_name("Tile Layer 1")
    layer_rendered = tilemap.layer_for_name("_rendered")

    print(layer, tilemap.width, tilemap.height)

    outfile.write(bytes([tilemap.width, tilemap.height]))

    for y in range(0, tilemap.height):
        for x in range(0, tilemap.width):
            idx = layer.tiles[y * tilemap.width + x]
            vis_idx = layer_rendered.tiles[y * tilemap.width + x]
            vis = 0
            tile_type = 0
            if idx != 0:
                tile_type = 1
                desc = idx - tilemap.tileset_for_gid(idx).firstgid
                vis = vis_idx - tilemap.tileset_for_gid(vis_idx).firstgid
                print(desc, vis)
            else:
                tile_type = 0
                desc = 0

            outfile.write(bytes([tile_type]))
            outfile.write(struct.pack("<H", desc))
            outfile.write(struct.pack("<H", vis))

    outfile.close()


