# Game Size Manager - Makefile
# Commands for development, building, and deployment

.PHONY: help run build-linux analyze gen clean install deck deck-setup deck-deploy deck-debug deck-logs deck-shell

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
	@echo "Steam Deck Remote Debug (via SSH):"
	@echo "  make deck         - Interactive menu (recommended)"
	@echo "  make deck-setup   - One-time: Setup SSH keys for Steam Deck"
	@echo "  make deck-deploy  - Build & deploy to Steam Deck"
	@echo "  make deck-debug   - Build, deploy & run with live debug logs"
	@echo "  make deck-run     - Deploy & run (no build)"
	@echo "  make deck-logs    - Stream logs from Steam Deck"
	@echo "  make deck-shell   - SSH into Steam Deck"
	@echo ""
	@echo "Installation (Steam Deck/Linux):"
	@echo "  make install      - Install app locally (run after build or from release)"
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

# ============================================
# Steam Deck Remote Deploy & Debug
# ============================================

# One-time setup: Generate and copy SSH keys
deck-setup:
	dart scripts/steamdeck_deploy.dart setup

# Build and deploy to Steam Deck
deck-deploy:
	dart scripts/steamdeck_deploy.dart deploy

# Full debug cycle: build, deploy, run with live logs
deck-debug:
	dart scripts/steamdeck_deploy.dart debug

# Quick deploy and run (skip build)
deck-run:
	dart scripts/steamdeck_deploy.dart run

# Stream logs from Steam Deck
deck-logs:
	dart scripts/steamdeck_deploy.dart logs

# SSH into Steam Deck
deck-shell:
	dart scripts/steamdeck_deploy.dart shell

# Interactive menu
deck:
	dart scripts/steamdeck_deploy.dart

# Clean build artifacts
clean:
	flutter clean
	rm -rf build/
	rm -rf .dart_tool/
	@echo "✅ Cleaned!"
