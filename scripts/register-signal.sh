#!/bin/bash
# Signal registration helper script for nanobot Docker setup
# Automates the Signal CLI registration process with proper volume persistence

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Nanobot Signal Registration Helper ===${NC}"
echo ""

# Get phone number
read -p "Enter your phone number (e.g., +32483541994): " PHONE_NUMBER

if [[ ! "$PHONE_NUMBER" =~ ^\+[0-9]+$ ]]; then
    echo -e "${RED}Error: Phone number must start with + and contain only digits${NC}"
    exit 1
fi

# Ensure data directory exists
mkdir -p ~/.nanobot/signal-data

echo ""
echo -e "${GREEN}Step 1: Starting registration...${NC}"
echo "This will request a verification code via SMS."
echo ""

# Start registration
if docker run -it \
    -v ~/.nanobot/nanobot:/root/.nanobot \
    -v ~/.nanobot/signal-data:/root/.local/share/signal-cli \
    --entrypoint signal-cli --rm nanobot \
    -a "$PHONE_NUMBER" register 2>&1; then
    echo -e "${GREEN}Registration initiated successfully!${NC}"
else
    echo -e "${YELLOW}Registration may have returned an error (possibly captcha required).${NC}"
fi

echo ""
echo -e "${BLUE}Step 2: Captcha Verification${NC}"
echo "If prompted for a captcha above, you need to complete it."
echo ""
echo "To get the captcha token:"
echo "  1. Visit: https://signalcaptchas.org/registration/generate.html"
echo "  2. Solve the captcha"
echo "  3. Right-click the 'Open Signal' link and copy the link"
echo "  4. Extract the token (starts with 'signalcaptcha://')"
echo ""

read -p "Enter the captcha token (or press Enter to skip if not needed): " CAPTCHA_TOKEN

if [ -n "$CAPTCHA_TOKEN" ]; then
    echo ""
    echo -e "${GREEN}Confirming captcha...${NC}"

    docker run -it \
        -v ~/.nanobot/nanobot:/root/.nanobot \
        -v ~/.nanobot/signal-data:/root/.local/share/signal-cli \
        --entrypoint signal-cli --rm nanobot \
        -a "$PHONE_NUMBER" register --captcha "$CAPTCHA_TOKEN"
fi

echo ""
echo -e "${BLUE}Step 3: SMS Verification${NC}"
read -p "Enter the verification code received via SMS: " VERIFY_CODE

if [[ ! "$VERIFY_CODE" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Error: Verification code must contain only digits${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Verifying code...${NC}"

if docker run -it \
    -v ~/.nanobot/nanobot:/root/.nanobot \
    -v ~/.nanobot/signal-data:/root/.local/share/signal-cli \
    --entrypoint signal-cli --rm nanobot \
    -a "$PHONE_NUMBER" verify "$VERIFY_CODE"; then

    echo ""
    echo -e "${GREEN}=== Signal registration completed successfully! ===${NC}"
    echo ""
    echo "You can now run nanobot with:"
    echo "  docker run -d -v ~/.nanobot/nanobot:/root/.nanobot nanobot gateway"
    echo ""
else
    echo ""
    echo -e "${RED}Verification failed. Please check the code and try again.${NC}"
    exit 1
fi
