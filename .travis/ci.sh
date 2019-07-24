#!/bin/bash

cd example_tmp
npm run configure

case "${TRAVIS_OS_NAME}" in
  osx)
    set -o pipefail && npm run build:ios | xcpretty -c -f `xcpretty-travis-formatter`
    npm run test:ios
  ;;
  linux)
    npm run build:android

    filename=screencap.png
    echo "Uploading a screenshot before starting tests"
    adb shell screencap -p /sdcard/$filename
    adb pull /sdcard/$filename ./$filename
    npx imgur-upload-cli ./$filename

    npm run test:android || true
  ;;
esac
