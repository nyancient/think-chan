VERSION ?= 1.0
SRC_DIR := src
ASSETS_DIR := $(SRC_DIR)/assets
DEST_DIR := think-chan
DEST_ASSETS_DIR := $(DEST_DIR)/assets

ASSETS := $(shell find $(ASSETS_DIR) -name '*.png' | sort)
DEST_ASSETS := $(patsubst $(ASSETS_DIR)/%.png,$(DEST_ASSETS_DIR)/%.png,$(ASSETS))

.PHONY: all check clean

all: check think-chan-$(VERSION).tar.gz

check: think-chan
	@echo "[verify] $(DEST_DIR)"
	@./verify-model.sh $(DEST_DIR)/model.json $(DEST_ASSETS_DIR)

think-chan-$(VERSION).tar.gz: think-chan
	@echo "[tar]    $@"
	@tar -czf "$@" "$<"

think-chan: _dimensions $(SRC_DIR)/model.json $(DEST_ASSETS)
	@mkdir -p "$@"
	@echo "[copy]   $(SRC_DIR)/model.json"
	@cp -f $(SRC_DIR)/model.json $(DEST_DIR)/model.json

_dimensions: $(ASSETS)
	@echo "Computing sprite dimensions"
	@./find-dims.sh $(ASSETS_DIR) | tee "$@"

$(DEST_ASSETS_DIR)/%.png: $(ASSETS_DIR)/%.png _dimensions
	@echo "[magick] $<"
	@mkdir -p $(@D)
	@read final_canvas_width final_canvas_height < _dimensions ; \
	magick "$<" -resize "x$${final_canvas_height}" "$@" ; \
	magick "$@" -background transparent -gravity center -extent "$${final_canvas_width}x$${final_canvas_height}" "$@"

clean:
	rm -f think-chan-$(VERSION).tar.gz
	rm -rf think-chan
	rm -f _dimensions
