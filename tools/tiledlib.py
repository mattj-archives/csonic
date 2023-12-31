import os
import xml.etree.ElementTree as ET
from xml.dom import minidom


class Property:
    def __init__(self, *, name, _type, value):
        self.name = name
        self.value = value
        self._type = _type

    def __repr__(self) -> str:
        return f'<Property {self.name} [{self._type}] = {self.value}>'

def read_properties(elem: ET.Element):
    props = []
    for c in elem:
        if c.tag == 'property':
            prop = Property(name=c.get("name"), _type=c.get("type"), value=c.get("value"))
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
        elem_prop.set("type", p._type)
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
        self.version = version
        self.tiledversion = tiledversion
        self.name = name
        self.tilewidth = tilewidth
        self.tileheight = tileheight
        self.tilecount = tilecount
        self.columns = columns
        self.backgroundcolor = backgroundcolor

        self.image: TilesetImage = None

        self.properties: [Property] = []

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

            print(f"Tileset '{self.name}': unknown tag {c.tag}")

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


#   <object id="4" gid="1170" x="264" y="240" width="24" height="24"/>
class TiledObject:
    def __init__(self, id: int, gid: int, x: float, y: float, width: float, height: float):
        super().__init__()
        self.id = id
        self.gid = gid
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.properties:[Property] = []

    def load_from_element(self, elem: ET.Element):
        for c in elem:
            if c.tag == 'properties':
                self.properties = read_properties(c)
                continue

            print(f'TiledObject: unknown tag {c}')

    @staticmethod
    def from_element(elem: ET.Element):
        tiled_object = TiledObject(
            int(elem.get("id")),
            int(elem.get("gid")),
            float(elem.get("x")),
            float(elem.get("y")),
            float(elem.get("width")),
            float(elem.get("height"))
        )

        tiled_object.load_from_element(elem)

        return tiled_object

    def to_xml(self):
        elem = ET.Element("object")
        elem.set("id", str(self.id))
        elem.set("gid", str(self.gid))
        elem.set("x", str(self.x))
        elem.set("y", str(self.y))
        elem.set("width", str(self.width))
        elem.set("height", str(self.height))

        if self.properties:
            elem.append(write_properties(self.properties))

        return elem

    def __repr__(self):
        return f'<TiledObject id={self.id} gid={self.gid} x={self.x}, y={self.y}>'

    def get_property_for_name(self, name: str) -> Property:
        for p in self.properties:
            if p.name == name:
                return p

        return None

class TiledObjectGroup:
    def __init__(self, id: int, name: str):
        super().__init__()
        self.id = id
        self.name = name
        self.objects = []

    def load_from_element(self, elem: ET.Element):
        for c in elem:
            if c.tag == 'object':
                self.objects.append(TiledObject.from_element(c))
                continue

            print(f'objectgroup: unknown tag {c.tag}')

    @staticmethod
    def from_element(elem: ET.Element):
        object_group = TiledObjectGroup(
            int(elem.get("id")),
            elem.get("name"),
        )
        object_group.load_from_element(elem)
        return object_group

    def to_xml(self):
        elem = ET.Element("objectgroup")
        elem.set("id", str(self.id))
        elem.set("name", str(self.name))
        for i in self.objects:
            elem.append(i.to_xml())
        return elem


class TiledLayer:

    def __init__(self, id, name, width, height, visible, locked) -> None:
        super().__init__()
        self.id = id
        self.name = name
        self.width = width
        self.height = height
        self.visible = visible
        self.locked = locked
        self.tiles = []

    @staticmethod
    def from_element(elem: ET.Element):
        layer = TiledLayer(
            elem.get("id"),
            elem.get("name"),
            int(elem.get("width")),
            int(elem.get("height")),
            int(elem.get("visible") or 1),
            int(elem.get("locked") or 0)
        )
        layer.load_from_element(elem)
        return layer

    def load_csv_data(self, elem: ET.Element):
        self.tiles = []

        for line in elem.text.split("\n"):
            for v in line.split(","):
                if len(v) > 0:
                    self.tiles.append(int(v))

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
        elem.set("visible", str(self.visible))
        elem.set("locked", str(self.locked))

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
        return f'<TilesetDef firstgid={self.firstgid} newfirstgid={self.newfirstgid} source={self.source} tileset.name={self.tileset.name}>'


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
        self.object_groups: [TiledObjectGroup] = []

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
                continue

            if c.tag == 'objectgroup':
                object_group = TiledObjectGroup.from_element(c)
                self.object_groups.append(object_group)
                continue

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

        for c in self.object_groups:
            elem.append(c.to_xml())

        if self.properties:
            elem.append(write_properties(self.properties))

        return elem

    def tileset_for_gid(self, gid: int) -> TilesetDef:
        ts: TilesetDef
        for ts in self.tilesets:
            if gid >= ts.firstgid and gid < ts.firstgid + ts.tileset.tilecount:
                return ts

        return None

    def all_objects(self):
        for g in self.object_groups:
            for obj in g.objects:
                yield obj

    def object_for_id(self, _id: int) -> TiledObject:
        obj: TiledObject
        for obj in self.all_objects():
            if obj.id == _id:
                return obj

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
        print("Updating tile indices in layers...")

        layer: TiledLayer
        for layer in self.layers:
            print(' -> layer: ', layer)
            for i in range(0, len(layer.tiles)):
                t = layer.tiles[i]
                if t == 0:
                    pass
                else:
                    ts = self.tileset_for_gid(t)
                    if not ts:
                        raise Exception(f"Tileset not found for gid {t}")

                    offs = t - ts.firstgid

                    new_value = ts.newfirstgid + offs
                    # if t != new_value:
                    #     print(t, '->', new_value)
                    layer.tiles[i] = new_value

        print("Updating tile indices in objectgroups...")
        og: TiledObjectGroup
        ob: TiledObject
        for og in self.object_groups:
            for ob in og.objects:
                ts = self.tileset_for_gid(ob.gid)
                ob.gid = ts.newfirstgid + (ob.gid - ts.firstgid)

        for ts in self.tilesets:
            ts.firstgid = ts.newfirstgid

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

    def clean_firstgids(self):
        firstgid = 1
        ts: TilesetDef
        for ts in self.tilesets:
            print(f'new first gid for {ts.tileset.name}: {firstgid}')
            ts.newfirstgid = firstgid
            firstgid += ts.tileset.tilecount + 1
            firstgid += (firstgid % 100)

        self.apply_new_firstgids()

    def write_to_file(self, path):
        with open(path, "wt") as f:
            _bytes = ET.tostring(self.to_xml(), xml_declaration=True, encoding='UTF-8')

            xmlstr = minidom.parseString(_bytes).toprettyxml(indent="   ")

            f.write(xmlstr)
