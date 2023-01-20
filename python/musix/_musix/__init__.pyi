from __future__ import annotations
import musix._musix
import typing

__all__ = [
    "Player",
    "init",
    "load"
]


class Player():
    def get_meta(self, name: str) -> typing.Union[str, float, int]: 
        """
        Get meta data about the loaded song.
        """
    def on_meta(self, arg0: typing.Callable[[typing.List[str]], None]) -> None: ...
        """
        Set callback to receive meta updates.
        """
    def render(self, count: int) -> object: 
        """
        Generate `count` number of samples and return `count*2` bytes
        """
    def seek(self, song: int, seconds: int = -1) -> bool: ...
    pass

def init() -> None:
    """
    Init musix
    """
def load(name: str) -> Player:
    """
    Load music file
    """
