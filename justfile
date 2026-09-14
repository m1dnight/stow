# Install the dotfiles and relevant configurations.
# define which gitconfig file to use depending on OS.

git_config := if os() == "macos" { ".gitconfig-mac" } else { ".gitconfig-linux" }

# Install the git config and stow the dotfiles into ~
default:
    cp {{ git_config }} ~/.gitconfig.local
    stow --dotfiles --adopt -t ~/ .

services:
    #!/usr/bin/env -S bash -x
    id=$(id -u)
    for plist in launch-agents/*.plist; do
        # the label is the filename (including plist)
        label=$(basename $plist)

        # bootout if it exists
        launchctl bootout "gui/${id}" ~/Library/LaunchAgents/$label

        # Remove the old file and copy it over again.
        rm -f ~/Library/LaunchAgents/$label
        cp $plist ~/Library/LaunchAgents
        chmod 644 ~/Library/LaunchAgents/$label

        # Enable and start the service.
        launchctl enable gui/$id/$label
        launchctl bootstrap gui/$id ~/Library/LaunchAgents/$label
        launchctl kickstart gui/$id/$label
        # launchctl print gui/$id/$label
    done
