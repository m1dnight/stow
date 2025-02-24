SERVICE_FILES := $(wildcard Library/LaunchAgents/*)
.PHONY: services $(SERVICE_FILES)

all:
	stow --dotfiles --adopt -t ~/ .

services: $(SERVICE_FILES)

$(SERVICE_FILES):
	@launchctl unload $@
	@launchctl load $@
	@-launchctl stop $@
	@-launchctl start $@
