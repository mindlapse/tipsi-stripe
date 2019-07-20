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

    echo "Appium version"
    node_modules/.bin/appium --version
    echo "------------"
    ps aux|grep appium
    npm run test:android
    ps aux|grep appium
    cat ../appium.out
  ;;
esac
