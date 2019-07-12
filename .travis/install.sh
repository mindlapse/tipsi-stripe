#!/bin/bash

echo ".travis/install.sh starting"

library_name=$(node -p "require('./package.json').name")
library_version=$(node -p "require('./package.json').version")

cd example_tmp

case "${TRAVIS_OS_NAME}" in
  osx)
    npm run set-stripe-url-type
  ;;
esac

rm -rf node_modules && npm install

echo "Unlinking $library_name"
react-native unlink $library_name

echo "Linking"
react-native link

case "${TRAVIS_OS_NAME}" in
  osx)
    cd ios
    pod install
    cd ..
  ;;
esac

# Make sure that dependencies work correctly after reinstallation
echo "Removing node modules"
rm -rf node_modules

echo "Calling npm install"
npm install > /dev/null

echo ".travis/install.sh complete"
