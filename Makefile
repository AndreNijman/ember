# ember — Makefile
#
# Targets:
#   build      — build aqs + aqs-greeter into ./build/
#   vet        — go vet ./...
#   lint       — qmllint over qml/
#   smoke      — run quickshell against shell.qml for 30s
#   ipc-test   — round-trip aqs ipc against stub
#   install    — install binaries, qml, systemd unit, manpage
#   uninstall  — remove the files put down by `install`
#   man        — render docs/aqs.1.scd into build/aqs.1
#   all        — build + vet + lint
#   clean      — rm -rf build/

REPO       := $(abspath $(CURDIR))
BUILD      := $(REPO)/build
AQS        := $(BUILD)/aqs
GREETER    := $(BUILD)/aqs-greeter
QML_DIR    := $(REPO)/qml
QML_FILES  := $(shell find $(QML_DIR) -name '*.qml')
QS_LIB     := /usr/lib/qt6/qml
QMLLINT    := qmllint
GO         ?= go
SCDOC      ?= scdoc

PREFIX     ?= /usr/local
DESTDIR    ?=
BINDIR     := $(DESTDIR)$(PREFIX)/bin
DATADIR    := $(DESTDIR)$(PREFIX)/share
LIBDIR     := $(DESTDIR)$(PREFIX)/lib
MANDIR     := $(DATADIR)/man/man1

# Inject git tag at build time so `aqs ipc shell version` reports the
# real release. Falls back to "v0.0.0-dev" when not in a git checkout.
VERSION    := $(shell git -C $(REPO) describe --tags --always --dirty 2>/dev/null || echo v0.0.0-dev)
LDFLAGS    := -X main.version=$(VERSION)

.PHONY: all build vet lint smoke ipc-test man install uninstall clean

all: build vet lint

build:
	@mkdir -p $(BUILD)
	$(GO) build -ldflags "$(LDFLAGS)" -o $(AQS)     ./cmd/aqs
	$(GO) build -ldflags "$(LDFLAGS)" -o $(GREETER) ./cmd/aqs-greeter
	@echo "built $(AQS)"
	@echo "built $(GREETER)"

vet:
	$(GO) vet ./...

lint:
	@test -n "$(QML_FILES)" || { echo "no qml files"; exit 1; }
	@set -e; for f in $(QML_FILES); do \
	    echo "  lint $$f"; \
	    $(QMLLINT) -I $(QML_DIR) -I $(QS_LIB) "$$f" || exit 1; \
	done

smoke: build
	@mkdir -p $(BUILD)
	@PATH=$(BUILD):$$PATH bash scripts/smoke.sh $(BUILD)/smoke.log

ipc-test: build
	@mkdir -p $(BUILD)
	@bash scripts/ipc-roundtrip.sh $(AQS) $(BUILD)/ipc-roundtrip.log

man: $(BUILD)/aqs.1

$(BUILD)/aqs.1: docs/aqs.1.scd
	@mkdir -p $(BUILD)
	$(SCDOC) < docs/aqs.1.scd > $@

install: build man
	@echo "installing to $(PREFIX)"
	install -Dm755 $(AQS)     $(BINDIR)/aqs
	install -Dm755 $(GREETER) $(BINDIR)/aqs-greeter
	# Shell QML tree
	install -d $(DATADIR)/aqs
	cp -a qml $(DATADIR)/aqs/
	# Greeter QML + Theme tree
	install -Dm644 qml/greeter.qml          $(DATADIR)/aqs-greeter/greeter.qml
	install -Dm644 qml/Theme/Theme.qml      $(DATADIR)/aqs-greeter/Theme/Theme.qml
	install -Dm644 qml/Theme/Tokens.qml     $(DATADIR)/aqs-greeter/Theme/Tokens.qml
	install -Dm644 qml/Theme/Fonts.qml      $(DATADIR)/aqs-greeter/Theme/Fonts.qml
	install -Dm644 qml/Theme/qmldir         $(DATADIR)/aqs-greeter/Theme/qmldir
	# Starter Hyprland config (users copy into ~/.config/hypr/)
	install -Dm644 contrib/hypr/hyprland.conf.example  $(DATADIR)/aqs/contrib/hypr/hyprland.conf.example
	install -Dm644 contrib/hypr/aqs/binds.conf         $(DATADIR)/aqs/contrib/hypr/aqs/binds.conf
	# greetd example
	install -Dm644 contrib/greetd/config.toml.example  $(DATADIR)/aqs/contrib/greetd/config.toml.example
	# Greeter installer script
	install -Dm755 scripts/install-greeter.sh          $(DATADIR)/aqs/scripts/install-greeter.sh
	# Systemd user unit
	install -Dm644 contrib/systemd/aqs.service         $(LIBDIR)/systemd/user/aqs.service
	# Manpage
	install -Dm644 $(BUILD)/aqs.1                      $(MANDIR)/aqs.1

uninstall:
	rm -f  $(BINDIR)/aqs $(BINDIR)/aqs-greeter
	rm -rf $(DATADIR)/aqs $(DATADIR)/aqs-greeter
	rm -f  $(LIBDIR)/systemd/user/aqs.service
	rm -f  $(MANDIR)/aqs.1

clean:
	rm -rf $(BUILD)
