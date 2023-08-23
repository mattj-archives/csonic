import os
import xml.etree.ElementTree as ET


class TilesetImage:
    def __init__(self, source, trans, width, height):
        self.source = source
        self.trans = trans
        self.width = width
        self.height = height


class Tileset:

    def __init__(self, name, tilewidth, tileheight, tilecount, columns, backgroundcolor) -> None:
        super().__init__()
        self.name = name
        self.tilewidth = tilewidth
        self.tileheight = tileheight
        self.tilecount = tilecount
        self.columns = columns
        self.backgroundcolor = backgroundcolor

        self.image = None

    def load_from_element(self, root: ET.Element):
        for c in root:
            if c.tag == 'image':
                source = c.get("source")
                trans = c.get("trans")
                width = int(c.get("width"))
                height = int(c.get("height"))

                self.image = TilesetImage(source, trans, width, height)

    @staticmethod
    def from_file(path):
        tree = ET.parse(path)
        root = tree.getroot()
        return Tileset.from_element(root)

    @staticmethod
    def from_element(elem: ET.Element):
        tileset = Tileset(
            elem.get("name"),
            int(elem.get("tilewidth")),
            int(elem.get("tileheight")),
            int(elem.get("tilecount")),
            int(elem.get("columns")),
            elem.get("backgroundcolor"))

        tileset.load_from_element(elem)

        return tileset


class TiledLayer:

    def __init__(self, id, name, width, height) -> None:
        super().__init__()
        self.id = id
        self.name = name
        self.width = width
        self.height = height
        self.tiles = []

    @staticmethod
    def from_element(elem: ET.Element):
        layer = TiledLayer(
            elem.get("id"),
            elem.get("name"),
            int(elem.get("width")),
            int(elem.get("height"))
        )
        layer.load_from_element(elem)
        return layer

    def load_csv_data(self, elem: ET.Element):
        self.tiles = []

        for line in elem.text.split("\n"):
            for v in line.split(","):
                if len(v) > 0:
                    self.tiles.append(int(v))
        print(len(self.tiles), self.tiles)

    def load_from_element(self, elem: ET.Element):
        # Load "data"
        for c in elem:
            if c.tag == "data":
                # TODO: If csv...
                self.load_csv_data(c)
                continue

            print("Unknown tag found in layer")

    def __repr__(self) -> str:
        return f"<TiledLayer id={self.id}, name=\"{self.name}\">"

    def to_xml(self):
        elem = ET.Element("layer")
        elem.set("id", self.id)
        elem.set("name", self.name)
        elem.set("width", str(self.width))
        elem.set("height", str(self.height))

        elem_data = ET.Element("data")
        elem_data.set("encoding", "csv")
        elem_data.text = ','.join([str(x) for x in self.tiles])
        elem.append(elem_data)
        return elem


class TilesetDef:
    def __init__(self, firstgid, source, directory="./"):
        self.firstgid = int(firstgid)
        self.source = source

        self.newfirstgid = self.firstgid

        self.tileset: Tileset = Tileset.from_file(f'{directory}/{self.source}')

    @staticmethod
    def from_element(elem: ET.Element, directory="."):
        return TilesetDef(
            elem.get("firstgid"),
            elem.get("source"),
            directory
        )

    def to_xml(self):
        elem = ET.Element("tileset")
        elem.set("firstgid", str(self.firstgid))
        elem.set("source", self.source)

        return elem

    def __repr__(self) -> str:
        return f'<TilesetDef firstgid={self.firstgid} newfirstgid={self.newfirstgid} source={self.source}>'


