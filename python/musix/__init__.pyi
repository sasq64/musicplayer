from __future__ import annotations
import musix
import typing
from musix._musix import Player

__all__ = [
    "Player",
    "init",
    "load"
]


def init() -> None:
    """
    Init musix. Must be called first.
    """
def load(name: str) -> Player:
    """
    Load music file. Throws an exception if the file could not
    be loaded.
    """
