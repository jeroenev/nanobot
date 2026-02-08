# Docker
Installs Homebrew, signal-cli, and nanobot in a Docker container.
## Configure Nanobot
Edit ~/.nanobot/config.json and set the following values:
```json
"signal": {
  "enabled": true,
  "phoneNumber": "+32xxxxxxxxx", # Phone Number of the Signal account for the Bot
  "cliBinary": "signal-cli",
  "allowFrom": [
    "+32475563671" # Phone Number of the Signal account of the user that is allowed to send commands to the bot
  ]
}
```
+ add API-keys for the providers you want to use (e.g. OpenAI, Gemini, etc.)

## Setup Signal
### Start registration
**Note:** Signal-cli stores registration state in a separate data directory that must be persisted between commands.
```bash
docker run -it \
  -v ~/.nanobot:/home/linuxbrew/.nanobot \
  -v ~/.nanobot/signal-data:/home/linuxbrew/.local/share/signal-cli \
  --entrypoint signal-cli --rm nanobot \
  -a "+32xxxxxxxxx" register
```
### Confirm Captcha
```bash
docker run -it \
  -v ~/.nanobot:/home/linuxbrew/.nanobot \
  -v ~/.nanobot/signal-data:/home/linuxbrew/.local/share/signal-cli \
  --entrypoint signal-cli --rm nanobot \
  -a "+32xxxxxxxxx" register --captcha signalcaptcha://...
```
### Verify with SMS code
```bash
docker run -it \
  -v ~/.nanobot:/home/linuxbrew/.nanobot \
  -v ~/.nanobot/signal-data:/home/linuxbrew/.local/share/signal-cli \
  --entrypoint signal-cli --rm nanobot \
  -a "+32xxxxxxxxx" verify 123456
```

## Alternative: Automated Registration Script
For a guided, interactive experience that automates all the steps above:
```bash
chmod +x scripts/register-signal.sh
./scripts/register-signal.sh
```
This script will:
1. Prompt for your phone number
2. Start the registration process
3. Guide you through captcha completion (if required)
4. Prompt for and verify the SMS code

## Run Nanobot
**Important:** Include the signal-cli data volume so the registration persists:
```bash
docker run -d \
  -v ~/.nanobot:/home/linuxbrew/.nanobot \
  -v ~/.nanobot/signal-data:/home/linuxbrew/.local/share/signal-cli \
  nanobot gateway
```

Or use the provided convenience script:
```bash
./scripts/run-gateway.sh
```