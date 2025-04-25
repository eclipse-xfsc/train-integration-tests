# pylint: disable=missing-module-docstring,missing-class-docstring,too-few-public-methods
from typing import Optional


class Ui:
    def __init__(self, host: Optional[str] = None) -> None:
        del host
        raise NotImplementedError()

    def is_up(self) -> bool:
        raise NotImplementedError()
