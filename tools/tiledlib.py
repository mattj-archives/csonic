import os
import xml.etree.ElementTree as ET
from xml.dom import minidom

class Property:
    def __init__(self, name, value):
        self.name = name
        self.value = value


def read_properties(elem: ET.Element):
    props = []
    for c in elem:
        if c.tag == 'property':
            prop = Property(c.get("name"), c.get("value"))
            props.append(prop)
            continue

        print('read_properties: unknown tag ', c.tag)

    return props


def write_properties(props) -> ET.Element:
    elem_props = ET.Element("properties")
    p: Property
    for p in props:
        elem_prop = ET.Element("property")
        elem_prop.set("name", p.name)
        elem_prop.set("value", p.value)
        elem_props.append(elem_prop)
    return elem_props

class TilesetImage:
    def __init__(self, source, trans, width, height):
        self.source = source
        self.trans = trans
        self.width = width
        self.height = height

    def to_xml(self):
        elem = ET.Element("image")
        elem.set("source", self.source)
        elem.set("trans", self.trans)
        elem.set("width", str(self.width))
        elem.set("height", str(self.height))

        return elem


class Tileset:

    def __init__(self,
                 version="1.8",
                 tiledversion="1.8.2",
                 name="", tilewidth=16, tileheight=16, tilecount=256, columns=16,
                 backgroundcolor='#000000') -> None:
        super().__init__()
        self.version=version
        self.tiledversion=tiledversion
        self.name = name
        self.tilewidth = tilewidth
        self.tileheight = tileheight
        self.tilecount = tilecount
        self.columns = columns
        self.backgroundcolor = backgroundcolor

        self.image: TilesetImage = None

        self.properties = []

    def write_to_xml_element(self, elem: ET.Element):
        if self.version:
            elem.set('version', self.version)
        if self.tiledversion:
            elem.set('tiledversion', self.tiledversion)
        elem.set('name', self.name)
        elem.set('tilewidth', str(self.tilewidth))
        elem.set('tileheight', str(self.tileheight))
        elem.set('tilecount', str(self.tilecount))
        elem.set('columns', str(self.columns))
        elem.set('backgroundcolor', self.backgroundcolor)

        elem.append(self.image.to_xml())

        if self.properties:
            elem.append(write_properties(self.properties))

    def to_xml(self):
        elem = ET.Element("tileset")
        self.write_to_xml_element(elem)
        return elem

    def load_from_element(self, root: ET.Element):
        for c in root:
            if c.tag == 'image':
                source = c.get("source")
                trans = c.get("trans")
                width = int(c.get("width"))
                height = int(c.get("height"))

                self.image = TilesetImage(source, trans, width, height)

                continue

            if c.tag == 'properties':
                self.properties = read_properties(c)
                continue

            print("Tileset: unknown tag", c.tag)

    @staticmethod
    def from_file(path):
        tree = ET.parse(path)
        root = tree.getroot()
        return Tileset.from_element(root)

    @staticmethod
    def from_element(elem: ET.Element):
        tileset = Tileset(
            elem.get("version"),
            elem.get("tiledversion"),
            elem.get("name"),
            int(elem.get("tilewidth")),
            int(elem.get("tileheight")),
            int(elem.get("tilecount")),
            int(elem.get("columns")),
            elem.get("backgroundcolor"))

        tileset.load_from_element(elem)

        return tileset

    def write_to_file(self, path):
        with open(path, "wt") as f:
            _bytes = ET.tostring(self.to_xml(), xml_declaration=True, encoding='UTF-8')

            xmlstr = minidom.parseString(_bytes).toprettyxml(indent="   ")

            f.write(xmlstr)


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
        elem.set("id", str(self.id))
        elem.set("name", self.name)
        elem.set("width", str(self.width))
        elem.set("height", str(self.height))

        elem_data = ET.Element("data")
        elem_data.set("encoding", "csv")
        elem_data.text = ','.join([str(x) for x in self.tiles])
        elem.append(elem_data)
        return elem


class TilesetDef:

    def __init__(self,
                 firstgid: int,
                 source=None,
                 tileset: Tileset = None,
                 directory="./"):
        self.firstgid = firstgid
        self.newfirstgid = self.firstgid

        self.source = source

        if self.source:
            self.tileset = Tileset.from_file(f'{directory}/{self.source}')
        else:
            self.tileset = tileset

    @staticmethod
    def from_source(firstgid: int, source: str, directory="./"):
        return TilesetDef(firstgid=firstgid, source=source, directory=directory)

    @staticmethod
    def from_element(elem: ET.Element, directory="."):

        if not elem.get("source"):
            return TilesetDef(firstgid=int(elem.get("firstgid")),
                              source=None,
                              tileset=Tileset.from_element(elem),
                              directory=directory)

        return TilesetDef.from_source(
            firstgid=int(elem.get("firstgid")),
            source=elem.get("source"),
            directory=directory
        )

    def to_xml(self):
        elem = ET.Element("tileset")
        elem.set("firstgid", str(self.firstgid))
        if self.source is not None:
            elem.set("source", self.source)
        else:
            self.tileset.write_to_xml_element(elem)

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

        self.properties = []

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

            if c.tag == 'properties':
                self.properties = read_properties(c)

            print("TiledMap: unknown tag: ", c)

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

        if self.properties:
            elem.append(write_properties(self.properties))

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

    def layer_for_name(self, name):
        try:
            return next(layer for layer in self.layers if layer.name == name)
        except StopIteration:
            return None

    def get_next_firstgid(self):
        max_firstgid = 0
        for ts in self.tilesets:
            v = ts.firstgid + ts.tileset.tilecount
            if v > max_firstgid:
                max_firstgid = v

        return max_firstgid

    def write_to_file(self, path):
        with open(path, "wt") as f:
            _bytes = ET.tostring(self.to_xml(), xml_declaration=True, encoding='UTF-8')

            xmlstr = minidom.parseString(_bytes).toprettyxml(indent="   ")

            f.write(xmlstr)


