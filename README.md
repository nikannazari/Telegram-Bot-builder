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
* Local development runner
* Linux installer and uninstaller
* Windows installer and uninstaller
* Global terminal command after installation

---

## 🏗️ Project Structure

```text
Telegram-Bot-Builder/
│
├── main.py
│
├── run.sh
├── install.sh
├── uninstall.sh
│
├── run.bat
├── install.bat
├── uninstall.bat
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

### 1. Clone the Repository

```bash
git clone <repository-url>
cd Telegram-Bot-Builder
```

### 2. Create a Virtual Environment

```bash
python -m venv .venv
```

### 3. Activate the Virtual Environment

#### Linux

```bash
source .venv/bin/activate
```

#### Windows CMD

```cmd
.venv\Scripts\activate.bat
```

#### Windows PowerShell

```powershell
.venv\Scripts\Activate.ps1
```

### 4. Install Dependencies

```bash
pip install -r requirements.txt
```

---

## ▶️ Running the Application

### Using Python

The application can be started with:

```bash
python main.py
```

Then select:

```text
1. Start Streamlit
```

### Using Streamlit Directly

```bash
streamlit run app/streamlit_app.py
```

---

## 🧪 Local Development Runner

The project includes separate development runners for Linux and Windows.

These runners:

1. Detect the project directory.
2. Create a local `.venv` if it does not exist.
3. Install dependencies from `requirements.txt`.
4. Run the Streamlit application.
5. Do not install the application system-wide.

---

### Linux Development Runner

File:

```text
run.sh
```

Make it executable:

```bash
chmod +x run.sh
```

Run the application:

```bash
./run.sh
```

The runner performs the equivalent of:

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
python -m streamlit run app/streamlit_app.py
```

---

### Windows Development Runner

File:

```text
run.bat
```

Run it from CMD:

```cmd
run.bat
```

You can also double-click `run.bat` from File Explorer.

The Windows runner performs the equivalent of:

```cmd
python -m venv .venv
.venv\Scripts\python.exe -m pip install -r requirements.txt
.venv\Scripts\python.exe -m streamlit run app\streamlit_app.py
```

---

## 📦 Linux Installation

The Linux installer installs the application as a system-wide command.

### Install

Make the installer executable:

```bash
chmod +x install.sh
```

Run:

```bash
./install.sh
```

The installer copies the application source code to:

```text
/opt/Telegram-Bot-Builder/
```

It creates the application virtual environment at:

```text
/opt/Telegram-Bot-Builder/.venv/
```

It also creates the global command:

```text
/usr/bin/Telegram-Bot-Builder
```

After installation, run the application from any directory:

```bash
Telegram-Bot-Builder
```

The installed command executes:

```text
/opt/Telegram-Bot-Builder/app/streamlit_app.py
```

using:

```text
/opt/Telegram-Bot-Builder/.venv/bin/python
```

### Linux Installation Layout

```text
/opt/Telegram-Bot-Builder/
├── main.py
├── app/
│   └── streamlit_app.py
├── src/
├── assets/
├── bots/
├── generated/
├── requirements.txt
└── .venv/

/usr/bin/Telegram-Bot-Builder
```

### Uninstall on Linux

Run:

```bash
chmod +x uninstall.sh
./uninstall.sh
```

The uninstaller removes:

```text
/opt/Telegram-Bot-Builder/
```

and:

```text
/usr/bin/Telegram-Bot-Builder
```

> The installed `bots/` and `generated/` directories are also removed during uninstallation. Back up important bot configurations before uninstalling.

---

## 📦 Windows Installation

The Windows installer installs the application inside the current user's local application directory.

### Install

Run:

```cmd
install.bat
```

You can also double-click `install.bat`.

The installer copies the application source code to:

```text
%LOCALAPPDATA%\Telegram-Bot-Builder\
```

The virtual environment is created at:

```text
%LOCALAPPDATA%\Telegram-Bot-Builder\.venv\
```

The installer also creates a command file at:

```text
%LOCALAPPDATA%\Microsoft\WindowsApps\Telegram-Bot-Builder.bat
```

After installation, open a new CMD or PowerShell window and run:

```cmd
Telegram-Bot-Builder
```

### Windows Installation Layout

```text
%LOCALAPPDATA%\Telegram-Bot-Builder/
├── main.py
├── app/
│   └── streamlit_app.py
├── src/
├── assets/
├── bots/
├── generated/
├── requirements.txt
└── .venv/

%LOCALAPPDATA%\Microsoft\WindowsApps\
└── Telegram-Bot-Builder.bat
```

### Uninstall on Windows

Run:

```cmd
uninstall.bat
```

You can also double-click `uninstall.bat`.

The uninstaller removes:

```text
%LOCALAPPDATA%\Telegram-Bot-Builder\
```

and:

```text
%LOCALAPPDATA%\Microsoft\WindowsApps\Telegram-Bot-Builder.bat
```

> The installed `bots/` and `generated/` directories are also removed during uninstallation. Back up important bot configurations before uninstalling.

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

During development, bot configurations are stored inside the project:

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

When the application is installed, these directories are copied to the installation directory.

### Linux

```text
/opt/Telegram-Bot-Builder/bots/
/opt/Telegram-Bot-Builder/generated/
```

### Windows

```text
%LOCALAPPDATA%\Telegram-Bot-Builder\bots\
%LOCALAPPDATA%\Telegram-Bot-Builder\generated\
```

The bot configuration contains the Telegram Bot Token so that a saved bot can be loaded again after restarting the application.

---

## 🔐 Security

Bot Tokens are sensitive credentials.

The `bots/` directory should be excluded from Git through `.gitignore`.

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
* Bash
* Windows Batch
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
