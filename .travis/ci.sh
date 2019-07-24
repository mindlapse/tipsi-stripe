#!/bin/bash

cd example_tmp
npm run configure

case "${TRAVIS_OS_NAME}" in
  osx)
    set -o pipefail && npm run build:ios | xcpretty -c -f `xcpretty-travis-formatter`
    npm run test:ios
  ;;
  linux)
    export ANDROID_HOME=~/android-sdk
    export PATH=${PATH}:${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

    npm run build:android

    echo "Uploading a screenshot before starting tests"
    filename=screencap.png
    adb shell screencap -p /sdcard/$filename
    adb pull /sdcard/$filename ./$filename
    npx imgur-upload-cli ./$filename

    npm run test:android || true
  ;;
esac
