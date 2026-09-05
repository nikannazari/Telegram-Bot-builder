# 🤖 Telegram Bot Builder

A modular Telegram Bot Builder built with **Python**, **Streamlit**, and **TeleBot (pyTelegramBotAPI)**.

The project allows you to configure a Telegram bot through a graphical interface and generate the corresponding Python source code automatically.

## ✨ Features

* Create bot configuration
* Configure bot name and username
* Secure bot token input
* Add Telegram handlers from Streamlit
* Text handlers
* Command handlers
* Contains-text handlers
* Default handler
* Generate a complete Python Telegram bot
* Preview generated source code
* Download generated `.py` files
* Start and stop the bot from Streamlit
* TeleBot-based Telegram integration
* Modular project architecture

## 🏗️ Architecture

```text
Streamlit UI
     │
     ▼
BotConfig
     │
     ├── Bot Name
     ├── Bot Username
     ├── Bot Token
     │
     └── HandlerConfig[]
              │
              ▼
        BotGenerator
              │
              ▼
       generated/*.py
              │
              ▼
          TeleBot
              │
              ▼
          Telegram
```

## 📁 Project Structure

```text
Telegram-Bot-Builder/
├── main.py
├── app/
│   └── streamlit_app.py
├── assets/
├── bots/
│   └── .gitkeep
├── generated/
│   └── .gitkeep
├── src/
│   └── telegram_bot_builder/
│       ├── __init__.py
│       ├── cli.py
│       ├── core/
│       │   ├── __init__.py
│       │   ├── bot.py
│       │   └── handler.py
│       ├── services/
│       │   ├── __init__.py
│       │   ├── telegram.py
│       │   └── generator.py
│       └── utils/
│           ├── __init__.py
│           └── validators.py
├── .gitignore
├── LICENSE
├── README.md
├── pyproject.toml
└── requirements.txt
```

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

## 🤖 Creating a Telegram Bot

Telegram bot accounts are created through **BotFather**.

After creating your bot, BotFather provides a bot token.

Keep this token secret.

Do not commit it to Git or place it directly inside generated source code.

## ▶️ Run the Application

Start the launcher:

```bash
python main.py
```

Then select:

```text
1. Start Streamlit
```

Alternatively:

```bash
streamlit run app/streamlit_app.py
```

## 🧩 Creating a Handler

For example:

```text
Handler Type: Text

Trigger:
python

Response:
You mentioned Python!
```

The builder generates:

```python
@bot.message_handler(
    func=lambda message: message.text == "python"
)
def handle_python(message):
    bot.reply_to(message, "You mentioned Python!")
```

## 📜 Generated Bot

The generated bot is saved inside:

```text
generated/
```

For example:

```text
generated/
└── python_bot.py
```

The generated source uses an environment variable for the bot token:

```python
BOT_TOKEN = os.getenv("BOT_TOKEN")
```

This prevents the token from being embedded directly into generated source code.

## 🔐 Security

Bot tokens are credentials.

Never:

* Commit bot tokens to Git
* Put tokens inside README files
* Share tokens publicly
* Hard-code tokens into source code
* Store tokens inside generated files

If a token is accidentally exposed, revoke it through BotFather and generate a new one.

## 🛠️ Technologies

* Python
* Streamlit
* TeleBot / pyTelegramBotAPI
* Dataclasses
* Threading
* pathlib

## 📌 Current Scope

The current version focuses on the core bot-building workflow:

```text
Bot Configuration
       ↓
Handler Configuration
       ↓
Python Code Generation
       ↓
TeleBot Execution
```

Database persistence, authentication, webhooks, deployment management, and multi-user support are intentionally outside the current scope.

## 📄 License

This project is licensed under the MIT License.
