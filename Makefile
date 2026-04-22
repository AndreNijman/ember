# ember — Makefile
#
# Everything here is repo-local. No installs, no symlinks, no system
# services, no $HOME writes outside the repo. Targets:
#   build     — build the `aqs` Go binary into ./build/aqs
#   vet       — run `go vet ./...`
#   lint      — run qmllint against every .qml in qml/
#   smoke     — launch quickshell against qml/shell.qml for 30s,
#               capture to build/smoke.log
#   ipc-test  — spin the stub server and round-trip `aqs ipc status`
#   all       — build + vet + lint
#   clean     — rm -rf build/

REPO      := $(abspath $(CURDIR))
BUILD     := $(REPO)/build
AQS       := $(BUILD)/aqs
QML_DIR   := $(REPO)/qml
QML_FILES := $(shell find $(QML_DIR) -name '*.qml')
QS_LIB    := /usr/lib/qt6/qml
QMLLINT   := qmllint
GO        ?= go

.PHONY: all build vet lint smoke ipc-test clean

all: build vet lint

build:
	@mkdir -p $(BUILD)
	$(GO) build -o $(AQS) ./cmd/aqs
	@echo "built $(AQS)"

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

clean:
	rm -rf $(BUILD)
