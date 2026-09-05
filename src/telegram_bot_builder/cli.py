import argparse
import sys
from pathlib import Path


ROOT_DIR = Path(__file__).resolve().parents[3]

if str(ROOT_DIR / "src") not in sys.path:
    sys.path.insert(0, str(ROOT_DIR / "src"))


from telegram_bot_builder.core.handler import (
    HandlerConfig,
    HandlerType,
)
from telegram_bot_builder.services.generator import (
    BotGenerator,
)


def main():

    parser = argparse.ArgumentParser(
        description="Telegram Bot Builder"
    )

    parser.add_argument(
        "--name",
        required=True,
        help="Bot name",
    )

    parser.add_argument(
        "--trigger",
        required=True,
        help="Text trigger",
    )

    parser.add_argument(
        "--response",
        required=True,
        help="Bot response",
    )

    args = parser.parse_args()

    handler = HandlerConfig(
        name="handle_trigger",
        handler_type=HandlerType.TEXT,
        trigger=args.trigger,
        response=args.response,
    )

    generator = BotGenerator(
        output_dir=ROOT_DIR / "generated"
    )

    output_file = generator.generate_bot(
        bot_name=args.name,
        handlers=[handler],
    )

    print(
        f"Bot generated successfully:\n{output_file}"
    )


if __name__ == "__main__":
    main()