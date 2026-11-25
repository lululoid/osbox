INSTALL_BIN    := $(HOME)/.local/bin
INSTALL_SHARE  := $(HOME)/.local/share/osbox
INSTALL_CONFIG := $(HOME)/.config/osbox
BUILD_DIR      := build
DIST_DIR       := dist
PYI            := pyinstaller --onefile --clean

SCRIPTS := osbox-build osbox

.PHONY: all install uninstall clean

all: install

$(INSTALL_BIN) $(INSTALL_SHARE) $(INSTALL_CONFIG):
	mkdir -p $@

install: $(addprefix $(DIST_DIR)/,$(SCRIPTS))
	install -d $(INSTALL_BIN) $(INSTALL_SHARE) $(INSTALL_CONFIG)
	install -m 755 $(addprefix $(DIST_DIR)/,$(SCRIPTS)) -t $(INSTALL_BIN)/
	cp -r scripts $(INSTALL_SHARE)/
	cp -r recipes  $(INSTALL_CONFIG)/

$(DIST_DIR)/%: bin/%
	$(PYI) --name $* --distpath $(DIST_DIR) --workpath $(BUILD_DIR) $<

clean:
	rm -rf $(BUILD_DIR) $(DIST_DIR)

uninstall:
	rm -f $(addprefix $(INSTALL_BIN)/,$(SCRIPTS))
	rm -rf $(INSTALL_SHARE)
