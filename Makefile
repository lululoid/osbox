INSTALL_BIN    := $(HOME)/.local/bin
INSTALL_SHARE  := $(HOME)/.local/share/osbox
INSTALL_CONFIG := $(HOME)/.config/osbox
BUILD_DIR      := build
DIST_DIR       := dist
PYI            := pyinstaller --onefile --clean

SCRIPTS := osbox-build osbox

.PHONY: all install clean

all: install

$(INSTALL_BIN) $(INSTALL_SHARE) $(INSTALL_CONFIG):
	mkdir -p $@

install: $(INSTALL_BIN) $(INSTALL_SHARE) $(INSTALL_CONFIG) $(addprefix $(DIST_DIR)/,$(SCRIPTS))
	cp $(addprefix $(DIST_DIR)/,$(SCRIPTS)) $(INSTALL_BIN)/
	cp -rf scripts $(INSTALL_SHARE)/
	cp -rf recipe  $(INSTALL_CONFIG)/
	chmod +x $(INSTALL_BIN)/osbox $(INSTALL_BIN)/osbox-build

$(DIST_DIR)/%: bin/%
	$(PYI) --name $* --distpath $(DIST_DIR) --workpath $(BUILD_DIR) $<

clean:
	rm -rf $(BUILD_DIR) $(DIST_DIR)   
