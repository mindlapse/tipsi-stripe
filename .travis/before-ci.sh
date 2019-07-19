#!/bin/bash

case "${TRAVIS_OS_NAME}" in
  linux)

    # Update sdk platform for emulator
    echo "y" | android update sdk -a --no-ui --filter "android-24"

    # Update the emulator sys image
    echo "y" | android update sdk -a --no-ui --filter "sys-img-armeabi-v7a-android-24"

    # Creating and waiting for emulator to run tests
    echo no | android create avd --force -n test -t "android-24" --abi "armeabi-v7a" -c 100M
    QEMU_AUDIO_DRV=none emulator -avd test -no-window &
    android-wait-for-emulator
    adb shell input keyevent 82 &

    #echo no | android create avd --force -n test -t android-21 --abi armeabi-v7a --skin WVGA800
    #emulator -avd test -scale 96dpi -dpi-device 160 -no-audio -no-window &
    #android-wait-for-emulator
    #sleep 60
    #adb shell input keyevent 82 &
  ;;
esac

example_tmp/node_modules/.bin/appium --session-override > appium.out &
