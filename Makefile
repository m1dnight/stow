SERVICE_FILES := $(wildcard Library/LaunchAgents/*.plist)
SERVICE_DIR := $(HOME)/Library/LaunchAgents
.PHONY: services copy_services

UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Darwin)
    # Mac-specific settings
    GIT_CONFIG = .gitconfig-mac
    OPEN_CMD = open
else ifeq ($(UNAME_S),Linux)
    # Linux-specific settings
    GIT_CONFIG = .gitconfig-linux
    OPEN_CMD = xdg-open
endif

all:
	cp $(GIT_CONFIG) ~/.gitconfig.local
	stow --dotfiles --adopt -t ~/ .

services: copy_services

copy_services:
	@mkdir -p "$(SERVICE_DIR)"
	@for plist in $(SERVICE_FILES); do \
		target="$(SERVICE_DIR)/$$(basename "$$plist")"; \
		rm -f "$$target"; \
		cp "$$plist" "$$target"; \
	done