class TiledMap:
    def __init__(self,
                 version="1.8",
                 tiledversion="1.8.2",
                 orientation="orthogonal",
                 renderorder="right-down",
                 width=64,
                 height=24,
                 tilewidth=24,
                 tileheight=24,
                 infinite=0,
                 nextlayerid=0,
                 nextobjectid=0) -> None:
        super().__init__()
        self.version = version
        self.tiledversion = tiledversion
        self.orientation = orientation
        self.renderorder = renderorder
        self.width = width
        self.height = height
        self.tilewidth = tilewidth
        self.tileheight = tileheight
        self.infinite = infinite  # Fixed the typo here
        self.nextlayerid = nextlayerid
        self.nextobjectid = nextobjectid

        self.tilesets: [TilesetDef] = []
        self.layers: [TiledLayer] = []

    @staticmethod
    def from_element(elem: ET.Element, directory="."):
        tiled_map = TiledMap(
            version=elem.get("version"),
            tiledversion=elem.get("tiledversion"),
            orientation=elem.get("orientation"),
            renderorder=elem.get("renderorder"),
            width=int(elem.get("width")),
            height=int(elem.get("height")),
            tilewidth=int(elem.get("tilewidth")),
            tileheight=int(elem.get("tileheight")),
            infinite=int(elem.get("infinite")),
            nextlayerid=int(elem.get("nextlayerid")),
            nextobjectid=int(elem.get("nextobjectid"))
        )

        tiled_map.load_from_element(elem, directory=directory)

        return tiled_map

    @staticmethod
    def from_file(path):
        tree = ET.parse(path)
        root = tree.getroot()
        return TiledMap.from_element(root, directory=os.path.dirname(path))

    def load_from_element(self, elem: ET.Element, directory="."):
        self.tilesets = []
        for c in elem:
            if c.tag == 'tileset':
                tile_set_def = TilesetDef.from_element(c, directory=directory)
                self.tilesets.append(tile_set_def)
                continue

            if c.tag == 'layer':
                layer = TiledLayer.from_element(c)
                self.layers.append(layer)
                continue

            print("unknown tag: ", c)

    def to_xml(self):
        elem = ET.Element("map")
        elem.set("version", self.version)
        elem.set("tiledversion", self.tiledversion)
        elem.set("orientation", self.orientation)
        elem.set("renderorder", self.renderorder)
        elem.set("width", str(self.width))
        elem.set("height", str(self.height))
        elem.set("tilewidth", str(self.tilewidth))
        elem.set("tileheight", str(self.tileheight))
        elem.set("infinite", str(self.infinite))
        elem.set("nextlayerid", str(self.nextlayerid))
        elem.set("nextobjectid", str(self.nextobjectid))

        for c in self.tilesets:
            elem.append(c.to_xml())

        for c in self.layers:
            elem.append(c.to_xml())

        return elem

    def tileset_for_gid(self, gid: int) -> TilesetDef | None:
        ts: TilesetDef
        for ts in self.tilesets:
            if gid >= ts.firstgid and gid < ts.firstgid + ts.tileset.tilecount:
                return ts

        return None

    def apply_new_firstgids(self) -> bool:
        ts: TilesetDef

        def sortfunc(item: TilesetDef):
            return item.newfirstgid

        new_ts = []
        sorted_ts = sorted(self.tilesets, key=sortfunc)
        for i in range(0, len(sorted_ts)):
            ts = sorted_ts[i]
            next_ts = None
            print(ts, ts.firstgid, '->', ts.newfirstgid)
            if i < len(sorted_ts) - 1:
                next_ts = sorted_ts[i + 1]
                print("   next:", next_ts)

            if next_ts:
                if ts.newfirstgid + ts.tileset.tilecount >= next_ts.newfirstgid:
                    print(f"Error: {ts.newfirstgid} + {ts.tileset.tilecount} >= {next_ts.newfirstgid}")
                    return False

            new_ts.append(ts)

        print(new_ts)
        print("Updating tile indices...")

        layer: TiledLayer
        for layer in self.layers:
            print(' -> layer: ', layer)
            for i in range(0, len(layer.tiles)):
                t = layer.tiles[i]
                if t == 0:
                    pass
                else:
                    ts = self.tileset_for_gid(t)

                    offs = t - ts.firstgid

                    new_value = ts.newfirstgid + offs
                    print(t, '->', new_value)
                    layer.tiles[i] = new_value

        return True
