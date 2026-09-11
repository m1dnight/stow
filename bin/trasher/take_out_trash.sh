#!/bin/sh
mkdir -p  ~/Downloads/do_not_trash
mkdir -p  ~/Desktop/do_not_trash

find ~/Downloads \
    -type f \
    -mtime +7 \
    -maxdepth 1 \
    -mindepth 1 \
    ! -path "$HOME/Downloads/do_not_trash" \
    -exec ~/bin/trasher/trash {} \;

find ~/Desktop \
    -mtime +7 \
    -type f \
    -and -not -name "keystore" \
    -and -not -name "fastlane-access-key.json" \
    -and -not -name "apple-auth-admin.p8" \
    -and -not -name "apple-auth.p8" \
    -and -not -name "*.pdf" \
    ! -path "$HOME/Desktop/do_not_trash" \
    -maxdepth 1 \
    -mindepth 1 \
    -exec ~/bin/trasher/trash {} \;

echo "Trasher ran at $(date)"
