#!/bin/bash

rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf "~/Library/Developer/Xcode/iOS DeviceSupport"
xcrun simctl delete unavailable
rm -rf ~/Library/Developer/CoreSimulator/Caches
rm -rf ~/Library/Caches/com.apple.dt.Xcode
rm -rf ~/Library/Developer/Xcode/UserData/Previews
rm -rf ~/Library/Caches/org.swift.swiftpm