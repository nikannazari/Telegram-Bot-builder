import sys
from pathlib import Path

import streamlit as st


ROOT_DIR = Path(__file__).resolve().parent.parent
SRC_DIR = ROOT_DIR / "src"

if str(SRC_DIR) not in sys.path:
    sys.path.insert(0, str(SRC_DIR))


from telegram_bot_builder.core.bot import BotConfig
from telegram_bot_builder.core.handler import (
    HandlerConfig,
    HandlerType,
)
from telegram_bot_builder.services.generator import BotGenerator
from telegram_bot_builder.services.storage import BotStorage
from telegram_bot_builder.services.telegram import (
    TelegramBotService,
)
from telegram_bot_builder.utils.validators import (
    validate_bot_token,
    validate_response,
    validate_trigger,
)


st.set_page_config(
    page_title="Telegram Bot Builder",
    page_icon="🤖",
    layout="wide",
)


storage = BotStorage(
    ROOT_DIR / "bots"
)


if "bot_config" not in st.session_state:
    st.session_state.bot_config = None

if "handlers" not in st.session_state:
    st.session_state.handlers = []

if "bot_service" not in st.session_state:
    st.session_state.bot_service = None

if "generated_file" not in st.session_state:
    st.session_state.generated_file = None


def load_saved_bot(
    bot_id: str,
):
    bot_id_int = int(bot_id)

    config_data = storage.load_config(
        bot_id_int
    )

    if not config_data:
        return None

    token = config_data.get("token")

    if not token:
        raise ValueError(
            "Saved bot does not contain a token."
        )

    config = BotConfig(
        name=config_data["name"],
        username=config_data["username"],
        token=token,
        telegram_id=config_data["telegram_id"],
    )

    handlers_data = storage.load_handlers(
        bot_id_int
    )

    handlers = []

    for data in handlers_data:

        handlers.append(
            HandlerConfig(
                name=data["name"],
                handler_type=HandlerType(
                    data["type"]
                ),
                trigger=data.get(
                    "trigger",
                    "",
                ),
                response=data["response"],
            )
        )

    return config, handlers


def save_current_bot() -> None:

    config = st.session_state.bot_config

    if config is None:
        return

    storage.save_config(
        config.telegram_id,
        config.to_dict(),
    )

    handlers_data = [
        {
            "name": handler.name,
            "type": handler.handler_type.value,
            "trigger": handler.trigger,
            "response": handler.response,
        }
        for handler in st.session_state.handlers
    ]

    storage.save_handlers(
        config.telegram_id,
        handlers_data,
    )


def create_bot_service(
    config: BotConfig,
) -> TelegramBotService:

    return TelegramBotService(
        config.token
    )


st.title("🤖 Telegram Bot Builder")

st.write(
    "Build and run Telegram bots using TeleBot."
)


# ============================================================
# SIDEBAR
# ============================================================

st.sidebar.title("Bot Manager")

saved_bots = storage.list_bots()

if saved_bots:

    selected_bot = st.sidebar.selectbox(
        "Saved Bots",
        options=saved_bots,
    )

    if st.sidebar.button(
        "Load Bot",
        use_container_width=True,
    ):

        try:

            loaded = load_saved_bot(
                selected_bot
            )

            if loaded:

                config, handlers = loaded

                service = create_bot_service(
                    config
                )

                st.session_state.bot_config = config

                st.session_state.handlers = handlers

                st.session_state.bot_service = service

                st.session_state.generated_file = None

                st.sidebar.success(
                    f"Bot @{config.username} loaded."
                )

                st.rerun()

            else:

                st.sidebar.error(
                    "Could not load bot configuration."
                )

        except Exception as error:

            st.sidebar.error(
                f"Could not load bot: {error}"
            )

else:

    st.sidebar.info(
        "No saved bots."
    )


# ============================================================
# CONNECT BOT
# ============================================================

st.divider()

st.header("1. Connect Telegram Bot")

st.info(
    "Create your bot with @BotFather first, "
    "then paste the Bot Token below."
)

bot_token = st.text_input(
    "Bot Token",
    type="password",
    placeholder="123456789:ABC...",
)


if st.button(
    "Connect Bot",
    use_container_width=True,
):

    try:

        validate_bot_token(
            bot_token
        )

        with st.spinner(
            "Connecting to Telegram..."
        ):

            service = TelegramBotService(
                bot_token.strip()
            )

            bot_info = service.get_bot_info()

        config = BotConfig(
            name=bot_info["first_name"],
            username=bot_info["username"] or "",
            token=bot_token.strip(),
            telegram_id=bot_info["id"],
        )

        st.session_state.bot_config = config

        st.session_state.bot_service = service

        st.session_state.handlers = []

        st.session_state.generated_file = None

        save_current_bot()

        st.success(
            "Telegram bot connected successfully."
        )

        st.rerun()

    except Exception as error:

        st.error(
            f"Could not connect to Telegram: {error}"
        )


# ============================================================
# BOT INFORMATION
# ============================================================

if st.session_state.bot_config:

    config = st.session_state.bot_config

    st.divider()

    st.header("2. Bot Information")

    col1, col2, col3 = st.columns(3)

    with col1:

        st.metric(
            "Bot Name",
            config.name,
        )

    with col2:

        st.metric(
            "Username",
            f"@{config.username}",
        )

    with col3:

        st.metric(
            "Telegram ID",
            config.telegram_id,
        )


