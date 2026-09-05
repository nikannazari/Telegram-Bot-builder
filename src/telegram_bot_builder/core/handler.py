from dataclasses import dataclass
from enum import Enum


class HandlerType(str, Enum):
    COMMAND = "command"
    TEXT = "text"
    CONTAINS = "contains"
    DEFAULT = "default"


@dataclass
class HandlerConfig:
    name: str
    handler_type: HandlerType
    trigger: str
    response: str