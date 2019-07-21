#!/bin/bash

case "${TRAVIS_OS_NAME}" in
  linux)

#    # Update sdk platform for emulator
#    echo "y" | android update sdk -a --no-ui --filter "android-24"
#
#    # Update the emulator sys image
#    echo "y" | android update sdk -a --no-ui --filter "sys-img-armeabi-v7a-android-24"
    adb kill-server

    echo "Cretaing AVD"
    echo no | android create avd --force -n test -t android-24 --abi armeabi-v7a --skin WVGA800 -c 512M

    echo "Starting emulator"
    QEMU_AUDIO_DRV=none emulator -avd test -scale 96dpi -dpi-device 160 -no-window &

    android-wait-for-emulator
    adb shell input keyevent 82 &

    echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

    sdkmanager --list | head -30
  ;;
esac

example_tmp/node_modules/.bin/appium --session-override > appium.out &
