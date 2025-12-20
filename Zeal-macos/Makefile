APP_NAME = Zeal
SCHEME = Zeal
CONFIG = Release
BUILD_DIR = ./build
APP_PATH = $(BUILD_DIR)/Build/Products/$(CONFIG)/$(APP_NAME).app
BINARY_PATH = $(APP_PATH)/Contents/MacOS/$(APP_NAME)

.PHONY: all build run debug clean test

all: build

build:
	@echo "Building $(APP_NAME)..."
	@xcodebuild -scheme $(SCHEME) \
		-configuration $(CONFIG) \
		-destination 'platform=macOS' \
		-derivedDataPath $(BUILD_DIR) \
		clean build \
		| grep -E "(^Compile|^Link|^Sign|^Touch|error:|warning:|\*\* BUILD)" \
		| sed -E 's/.*\((in target.*)\)/\1/'
	@echo "\nDone! App located at:\n  $(APP_PATH)"

run: close build
	@echo "Opening $(APP_NAME)..."
	@open "$(APP_PATH)"

debug: close build
	@echo "Starting $(APP_NAME) in debug mode..."
	@echo "Press Ctrl+C to stop."
	@echo "----------------------------------------"
	@$(BINARY_PATH)

close:
	@echo "Closing $(APP_NAME)..."
	@killall $(APP_NAME) 2>/dev/null || echo "$(APP_NAME) is not running."

clean:
	@rm -rf $(BUILD_DIR)
	@echo "Cleaned build directory."

test:
	@./test-api.sh
