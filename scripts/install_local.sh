#!/bin/bash
# Steam Deck Local Installation Script
# Run this on your Steam Deck to install the app

set -e

APP_NAME="GameSizeManager"
INSTALL_DIR="$HOME/Applications/$APP_NAME"
DESKTOP_FILE="$HOME/.local/share/applications/$APP_NAME.desktop"

echo "🎮 Installing $APP_NAME..."
echo ""

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Check if we're running from the bundle directory
if [ -f "./game_size_manager" ]; then
    echo "📦 Installing from current directory..."
    cp -r ./* "$INSTALL_DIR/"
elif [ -d "../build/linux/x64/release/bundle" ]; then
    echo "📦 Installing from build directory..."
    cp -r ../build/linux/x64/release/bundle/* "$INSTALL_DIR/"
else
    echo "❌ Could not find app bundle. Please run from the bundle directory or project root."
    exit 1
fi

# Make executable
chmod +x "$INSTALL_DIR/game_size_manager"

echo "✅ Installed to: $INSTALL_DIR"
echo ""

# Create desktop shortcut
echo "📝 Creating desktop shortcut..."
mkdir -p "$(dirname "$DESKTOP_FILE")"

cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=Game Size Manager
Comment=Manage game storage across launchers
Exec=$INSTALL_DIR/game_size_manager
Icon=$INSTALL_DIR/data/flutter_assets/assets/icon.png
Terminal=false
Type=Application
Categories=Game;Utility;
StartupWMClass=game_size_manager
EOF

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$HOME/.local/share/applications"
fi

echo "✅ Desktop shortcut created"
echo ""
echo "🎉 Installation complete!"
echo ""
echo "You can now:"
echo "  1. Launch from your application menu"
echo "  2. Add to Steam as a non-Steam game for Gaming Mode access"
echo ""
echo "To add to Steam Gaming Mode:"
echo "  1. Open Steam > Library > Add a Game > Add a Non-Steam Game"
echo "  2. Browse to: $INSTALL_DIR/game_size_manager"
echo "  3. Add Selected Programs"
