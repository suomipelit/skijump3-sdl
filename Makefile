SDL2_HEADERS := Pascal-SDL-2-Headers
SDL2_HEADERS_REPO := https://github.com/ev1313/$(SDL2_HEADERS)
SDL2_HEADERS_DIR := ./$(SDL2_HEADERS)

SOURCE_DIR := ./SRC
SOURCE_FILE := $(SOURCE_DIR)/SJ3.PAS
OUTPUT := ./SJ3

COMPILER_OPTIONS := -Mtp -Fu$(SDL2_HEADERS_DIR) -FU$(SOURCE_DIR) -o$(OUTPUT)

.PHONY: all build run clean distclean
.PHONY: install-deps install-build-deps install-runtime-deps clone-headers

all: build

install-deps: install-build-deps install-runtime-deps

install-build-deps:
	sudo apt-get update
	sudo apt-get install -y fpc libsdl2-dev git
	$(MAKE) clone-headers

install-runtime-deps:
	sudo apt-get update
	sudo apt-get install -y libsdl2-2.0-0

clone-headers:
	@if [ ! -d "$(SDL2_HEADERS_DIR)" ]; then \
		git clone $(SDL2_HEADERS_REPO) $(SDL2_HEADERS_DIR); \
	fi

build:
	fpc $(COMPILER_OPTIONS) $(SOURCE_FILE)

run: build
	$(OUTPUT)

clean:
	rm -f $(OUTPUT) $(SOURCE_DIR)/*.o $(SOURCE_DIR)/*.ppu

distclean: clean
	rm -rf $(SDL2_HEADERS_DIR)
