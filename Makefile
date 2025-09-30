SERVICE_FILES := $(wildcard Library/LaunchAgents/*)
SERVICE_FILES := $(wildcard Library/LaunchAgents/*)
.PHONY: services $(SERVICE_FILES)

all:
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
