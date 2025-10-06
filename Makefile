SERVICE_FILES := $(wildcard Library/LaunchAgents/*)
SERVICE_FILES := $(wildcard Library/LaunchAgents/*)
.PHONY: services $(SERVICE_FILES)

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

services: $(SERVICE_FILES)

copy_services:
	@find ~/Library/LaunchAgents -type l -delete
	@cp Library/LaunchAgents/* ~/Library/LaunchAgents/

# https://superuser.com/questions/930389/how-to-start-a-service-using-mac-osxs-launchctl
# these cannot be symlinks so overwrite them
$(SERVICE_FILES): copy_services
	@launchctl unload -w $@
	@launchctl load -w $@
	@-launchctl stop $@
	@-launchctl start $@
