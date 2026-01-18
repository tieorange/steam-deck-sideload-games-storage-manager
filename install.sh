#!/bin/bash

# Configuration
REPO="tieorange/steam-deck-sideload-games-storage-manager"
APP_NAME="GameSizeManager"
INSTALL_DIR="$HOME/Applications/$APP_NAME"
EXECUTABLE_NAME="steam-deck-sideload-games-storage-manager"
DESKTOP_FILE="$HOME/.local/share/applications/game-size-manager.desktop"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Installing $APP_NAME...${NC}"

# 1. Create install directory
echo "Creating installation directory: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

# 2. Get latest release URL
echo "Fetching latest release info..."
LATEST_URL=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep "browser_download_url.*zip" | cut -d : -f 2,3 | tr -d \")

if [ -z "$LATEST_URL" ]; then
    echo -e "${RED}Error: Could not find latest release asset.${NC}"
    echo "Please check if a release exists at https://github.com/$REPO/releases"
    exit 1
fi

echo "Downloading from: $LATEST_URL"

# 3. Download and extract
curl -L -o /tmp/game-manager.zip "$LATEST_URL"
unzip -o /tmp/game-manager.zip -d "$INSTALL_DIR"
rm /tmp/game-manager.zip

# 4. Make executable
chmod +x "$INSTALL_DIR/$EXECUTABLE_NAME"

# 5. Create Desktop Entry
echo "Creating desktop entry..."
cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=Game Size Manager
Comment=Manage storage for sideloaded games
Exec=$INSTALL_DIR/$EXECUTABLE_NAME
Icon=$INSTALL_DIR/data/flutter_assets/assets/images/app_icon.png
Terminal=false
Type=Application
Categories=Utility;Game;
EOF

# Note: Icon path might need adjustment depending on where Flutter puts assets in release bundle
# Usually it is data/flutter_assets/...

echo -e "${GREEN}Installation complete!${NC}"
echo -e "You can find the app in your Applications menu or run it from:"
echo -e "$INSTALL_DIR/$EXECUTABLE_NAME"
