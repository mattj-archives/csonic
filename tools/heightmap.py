import PIL.Image


class HeightMapTool:

    def __init__(self) -> None:
        super().__init__()

    def get_heights(self, img, tx, ty) -> []:
        print("tile", tx, ty)
        heights = [0 for i in range(0, 24)]
        for x in range(0, 24):
            for y in range(ty * 24, ty * 24 + 24):
                if img[y * img.size[1] + (tx * 24 + x)] == (255, 255, 255):
                    h = 24 - (y - ty * 24)
                    # print(f'height found at x={x}', h)
                    heights[x] = h
                    break

        print(heights)
        return heights

    def run(self):
        img = PIL.Image.open("dev/height.png")
        data = img.getdata()
        print(data.size)
        heights = []

        for ty in range(0, 16):
            for tx in range(0, 16):
                heights.append(self.get_heights(data, tx, ty))

        print("heights:", heights)

        with open("height.dat", "wb") as f:
            for h in heights:
                f.write(bytes(h))


