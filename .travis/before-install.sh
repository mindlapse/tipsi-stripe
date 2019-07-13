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
#    sdkmanager --list | head -30
#    touch ~/.android/repositories.cfg
#
#
#
#    echo ANDROID_HOME=$ANDROID_HOME
#    export ANDROID_SDK_ROOT=/usr/local/android-sdk-25.2.3
#    echo ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT

    export DISPLAY=:99.0
    sh -e /etc/init.d/xvfb start
    sleep 3 # give xvfb some time to start

    ANDROID_TOOLS=4333796 # android-28
    export ANDROID_HOME=~/android-sdk
    export ANDROID_SDK_ROOT=~/android-sdk
    echo "### Downloading android tools"
    wget "https://dl.google.com/android/repository/sdk-tools-linux-$ANDROID_TOOLS.zip" -O android-sdk-tools.zip
    echo "### Unzipping android tools"
    unzip -q android-sdk-tools.zip -d ${ANDROID_HOME}
    echo "### Removing android-sdk-tools.zip"
    rm android-sdk-tools.zip
    PATH=${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools
    echo "### Set PATH to $PATH"
    # Silence warning.
    mkdir -p ~/.android
    touch ~/.android/repositories.cfg


#    echo "### Uninstalling extras;google;google_play_services"
#    yes | sdkmanager --uninstall "extras;google;google_play_services" > /dev/null

    echo "### Installing platforms;android-${COMPILE_API_LEVEL} required by compiler"
    yes | sdkmanager "platforms;android-${COMPILE_API_LEVEL}" > /dev/null

    echo "### Installing platforms;android-${COMPILE_API_LEVEL} required by compiler"
    yes | sdkmanager "platforms;android-${COMPILE_API_LEVEL}" > /dev/null

    echo "### Updating tools"
    yes | sdkmanager "tools" #> /dev/null

    echo "### Updating platform-tools"
    yes | sdkmanager "platform-tools" #> /dev/null

    echo "### Updating extras"
    yes | sdkmanager "extras" #> /dev/null

    echo "### Installing build-tools;${ANDROID_BUILD_TOOLS_VERSION}"
    yes | sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" > /dev/null

    # The SDK used in the project
    echo "### Installing android-${COMPILE_API_LEVEL}"
    yes | sdkmanager "platforms;android-${COMPILE_API_LEVEL}" > /dev/null

    # For running the emulator
    echo "### Installing platforms;${EMULATOR_API_LEVEL}"
    yes | sdkmanager "platforms;android-${EMULATOR_API_LEVEL}" > /dev/null



#    echo "### Uninstalling build-tools;25.0.2"
#    yes | sdkmanager --uninstall "build-tools;25.0.2" #> /dev/null
#
#    echo "### Uninstalling platforms;android-25"
#    yes | sdkmanager --uninstall "platforms;android-25" #> /dev/null

    echo "### Installing ${EMULATOR} system image"
    yes | sdkmanager "${EMULATOR}"

    sdkmanager --list | head -30  # Print out package list for debug purposes
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
