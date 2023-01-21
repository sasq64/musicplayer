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
        Get meta data about the loaded song. Basic meta names include;
        'title' or 'game', 'composer', 'length' etc
        """
    def on_meta(self, arg0: typing.Callable[[typing.List[str]], None]) -> None: ...
        """
        Set callback to receive meta updates.
        """
    def render(self, count: int) -> bytes: 
        """
        Generate `count` number of audio samples in 44100Hz stereo signed 16 bit 
        (returns `count*2` bytes).
        """
    def seek(self, song: int, seconds: int = -1) -> bool: ...
        """
        Switch subsong, and/or seek to position if plugin supports it.
        """
    pass

def init() -> None:
    """
    Init musix.
    """
def load(name: str) -> Player:
    """
    Load music file.
    """
