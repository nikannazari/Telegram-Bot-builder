# 🤖 Telegram Bot Builder

A modular Python application for building and running Telegram bots using **TeleBot (`pyTelegramBotAPI`)** with a **Streamlit** interface.

The project allows you to connect an existing Telegram bot, configure message handlers, generate Python source code, save bot configurations, and run the bot directly from the application.

---

## ✨ Features

* Connect existing Telegram bots using a Bot Token
* Verify bot credentials through the Telegram API
* Automatically retrieve:

  * Bot ID
  * Bot name
  * Bot username
* Create message handlers without manually writing code
* Supported handler types:

  * Text
  * Command
  * Contains
  * Default
* Generate a complete Python Telegram bot
* Save bot configurations locally
* Save handler configurations locally
* Load previously saved bots
* Start and stop bots from Streamlit
* Download generated Python source code
* Modular project architecture
* CLI support

---

## 🏗️ Project Structure

```text
Telegram-Bot-Builder/
│
├── main.py
│
├── app/
│   └── streamlit_app.py
│
├── assets/
│
├── bots/
│   └── .gitkeep
│
├── generated/
│   └── .gitkeep
│
├── src/
│   └── telegram_bot_builder/
│       │
│       ├── __init__.py
│       │
│       ├── cli.py
│       │
│       ├── core/
│       │   ├── __init__.py
│       │   ├── bot.py
│       │   └── handler.py
│       │
│       ├── services/
│       │   ├── __init__.py
│       │   ├── generator.py
│       │   ├── storage.py
│       │   └── telegram.py
│       │
│       └── utils/
│           ├── __init__.py
│           └── validators.py
│
├── .env.example
├── .gitignore
├── LICENSE
├── README.md
├── pyproject.toml
└── requirements.txt
```

---

## ⚙️ Architecture

The project follows a modular architecture:

```text
                    ┌──────────────────┐
                    │    Streamlit     │
                    │       UI         │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │      Core        │
                    │                  │
                    │ BotConfig        │
                    │ HandlerConfig    │
                    └────────┬─────────┘
                             │
             ┌───────────────┼────────────────┐
             ▼               ▼                ▼
       ┌──────────┐   ┌─────────────┐   ┌──────────┐
       │ Telegram │   │  Generator  │   │ Storage  │
       │ Service  │   │             │   │          │
       └────┬─────┘   └──────┬──────┘   └────┬─────┘
            │                │               │
            ▼                ▼               ▼
         Telegram         .py file       JSON files
```

### Core

Contains the application's main data models.

### Services

Contains application functionality such as:

* Telegram API communication
* Python code generation
* Local configuration storage

### Utils

Contains validation and helper functionality.

### App

Contains the Streamlit user interface.

---

## 🚀 Installation

Clone the repository:

```bash
git clone <repository-url>
cd Telegram-Bot-Builder
```

Create a virtual environment:

```bash
python -m venv .venv
```

Activate it on Linux:

```bash
source .venv/bin/activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

---

## ▶️ Running the Application

The recommended way is:

```bash
python main.py
```

Then select:

```text
1. Start Streamlit
```

Alternatively, run Streamlit directly:

```bash
streamlit run app/streamlit_app.py
```

---

## 🤖 Creating a Telegram Bot

Telegram bot accounts must be created through **BotFather**.

1. Open Telegram.
2. Open `@BotFather`.
3. Create a new bot.
4. Copy the generated Bot Token.
5. Open Telegram Bot Builder.
6. Paste the token into the application.
7. Click **Connect Bot**.

The application verifies the token through the Telegram API.

---

## 🧩 Handler Builder

After connecting a bot, handlers can be created through the Streamlit interface.

### Text Handler

Example:

```text
Trigger:
python

Response:
You mentioned Python!
```

The generated code will look like:

```python
@bot.message_handler(
    func=lambda message: message.text == "python"
)
def handle_python(message):
    bot.reply_to(message, "You mentioned Python!")
```

### Command Handler

Example:

```text
Trigger:
/start

Response:
Welcome!
```

Generated code:

```python
@bot.message_handler(commands=["start"])
def handle_start(message):
    bot.reply_to(message, "Welcome!")
```

### Contains Handler

Example:

```text
Trigger:
python

Response:
You are talking about Python.
```

This handler responds when the trigger appears inside the message.

### Default Handler

The default handler responds to messages that were not handled by other handlers.

Only one default handler is allowed.

---

## 💾 Data Storage

Bot configurations are stored locally:

```text
bots/
└── <telegram_id>/
    ├── config.json
    └── handlers.json
```

Generated Python files are stored in:

```text
generated/
└── <bot_name>.py
```

Example:

```text
bots/
└── 123456789/
    ├── config.json
    └── handlers.json

generated/
└── my_bot.py
```

The bot configuration contains the Telegram Bot Token so that a saved bot can be loaded again after restarting the application.

---

## 🔐 Security

Bot Tokens are sensitive credentials.

The `bots/` directory is excluded from Git through `.gitignore`.

Do not:

* Commit `bots/` to GitHub
* Share `config.json`
* Publish Bot Tokens
* Put real tokens inside source code
* Upload configuration files containing tokens publicly

If a Bot Token is accidentally exposed, revoke it through BotFather and generate a new token.

---

## 🖥️ CLI

The project also provides a basic CLI interface.

Example:

```bash
python -m telegram_bot_builder.cli \
    --name "Python Bot" \
    --trigger "python" \
    --response "You mentioned Python!"
```

The generated bot will be placed inside:

```text
generated/
```

---

## 🧱 Technologies

* Python
* Streamlit
* TeleBot / pyTelegramBotAPI
* JSON
* Git

---

## 📌 Current Scope

The current project focuses on:

```text
Telegram Bot
      │
      ├── Connect
      │
      ├── Configure
      │
      ├── Add Handlers
      │
      ├── Save Configuration
      │
      ├── Generate Python
      │
      └── Run Bot
```

The project intentionally keeps the architecture simple and local.

Features such as:

* Database
* Authentication
* Multi-user management
* Webhooks
* Background worker management
* Automatic bot recovery
* Docker
* Reverse proxy
* Cloud deployment

are outside the current scope.

---

## 📄 License

This project is licensed under the MIT License.
