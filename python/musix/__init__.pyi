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
    Init musix
    """
def load(name: str) -> Player:
    """
    Load music file
    """
