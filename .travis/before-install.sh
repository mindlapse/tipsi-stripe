#!/bin/bash

echo ".travis/before-install.sh starting"

init_new_example_project() {
  proj_dir_old=example
  proj_dir_new=example_tmp

  react_native_version=$(cat $proj_dir_old/package.json | sed -n 's/"react-native": "\(\^|~\)*\(.*\)",*/\2/p')

  files_to_copy=(
    .appiumhelperrc
    package.json
    index.{ios,android}.js
    android/build.gradle
    android/app/build.gradle
    android/gradle/wrapper/gradle-wrapper.properties
    android/gradle.properties
    ios/example/AppDelegate.m
    src
    scripts
    __tests__
    rn-cli.config.js
    ios/Podfile
  )

  mkdir tmp
  cd tmp
  react-native init $proj_dir_old --version $react_native_version
  rm -rf $proj_dir_old/__tests__
  cd ..
  mv tmp/$proj_dir_old $proj_dir_new
  rm -rf tmp

  echo "Copying $proj_dir_old files into $proj_dir_new"
  for i in ${files_to_copy[@]}; do
    if [ -e $proj_dir_old/$i ]; then
      cp -Rp $proj_dir_old/$i $proj_dir_new/$i
    fi
  done
}

# NVM_NODEJS_ORG_MIRROR is deprecated and will be removed in node-gyp v4,
# please use NODEJS_ORG_MIRROR
export NODEJS_ORG_MIRROR=http://nodejs.org/dist

$HOME/.nvm/nvm.sh
echo "Installing node 8.9.0"
nvm install v12.6.0

echo "Installing npm 6"
npm i npm@6 -g


case "${TRAVIS_OS_NAME}" in
  osx)
    echo "Installing cocoapods"
    gem install cocoapods -v 1.4.0
    travis_wait pod repo update --silent
  ;;
  linux)
    echo ANDROID_HOME=ANDROID_HOME
    echo ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT
    sdkmanager --list | head -30                                              # Print out package list for debug purposes
#    sdkmanager --uninstall "extras;google;google_play_services"
    yes | sdkmanager "tools"                                      > /dev/null  # Update tools
    yes | sdkmanager "platforms;android-${EMULATOR_API_LEVEL}"    > /dev/null  # Android platform required by emulator
    yes | sdkmanager "platforms;android-${COMPILE_API_LEVEL}"     > /dev/null  # Android platform required by compiler
    yes | sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" > /dev/null  # Android build tools
    yes | sdkmanager "${EMULATOR}"                                > /dev/null  # Install emulator system image
    sdkmanager --list | head -30                                              # Print out package list for debug purposes
  ;;
esac

echo "Installing react-native-cli"
npm install -g react-native-cli

# Test propTypes
echo "Calling npm install"
npm install

echo "Calling npm test"
npm test

echo "Removing existing tarball"
rm -rf *.tgz

echo "Creating a new tarball"
npm pack

init_new_example_project

echo ".travis/before-install.sh complete"
