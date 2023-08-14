
class SpriteState:

    def __init__(self, name, left, right) -> None:
        super().__init__()
        self.name = name
        self.left = left
        self.right = right


class State:
    def __init__(self, name, duration, next_state, sprite_state, func=0) -> None:
        super().__init__()

        self.name = name
        self.duration = int(duration)
        self.next_state = next_state
        self.sprite_state = sprite_state
        self.func = func
