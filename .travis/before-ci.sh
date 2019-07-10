#!/bin/bash

echo ".travis/before-ci.sh starting"

case "${TRAVIS_OS_NAME}" in
  linux)
    echo "Listing targets"
    android list targets
    echo "Creating AVD"
    android create avd --force -n test -t android-25 --abi armeabi-v7a --skin WVGA800
    echo "Starting emulator as a background process"
    emulator -avd test -scale 96dpi -dpi-device 160 -no-audio -no-window &
    echo "Waiting for emulator"
    android-wait-for-emulator
    echo "Sleeping for 60"
    sleep 60
    echo "Unlocking the device screen"
    adb shell input keyevent 82 &
  ;;
esac

echo "Starting appium"
example_tmp/node_modules/.bin/appium --session-override > appium.out &

echo ".travis/before-ci.sh complete"
