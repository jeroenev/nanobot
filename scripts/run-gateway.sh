#!/bin/bash
# Convenience script to run nanobot gateway with proper volume mounts

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Starting Nanobot Gateway ===${NC}"
echo ""

# Ensure data directories exist
mkdir -p ~/.nanobot/signal-data

# Run the gateway
echo -e "${GREEN}Starting nanobot gateway...${NC}"
docker run -d \
  --name nanobot-gateway \
  -v ~/.nanobot/nanobot:/root/.nanobot \
  -v ~/.nanobot/signal-data:/root/.local/share/signal-cli \
  -p 18790:18790 \
  nanobot gateway

echo ""
echo -e "${GREEN}Gateway started successfully!${NC}"
echo ""
echo "View logs with:"
echo "  docker logs -f nanobot-gateway"
echo ""
echo "Stop with:"
echo "  docker stop nanobot-gateway && docker rm nanobot-gateway"
