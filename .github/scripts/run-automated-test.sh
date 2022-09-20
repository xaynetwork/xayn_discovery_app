#!/bin/bash

adb root
adb shell screenrecord --bugreport --bit-rate 4M /sdcard/test.mp4 &
VIDEO_PID=$!
pushd application || exit
fastlane run_automation platform:android test_suite:"$TEST_SUITE"
sleep 5
popd || exit
kill $VIDEO_PID
sleep 3
adb pull /sdcard/test.mp4