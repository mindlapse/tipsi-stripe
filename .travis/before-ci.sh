#!/bin/bash

echo ".travis/before-ci.sh starting"

case "${TRAVIS_OS_NAME}" in
  linux)

    echo no | android create avd --force -n ${EMULATOR_NAME} -k "${EMULATOR}"
    # Run emulator in a subshell, this seems to solve the travis QT issue
    ( cd "$(dirname "$(which emulator)")" && ./emulator -avd ${EMULATOR_NAME} -verbose -show-kernel -selinux permissive -no-audio -no-window -no-boot-anim -wipe-data & )
    android-wait-for-emulator
    adb shell settings put global window_animation_scale 0 &
    adb shell settings put global transition_animation_scale 0 &
    adb shell settings put global animator_duration_scale 0 &
    sleep 30
    adb shell input keyevent 82 &
    adb devices
  ;;
#    export DISPLAY=:99.0
#    sh -e /etc/init.d/xvfb start
#    sleep 3 # give xvfb some time to start
#
#    echo "Listing available component"
##    sdkmanager --list
#    ANDROID_TOOLS=4333796 # android-28
#    export ANDROID_HOME=~/android-sdk
#    echo "### Downloading android tools"
#    wget "https://dl.google.com/android/repository/sdk-tools-linux-$ANDROID_TOOLS.zip" -O android-sdk-tools.zip
#    echo "### Unzipping android tools"
#    unzip -q android-sdk-tools.zip -d ${ANDROID_HOME}
#    echo "### Removing android-sdk-tools.zip"
#    rm android-sdk-tools.zip
#    PATH=${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools
#    echo "### Set PATH to $PATH"
#    # Silence warning.
#    mkdir -p ~/.android
#    touch ~/.android/repositories.cfg
#    # Accept licenses before installing components, no need to echo y for each component
##    yes | sdkmanager --licenses
#
#    # Platform tools
#    sdkmanager --list | head -15
#    echo '### sdkmanager "emulator"'
#    yes | sdkmanager "emulator" > /dev/null
#    echo '### sdkmanager "tools"'
#    yes | sdkmanager "tools" > /dev/null
#    echo '### sdkmanager "platform-tools"'
#    yes | sdkmanager "platform-tools" > /dev/null
#    # install older build tools (for emulator)
#    echo "### Install build-tools"
#    yes | sdkmanager "build-tools;28.0.3" > /dev/null
#    echo "### Install platform tools"
#    yes | sdkmanager "platforms;android-28" > /dev/null
#    echo "### Install system-images;android-$SYS;$ABI"
#    yes | sdkmanager "system-images;android-$SYS;$ABI" > /dev/null
#    sdkmanager --list | head -20
#    echo no | avdmanager create avd -n test -k "system-images;android-$SYS;$ABI"
#    avdmanager
#    echo "### avdmanager list avd"
#    avdmanager list avd
#
#    # fix timezone warning on osx
#    if [[ "${SYS}${ABI}" == "25google_apis;armeabi-v7a" || "${SYS}${ABI}" == "24google_apis;armeabi-v7a" ]]; then
#      EMU_PARAMS="-no-window -gpu swiftshader"
#    else
#      EMU_PARAMS="-no-boot-anim -gpu off"
#    fi
#    # use the absolute emulator path in case older version installed (on default path)
#    echo "### ls $ANDROID_HOME"
#    ls $ANDROID_HOME
#    echo "### ls $ANDROID_HOME/tools"
#    ls $ANDROID_HOME/tools
#    echo "### Starting emulator"
#    $ANDROID_HOME/tools/emulator -avd test -no-audio $EMU_PARAMS &
#
#    android-wait-for-emulator
#    echo "Sleeping for 60"
#    sleep 60
#    echo "Unlocking the device screen"
#    adb shell input keyevent 82 &
#
#    # Prevent 'ENOSPC: System limit for number of file watchers reached' error
#    echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
#    ;;
esac

echo "Starting appium"
example_tmp/node_modules/.bin/appium --session-override > appium.out &

echo ".travis/before-ci.sh complete"
