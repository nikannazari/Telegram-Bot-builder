import os
import sys
from pathlib import Path

import streamlit as st


ROOT_DIR = Path(__file__).resolve().parent.parent
SRC_DIR = ROOT_DIR / "src"

if str(SRC_DIR) not in sys.path:
    sys.path.insert(0, str(SRC_DIR))


from telegram_bot_builder.core.bot import BotConfig
from telegram_bot_builder.core.handler import HandlerConfig, HandlerType
from telegram_bot_builder.services.generator import BotGenerator
from telegram_bot_builder.services.telegram import TelegramBotService
from telegram_bot_builder.utils.validators import (
    validate_bot_name,
    validate_bot_token,
    validate_bot_username,
    validate_response,
    validate_trigger,
)


st.set_page_config(
    page_title="Telegram Bot Builder",
    page_icon="🤖",
    layout="wide",
)


if "bot_config" not in st.session_state:
    st.session_state.bot_config = None

if "handlers" not in st.session_state:
    st.session_state.handlers = []

if "bot_service" not in st.session_state:
    st.session_state.bot_service = None

if "bot_running" not in st.session_state:
    st.session_state.bot_running = False


st.title("🤖 Telegram Bot Builder")
st.write(
    "Build a Telegram bot with TeleBot without writing the handlers manually."
)

st.divider()


# ---------------------------------------------------------
# Bot Configuration
# ---------------------------------------------------------

st.header("1. Bot Configuration")

col1, col2 = st.columns(2)

with col1:
    bot_name = st.text_input(
        "Bot Name",
        placeholder="My Python Bot",
    )

with col2:
    bot_username = st.text_input(
        "Bot Username",
        placeholder="my_python_bot",
    )

bot_token = st.text_input(
    "Bot Token",
    type="password",
    placeholder="123456789:ABC...",
    help="Get this token from @BotFather.",
)


if st.button("Create Bot Configuration", use_container_width=True):

    errors = []

    try:
        validate_bot_name(bot_name)
    except ValueError as error:
        errors.append(str(error))

    try:
        validate_bot_username(bot_username)
    except ValueError as error:
        errors.append(str(error))

    try:
        validate_bot_token(bot_token)
    except ValueError as error:
        errors.append(str(error))

    if errors:
        for error in errors:
            st.error(error)
    else:
        st.session_state.bot_config = BotConfig(
            name=bot_name,
            username=bot_username,
            token=bot_token,
        )

        st.success("Bot configuration created.")


# ---------------------------------------------------------
# Handler Builder
# ---------------------------------------------------------

if st.session_state.bot_config:

    st.divider()

    st.header("2. Add Handler")

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

    if st.button("Add Handler", use_container_width=True):

        errors = []

        if handler_type != HandlerType.DEFAULT.value:
            try:
                validate_trigger(trigger)
            except ValueError as error:
                errors.append(str(error))

        try:
            validate_response(response)
        except ValueError as error:
            errors.append(str(error))

        if errors:
            for error in errors:
                st.error(error)

        else:

            handler_name = "handle_"

            if handler_type == HandlerType.DEFAULT.value:
                handler_name += "default"

            else:
                safe_trigger = (
                    trigger.lower()
                    .replace(" ", "_")
                    .replace("/", "")
                )

                handler_name += safe_trigger

            handler = HandlerConfig(
                name=handler_name,
                handler_type=HandlerType(handler_type),
                trigger=trigger,
                response=response,
            )

            if (
                handler.handler_type == HandlerType.DEFAULT
                and any(
                    item.handler_type == HandlerType.DEFAULT
                    for item in st.session_state.handlers
                )
            ):
                st.error("Only one default handler is allowed.")

            else:
                st.session_state.handlers.append(handler)
                st.success("Handler added.")


# ---------------------------------------------------------
# Handler List
# ---------------------------------------------------------

if st.session_state.handlers:

    st.divider()

    st.header("3. Bot Handlers")

    for index, handler in enumerate(
        st.session_state.handlers
    ):

        with st.container(border=True):

            col1, col2, col3 = st.columns([2, 2, 1])

            with col1:
                st.write(f"**Name:** `{handler.name}`")

            with col2:
                st.write(
                    f"**Type:** `{handler.handler_type.value}`"
                )

                if handler.trigger:
                    st.write(
                        f"**Trigger:** `{handler.trigger}`"
                    )

            with col3:
                if st.button(
                    "Delete",
                    key=f"delete_{index}",
                ):
                    st.session_state.handlers.pop(index)
                    st.rerun()

            st.write(
                f"**Response:** {handler.response}"
            )


# ---------------------------------------------------------
# Generate Bot
# ---------------------------------------------------------

if (
    st.session_state.bot_config
    and st.session_state.handlers
):

    st.divider()

    st.header("4. Generate Bot")

    if st.button(
        "Generate Python Bot",
        use_container_width=True,
    ):

        generator = BotGenerator(
            output_dir=ROOT_DIR / "generated"
        )

        output_file = generator.generate_bot(
            bot_name=st.session_state.bot_config.name,
            handlers=st.session_state.handlers,
        )

        st.success(
            f"Bot generated successfully: `{output_file}`"
        )

        st.session_state.generated_file = output_file


# ---------------------------------------------------------
# Generated Source
# ---------------------------------------------------------

if "generated_file" in st.session_state:

    st.divider()

    st.header("5. Generated Python Code")

    generated_file = st.session_state.generated_file

    if generated_file.exists():

        source_code = generated_file.read_text(
            encoding="utf-8"
        )

        st.code(
            source_code,
            language="python",
        )

        st.download_button(
            label="Download Python Bot",
            data=source_code,
            file_name=generated_file.name,
            mime="text/x-python",
        )


# ---------------------------------------------------------
# Bot Controls
# ---------------------------------------------------------

if st.session_state.bot_config:

    st.divider()

    st.header("6. Bot Controls")

    col1, col2 = st.columns(2)

    with col1:

        if st.button(
            "▶ Start Bot",
            use_container_width=True,
        ):

            if not st.session_state.handlers:
                st.error("Add at least one handler first.")

            else:

                service = TelegramBotService(
                    st.session_state.bot_config.token
                )

                try:
                    service.connect()

                    service.register_handlers(
                        st.session_state.handlers
                    )

                    service.start()

                    st.session_state.bot_service = service
                    st.session_state.bot_running = True

                    st.success("Bot started.")

                except Exception as error:
                    st.error(f"Failed to start bot: {error}")

    with col2:

        if st.button(
            "■ Stop Bot",
            use_container_width=True,
        ):

            service = st.session_state.bot_service

            if service:

                service.stop()

                st.session_state.bot_running = False

                st.success("Bot stopped.")