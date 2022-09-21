#!/usr/bin/env bash

adb root
fastlane build_runner
fastlane build apk
adb shell screenrecord --bugreport --bit-rate 4M /sdcard/test.mp4 &
VIDEO_PID=$!
flutter test integration_test
kill $VIDEO_PID || true
sleep 3
adb pull /sdcard/test.mp4