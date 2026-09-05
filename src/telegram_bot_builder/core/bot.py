from dataclasses import dataclass, field

from telegram_bot_builder.core.handler import HandlerConfig


@dataclass
class BotConfig:
    name: str
    username: str
    token: str = field(repr=False)
    handlers: list[HandlerConfig] = field(default_factory=list)

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