# ============================================================
# HANDLER BUILDER
# ============================================================

if st.session_state.bot_config:

    st.divider()

    st.header("3. Handler Builder")

    handler_type = st.selectbox(
        "Handler Type",
        options=[
            HandlerType.TEXT.value,
            HandlerType.COMMAND.value,
            HandlerType.CONTAINS.value,
            HandlerType.DEFAULT.value,
        ],
    )

    trigger = ""

    if handler_type != HandlerType.DEFAULT.value:

        trigger = st.text_input(
            "Trigger",
            placeholder="python",
        )

    response = st.text_area(
        "Response",
        placeholder="You mentioned Python!",
        height=120,
    )

    if st.button(
        "Add Handler",
        use_container_width=True,
    ):

        errors = []

        if handler_type != HandlerType.DEFAULT.value:

            try:

                validate_trigger(
                    trigger
                )

            except ValueError as error:

                errors.append(
                    str(error)
                )

        try:

            validate_response(
                response
            )

        except ValueError as error:

            errors.append(
                str(error)
            )

        if errors:

            for error in errors:

                st.error(error)

        else:

            if handler_type == HandlerType.DEFAULT.value:

                handler_name = "handle_default"

            else:

                safe_trigger = (
                    trigger
                    .strip()
                    .lower()
                    .replace("/", "")
                    .replace(" ", "_")
                )

                handler_name = (
                    f"handle_{safe_trigger}"
                )

            handler = HandlerConfig(
                name=handler_name,
                handler_type=HandlerType(
                    handler_type
                ),
                trigger=trigger,
                response=response,
            )

            if (
                handler.handler_type
                == HandlerType.DEFAULT
                and any(
                    item.handler_type
                    == HandlerType.DEFAULT
                    for item
                    in st.session_state.handlers
                )
            ):

                st.error(
                    "Only one default handler is allowed."
                )

            else:

                st.session_state.handlers.append(
                    handler
                )

                save_current_bot()

                st.success(
                    f"Handler '{handler.name}' added."
                )


# ============================================================
# CONFIGURED HANDLERS
# ============================================================

if st.session_state.handlers:

    st.divider()

    st.header("4. Configured Handlers")

    for index, handler in enumerate(
        st.session_state.handlers
    ):

        with st.container(
            border=True
        ):

            col1, col2 = st.columns(
                [5, 1]
            )

            with col1:

                st.write(
                    f"**Function:** `{handler.name}`"
                )

                st.write(
                    f"**Type:** `{handler.handler_type.value}`"
                )

                if handler.trigger:

                    st.write(
                        f"**Trigger:** `{handler.trigger}`"
                    )

                st.write(
                    f"**Response:** {handler.response}"
                )

            with col2:

                if st.button(
                    "Delete",
                    key=f"delete_handler_{index}",
                ):

                    st.session_state.handlers.pop(
                        index
                    )

                    save_current_bot()

                    st.rerun()


# ============================================================
# GENERATE BOT
# ============================================================

if (
    st.session_state.bot_config
    and st.session_state.handlers
):

    st.divider()

    st.header("5. Generate Python Bot")

    if st.button(
        "Generate Bot",
        use_container_width=True,
    ):

        try:

            generator = BotGenerator(
                output_dir=ROOT_DIR / "generated"
            )

            output_file = generator.generate_bot(
                bot_name=(
                    st.session_state.bot_config.name
                ),
                handlers=(
                    st.session_state.handlers
                ),
            )

            st.session_state.generated_file = (
                output_file
            )

            save_current_bot()

            st.success(
                f"Bot generated: `{output_file}`"
            )

        except Exception as error:

            st.error(
                f"Could not generate bot: {error}"
            )


# ============================================================
# GENERATED CODE
# ============================================================

if st.session_state.generated_file:

    generated_file = (
        st.session_state.generated_file
    )

    if generated_file.exists():

        st.divider()

        st.header("6. Generated Python Code")

        source_code = generated_file.read_text(
            encoding="utf-8"
        )

        st.code(
            source_code,
            language="python",
        )

        st.download_button(
            "Download Python Bot",
            data=source_code,
            file_name=generated_file.name,
            mime="text/x-python",
            use_container_width=True,
        )


# ============================================================
# BOT CONTROLS
# ============================================================

if (
    st.session_state.bot_config
    and st.session_state.handlers
):

    st.divider()

    st.header("7. Bot Controls")

    col1, col2 = st.columns(2)

    with col1:

        if st.button(
            "▶ Start Bot",
            use_container_width=True,
        ):

            service = (
                st.session_state.bot_service
            )

            if service is None:

                service = create_bot_service(
                    st.session_state.bot_config
                )

                st.session_state.bot_service = (
                    service
                )

            try:

                service.register_handlers(
                    st.session_state.handlers
                )

                service.start()

                st.success(
                    "Bot started successfully."
                )

            except Exception as error:

                st.error(
                    f"Could not start bot: {error}"
                )

    with col2:

        if st.button(
            "■ Stop Bot",
            use_container_width=True,
        ):

            service = (
                st.session_state.bot_service
            )

            if service:

                service.stop()

                st.success(
                    "Bot stopped."
                )