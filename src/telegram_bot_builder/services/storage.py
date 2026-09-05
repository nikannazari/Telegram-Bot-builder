import json
from pathlib import Path
from typing import Any


class BotStorage:

    def __init__(
        self,
        storage_dir: str | Path = "bots",
    ):
        self.storage_dir = Path(storage_dir)

        self.storage_dir.mkdir(
            parents=True,
            exist_ok=True,
        )

    def save_config(
        self,
        bot_id: int,
        data: dict[str, Any],
    ) -> Path:

        bot_dir = self.storage_dir / str(bot_id)

        bot_dir.mkdir(
            parents=True,
            exist_ok=True,
        )

        config_file = bot_dir / "config.json"

        config_file.write_text(
            json.dumps(
                data,
                indent=4,
                ensure_ascii=False,
            ),
            encoding="utf-8",
        )

        return config_file

    def save_handlers(
        self,
        bot_id: int,
        handlers: list[dict[str, Any]],
    ) -> Path:

        bot_dir = self.storage_dir / str(bot_id)

        bot_dir.mkdir(
            parents=True,
            exist_ok=True,
        )

        handlers_file = bot_dir / "handlers.json"

        handlers_file.write_text(
            json.dumps(
                handlers,
                indent=4,
                ensure_ascii=False,
            ),
            encoding="utf-8",
        )

        return handlers_file

    def load_config(
        self,
        bot_id: int,
    ) -> dict[str, Any] | None:

        config_file = (
            self.storage_dir
            / str(bot_id)
            / "config.json"
        )

        if not config_file.exists():
            return None

        return json.loads(
            config_file.read_text(
                encoding="utf-8"
            )
        )

    def list_bots(self) -> list[str]:

        return [
            directory.name
            for directory in self.storage_dir.iterdir()
            if directory.is_dir()
        ]