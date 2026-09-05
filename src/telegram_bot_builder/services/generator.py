from pathlib import Path

from telegram_bot_builder.core.handler import (
    HandlerConfig,
    HandlerType,
)


class BotGenerator:

    def __init__(
        self,
        output_dir: str | Path = "generated",
    ):
        self.output_dir = Path(output_dir)

        self.output_dir.mkdir(
            parents=True,
            exist_ok=True,
        )

    def generate_handler(
        self,
        handler: HandlerConfig,
    ) -> str:

        trigger = self._escape(handler.trigger)
        response = self._escape(handler.response)

        if handler.handler_type == HandlerType.COMMAND:

            return f'''@bot.message_handler(commands=["{trigger}"])
def {handler.name}(message):
    bot.reply_to(message, "{response}")
'''

        if handler.handler_type == HandlerType.TEXT:

            return f'''@bot.message_handler(
    func=lambda message: message.text == "{trigger}"
)
def {handler.name}(message):
    bot.reply_to(message, "{response}")
'''

        if handler.handler_type == HandlerType.CONTAINS:

            return f'''@bot.message_handler(
    func=lambda message: "{trigger}".lower() in (message.text or "").lower()
)
def {handler.name}(message):
    bot.reply_to(message, "{response}")
'''

        if handler.handler_type == HandlerType.DEFAULT:

            return f'''@bot.message_handler(func=lambda message: True)
def {handler.name}(message):
    bot.reply_to(message, "{response}")
'''

        raise ValueError(
            f"Unsupported handler type: {handler.handler_type}"
        )

    def generate_bot(
        self,
        bot_name: str,
        handlers: list[HandlerConfig],
    ) -> Path:

        if not handlers:
            raise ValueError(
                "At least one handler is required."
            )

        filename = self._sanitize_filename(
            bot_name
        )

        if not filename:
            filename = "telegram_bot"

        output_file = (
            self.output_dir / f"{filename}.py"
        )

        generated_handlers = "\n\n".join(
            self.generate_handler(handler)
            for handler in handlers
        )

        source = f'''import os

import telebot


BOT_TOKEN = os.getenv("BOT_TOKEN")

if not BOT_TOKEN:
    raise RuntimeError(
        "BOT_TOKEN environment variable is not set"
    )


bot = telebot.TeleBot(BOT_TOKEN)


{generated_handlers}


if __name__ == "__main__":
    bot.infinity_polling()
'''

        output_file.write_text(
            source,
            encoding="utf-8",
        )

        return output_file

    @staticmethod
    def _escape(value: str) -> str:

        return (
            value
            .replace("\\", "\\\\")
            .replace('"', '\\"')
            .replace("\n", "\\n")
            .replace("\r", "\\r")
        )

    @staticmethod
    def _sanitize_filename(
        name: str,
    ) -> str:

        name = name.strip().lower()
        name = name.replace(" ", "_")

        allowed = (
            "abcdefghijklmnopqrstuvwxyz"
            "0123456789_-"
        )

        return "".join(
            char
            for char in name
            if char in allowed
        )