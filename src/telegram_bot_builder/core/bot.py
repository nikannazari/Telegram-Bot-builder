from dataclasses import dataclass, field
from typing import Any

from telegram_bot_builder.core.handler import HandlerConfig


@dataclass
class BotConfig:
    name: str
    username: str
    token: str = field(repr=False)
    telegram_id: int | None = None
    handlers: list[HandlerConfig] = field(
        default_factory=list
    )

    def add_handler(
        self,
        handler: HandlerConfig,
    ) -> None:
        self.handlers.append(handler)

    def remove_handler(
        self,
        handler_name: str,
    ) -> None:

        self.handlers = [
            handler
            for handler in self.handlers
            if handler.name != handler_name
        ]

    def get_handler(
        self,
        handler_name: str,
    ) -> HandlerConfig | None:

        for handler in self.handlers:

            if handler.name == handler_name:
                return handler

        return None

    def clear_handlers(self) -> None:
        self.handlers.clear()

    @property
    def handler_count(self) -> int:
        return len(self.handlers)

    def to_dict(self) -> dict[str, Any]:

        return {
            "telegram_id": self.telegram_id,
            "name": self.name,
            "username": self.username,
            "handler_count": self.handler_count,
        }