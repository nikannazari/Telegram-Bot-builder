import re


def validate_bot_name(
    name: str,
) -> bool:

    if not name.strip():
        raise ValueError(
            "Bot name cannot be empty."
        )

    if len(name.strip()) > 128:
        raise ValueError(
            "Bot name is too long."
        )

    return True


def validate_bot_username(
    username: str,
) -> bool:

    username = username.strip()

    if username.startswith("@"):
        username = username[1:]

    if not username:
        raise ValueError(
            "Bot username cannot be empty."
        )

    if not username.endswith("bot"):
        raise ValueError(
            "Telegram bot username must end with 'bot'."
        )

    if not re.fullmatch(
        r"[A-Za-z0-9_]+",
        username,
    ):
        raise ValueError(
            "Invalid bot username."
        )

    return True


def validate_bot_token(
    token: str,
) -> bool:

    token = token.strip()

    if not token:
        raise ValueError(
            "Bot token cannot be empty."
        )

    if ":" not in token:
        raise ValueError(
            "Invalid Telegram bot token."
        )

    return True


def validate_trigger(
    trigger: str,
) -> bool:

    if not trigger.strip():
        raise ValueError(
            "Trigger cannot be empty."
        )

    return True


def validate_response(
    response: str,
) -> bool:

    if not response.strip():
        raise ValueError(
            "Response cannot be empty."
        )

    return True