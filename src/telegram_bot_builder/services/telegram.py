import threading
from typing import Callable

import telebot

from telegram_bot_builder.core.handler import (
    HandlerConfig,
    HandlerType,
)


class TelegramBotService:

    def __init__(self, token: str):

        if not token:
            raise ValueError(
                "Bot token cannot be empty."
            )

        self.token = token
        self.bot = telebot.TeleBot(token)

        self._thread: threading.Thread | None = None
        self._running = False

    def connect(self):

        bot_info = self.bot.get_me()

        return bot_info

    def register_handlers(
        self,
        handlers: list[HandlerConfig],
    ) -> None:

        regular_handlers = [
            handler
            for handler in handlers
            if handler.handler_type != HandlerType.DEFAULT
        ]

        default_handlers = [
            handler
            for handler in handlers
            if handler.handler_type == HandlerType.DEFAULT
        ]

        for handler in regular_handlers:
            self._register_handler(handler)

        for handler in default_handlers:
            self._register_handler(handler)

    def _register_handler(
        self,
        handler: HandlerConfig,
    ) -> None:

        callback = self._create_callback(
            handler.response
        )

        if handler.handler_type == HandlerType.COMMAND:

            command = handler.trigger.lstrip("/")

            self.bot.register_message_handler(
                callback,
                commands=[command],
            )

        elif handler.handler_type == HandlerType.TEXT:

            trigger = handler.trigger

            self.bot.register_message_handler(
                callback,
                func=lambda message,
                trigger=trigger:
                    message.text == trigger,
            )

        elif handler.handler_type == HandlerType.CONTAINS:

            trigger = handler.trigger.lower()

            self.bot.register_message_handler(
                callback,
                func=lambda message,
                trigger=trigger:
                    trigger in (
                        message.text or ""
                    ).lower(),
            )

        elif handler.handler_type == HandlerType.DEFAULT:

            self.bot.register_message_handler(
                callback,
                func=lambda message: True,
            )

        else:

            raise ValueError(
                f"Unsupported handler type: "
                f"{handler.handler_type}"
            )

    def _create_callback(
        self,
        response: str,
    ) -> Callable:

        def callback(message):

            self.bot.reply_to(
                message,
                response,
            )

        return callback

    def start(self) -> None:

        if self._running:
            return

        self._running = True

        self._thread = threading.Thread(
            target=self._polling_worker,
            daemon=True,
        )

        self._thread.start()

    def _polling_worker(self):

        try:

            self.bot.infinity_polling(
                skip_pending=True,
            )

        except Exception as error:

            print(
                f"Telegram polling error: {error}"
            )

        finally:

            self._running = False

    def stop(self) -> None:

        if not self._running:
            return

        self.bot.stop_polling()

        self._running = False

        if (
            self._thread
            and self._thread.is_alive()
        ):

            self._thread.join(
                timeout=5
            )

        self._thread = None

    @property
    def is_running(self) -> bool:
        return self._running