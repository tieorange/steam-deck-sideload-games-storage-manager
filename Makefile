# Game Size Manager - Makefile
# Commands for development, building, and deployment

.PHONY: help run build-linux analyze gen clean install

# Default target
help:
	@echo "🎮 Game Size Manager - Available Commands"
	@echo "=========================================="
	@echo ""
	@echo "Development:"
	@echo "  make run          - Run the app on macOS"
	@echo "  make analyze      - Run Flutter analyzer"
	@echo "  make gen          - Generate freezed/json_serializable code"
	@echo ""
	@echo "Building:"
	@echo "  make build-linux  - Build Linux release using Docker (M-chip compatible)"
	@echo ""
	@echo "Installation (Steam Deck/Linux):"
	@echo "  make install      - Install app locally (run after build or from release)"
	@echo ""
	@echo "Deployment:"
	@echo "  make deploy       - Deploy to Steam Deck via SSH"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean        - Clean build artifacts"

# Run the app on macOS
run:
	flutter run -d macos

# Run Flutter analyzer
analyze:
	flutter analyze

# Generate code (freezed, json_serializable)
gen:
	dart run build_runner build --delete-conflicting-outputs

# Watch for changes and regenerate
watch:
	dart run build_runner watch --delete-conflicting-outputs

# Build Linux release using Docker (for M-chip Macs)
build-linux:
	@echo "🐧 Building Linux release..."
	@if [ -f "./build_linux_on_mac.sh" ]; then \
		./build_linux_on_mac.sh; \
	else \
		echo "Docker build script not found. Running direct build..."; \
		flutter build linux --release; \
	fi

# Install app locally (for Steam Deck/Linux)
install:
	@echo "📦 Installing app locally..."
	./scripts/install_local.sh

# Deploy to Steam Deck
deploy:
	@echo "🚀 Deploying to Steam Deck..."
	@read -p "Enter Steam Deck IP or hostname (e.g., steamdeck.local): " DECK_HOST; \
	scp -r build/linux/x64/release/bundle/* deck@$$DECK_HOST:~/Applications/GameSizeManager/

# Clean build artifacts
clean:
	flutter clean
	rm -rf build/
	rm -rf .dart_tool/
	@echo "✅ Cleaned!"
