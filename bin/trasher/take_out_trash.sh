#!/bin/sh
find ~/Downloads \
    -mtime +7 \
    -maxdepth 1 \
    -mindepth 1 \
    -exec ~/bin/trasher/trash {} \;

find ~/Desktop \
    -mtime +7 \
    -type f \
    -and -not -name "keystore" \
    -and -not -name "fastlane-access-key.json" \
    -and -not -name "apple-auth-admin.p8" \
    -and -not -name "apple-auth.p8" \
    -maxdepth 1 \
    -mindepth 1 \
    -exec ~/bin/trasher/trash {} \;

echo "Trasher ran at $(date)"
 
