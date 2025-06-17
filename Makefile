SERVICE_FILES := $(wildcard Library/LaunchAgents/*)
.PHONY: services $(SERVICE_FILES)

all:
	stow --dotfiles --adopt -t ~/ .

services: $(SERVICE_FILES)

# https://superuser.com/questions/930389/how-to-start-a-service-using-mac-osxs-launchctl
$(SERVICE_FILES):
	@launchctl unload -w $@
	@launchctl load -w $@
	@-launchctl stop $@
	@-launchctl start $@
