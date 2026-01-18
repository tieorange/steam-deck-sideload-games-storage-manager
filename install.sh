#!/bin/bash

# Configuration
REPO="tieorange/steam-deck-sideload-games-storage-manager"
APP_NAME="GameSizeManager"
INSTALL_DIR="$HOME/Applications/$APP_NAME"
EXECUTABLE_NAME="game_size_manager"
DESKTOP_FILE="$HOME/.local/share/applications/game-size-manager.desktop"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Installing $APP_NAME...${NC}"

# Check dependencies
if ! command -v curl &> /dev/null; then
    echo -e "${RED}Error: curl is required but not installed.${NC}"
    exit 1
fi
if ! command -v unzip &> /dev/null; then
    echo -e "${RED}Error: unzip is required but not installed.${NC}"
    exit 1
fi

# 1. Create install directory
echo "Creating installation directory: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

# 2. Get latest release URL
echo "Fetching latest release info..."
# Matches: https://...linux.zip
LATEST_URL=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep -o 'https://[^"]*linux.zip' | head -n 1)

if [ -z "$LATEST_URL" ]; then
    echo -e "${RED}Error: Could not find latest release asset ending in 'linux.zip'.${NC}"
    echo "Please check if a release exists at https://github.com/$REPO/releases"
    exit 1
fi

echo "Downloading from: $LATEST_URL"

# 3. Download and extract
TEMP_ZIP="/tmp/game-manager.zip"
TEMP_DIR="/tmp/game-manager-extracted"

curl -L -o "$TEMP_ZIP" "$LATEST_URL"

if [ ! -f "$TEMP_ZIP" ]; then
   echo -e "${RED}Error: Download failed.${NC}"
   exit 1
fi

echo "Extracting..."
rm -rf "$TEMP_DIR"
unzip -o "$TEMP_ZIP" -d "$TEMP_DIR" > /dev/null

# 4. Install files
echo "Installing files to $INSTALL_DIR..."
# Check for nested directory (steam-deck-release) as seen in artifacts
if [ -d "$TEMP_DIR/steam-deck-release" ]; then
    cp -r "$TEMP_DIR/steam-deck-release/"* "$INSTALL_DIR/"
else
    # Fallback if structure changes (flat structure)
    cp -r "$TEMP_DIR/"* "$INSTALL_DIR/"
fi

# Cleanup
rm "$TEMP_ZIP"
rm -rf "$TEMP_DIR"

# 5. Make executable
if [ -f "$INSTALL_DIR/$EXECUTABLE_NAME" ]; then
    chmod +x "$INSTALL_DIR/$EXECUTABLE_NAME"
else
    echo -e "${RED}Error: Executable not found at $INSTALL_DIR/$EXECUTABLE_NAME${NC}"
    echo "Contents of $INSTALL_DIR:"
    ls -l "$INSTALL_DIR"
    exit 1
fi

# 6. Create Desktop Entry
echo "Creating desktop entry..."
# Note: Icon path might need adjustment depending on where Flutter puts assets in release bundle
# Try to find a valid icon or default to empty (system default)
ICON_PATH="$INSTALL_DIR/data/flutter_assets/assets/images/app_icon.png"

cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=Game Size Manager
Comment=Manage storage for sideloaded games
Exec=$INSTALL_DIR/$EXECUTABLE_NAME
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Utility;Game;
EOF

echo -e "${GREEN}Installation complete!${NC}"
echo -e "You can find the app in your Applications menu or run it from:"
echo -e "$INSTALL_DIR/$EXECUTABLE_NAME"
