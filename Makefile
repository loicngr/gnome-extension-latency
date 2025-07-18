# Makefile for GNOME Shell Latency Extension

# Extension metadata
EXTENSION_UUID = latency@mboscovich.github.io
EXTENSION_NAME = latency

# Directories
SCHEMAS_DIR = schemas
INSTALL_DIR = $(HOME)/.local/share/gnome-shell/extensions/$(EXTENSION_UUID)

# Files to include in the extension
EXTENSION_FILES = extension.js metadata.json prefs.js show-ping-time.sh LICENSE README.md
SCHEMA_FILES = $(SCHEMAS_DIR)/org.gnome.shell.extensions.latency.gschema.xml
COMPILED_SCHEMA = $(SCHEMAS_DIR)/gschemas.compiled

.PHONY: help build install uninstall clean

# Default target
all: build

help:
	@echo "Available targets:"
	@echo "  build      - Compile schemas and prepare the extension"
	@echo "  install    - Install the extension to user directory"
	@echo "  uninstall  - Remove the extension from user directory"
	@echo "  clean      - Clean build artifacts"
	@echo "  help       - Show this help message"

build: $(COMPILED_SCHEMA)
	@echo "Building extension..."
	@chmod +x show-ping-time.sh
	@echo "Extension built successfully!"

$(COMPILED_SCHEMA): $(SCHEMA_FILES)
	@echo "Compiling GSettings schemas..."
	@glib-compile-schemas $(SCHEMAS_DIR)/
	@echo "Schemas compiled successfully!"

install: build
	@echo "Installing extension to $(INSTALL_DIR)..."
	@mkdir -p $(INSTALL_DIR)
	@mkdir -p $(INSTALL_DIR)/$(SCHEMAS_DIR)
	@cp $(EXTENSION_FILES) $(INSTALL_DIR)/
	@cp $(SCHEMA_FILES) $(INSTALL_DIR)/$(SCHEMAS_DIR)/
	@cp $(COMPILED_SCHEMA) $(INSTALL_DIR)/$(SCHEMAS_DIR)/
	@echo "Extension installed successfully!"
	@echo ""
	@echo "To enable the extension:"
	@echo "1. Restart GNOME Shell (Alt+F2, type 'r', press Enter on X11)"
	@echo "2. Enable the extension: gnome-extensions enable $(EXTENSION_UUID)"

uninstall:
	@echo "Uninstalling extension..."
	@if [ -d "$(INSTALL_DIR)" ]; then \
		rm -rf "$(INSTALL_DIR)"; \
		echo "Extension uninstalled successfully!"; \
	else \
		echo "Extension not found in $(INSTALL_DIR)"; \
	fi

clean:
	@echo "Cleaning build artifacts..."
	@rm -f $(COMPILED_SCHEMA)
	@echo "Clean completed!"

# Check if required tools are available
check-deps:
	@echo "Checking dependencies..."
	@command -v glib-compile-schemas >/dev/null 2>&1 || { echo "Error: glib-compile-schemas not found. Please install glib development packages."; exit 1; }
	@command -v ping >/dev/null 2>&1 || { echo "Error: ping command not found."; exit 1; }
	@command -v host >/dev/null 2>&1 || { echo "Error: host command not found."; exit 1; }
	@echo "All dependencies are available!"

# Development target to check the extension structure
check:
	@echo "Checking extension structure..."
	@for file in $(EXTENSION_FILES); do \
		if [ ! -f "$$file" ]; then \
			echo "Warning: $$file not found"; \
		fi; \
	done
	@for file in $(SCHEMA_FILES); do \
		if [ ! -f "$$file" ]; then \
			echo "Error: $$file not found"; \
			exit 1; \
		fi; \
	done
	@echo "Extension structure check completed!"
