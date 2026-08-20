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
# Create the unique identifier for each service, based on domain/user_id/label.
# then bootout the potential existing services
# then wait for the service to be removed (loop)
# then enable the service again
# then bootstrap it to load it into the system runner
# kickstart immediately runs it.
$(SERVICE_FILES): copy_services
	@plist=$(HOME)/Library/LaunchAgents/$(notdir $@); \
	label=$$(/usr/libexec/PlistBuddy -c 'Print :Label' "$$plist"); \
	domain=gui/$$(id -u); \
	launchctl bootout $$domain/$$label 2>/dev/null || true; \
	for i in 1 2 3 4 5 6 7 8 9 10; do \
		launchctl print $$domain/$$label >/dev/null 2>&1 || break; \
		sleep 1; \
	done; \
	launchctl enable $$domain/$$label; \
	launchctl bootstrap $$domain "$$plist"; \
	launchctl kickstart $$domain/$$label
