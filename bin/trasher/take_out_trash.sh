#!/bin/sh
mkdir -p  ~/Downloads/do_not_trash
mkdir -p  ~/Desktop/do_not_trash

find ~/Downloads \
    -mtime +7 \
    -maxdepth 1 \
    -mindepth 1 \
    ! -path "do_not_trash" \
    -and -not -name "*.pdf" \
    -and -not -name "*.jpg" \
    -and -not -name "*.png" \
    -exec ~/bin/trasher/trash {} \;

find ~/Desktop \
    -mtime +7 \
    -type f \
    -and -not -name "keystore" \
    -and -not -name "fastlane-access-key.json" \
    -and -not -name "apple-auth-admin.p8" \
    -and -not -name "apple-auth.p8" \
    -and -not -name "*.pdf" \
    ! -path "do_not_trash" \
    -maxdepth 1 \
    -mindepth 1 \
    -exec ~/bin/trasher/trash {} \;

echo "Trasher ran at $(date)"
