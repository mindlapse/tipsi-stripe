#!/bin/bash

android-wait-for-emulator() {
  set +e

  bootanim=""
  failcounter=0
  timeout_in_sec=900

  until [[ "$bootanim" =~ "stopped" ]]; do
    bootanim=`adb -e shell getprop init.svc.bootanim 2>&1 &`
    if [[ "$bootanim" =~ "device not found" || "$bootanim" =~ "device offline"
      || "$bootanim" =~ "running" ]]; then
      let "failcounter += 1"
      echo "Waiting for emulator to start"
      if [[ $failcounter -gt timeout_in_sec ]]; then
        echo "Timeout ($timeout_in_sec seconds) reached; failed to start emulator"
        exit 1
      fi
    fi
    sleep 1
  done

  echo "Emulator is ready"
}


case "${TRAVIS_OS_NAME}" in
  linux)

    echo "### Creating AVD ${EMULATOR_NAME} for image ${EMULATOR}"
    echo no | avdmanager create avd --force -n ${EMULATOR_NAME} -k "${EMULATOR}" -d "3.7in WVGA (Nexus One)"

    echo "### Starting emulator"
    # Run emulator in a subshell, this seems to solve the travis QT issue
    ( ${ANDROID_SDK_ROOT}/emulator/emulator -avd ${EMULATOR_NAME} -scale 96dpi -dpi-device 160 -m 512 -verbose -show-kernel -selinux permissive -no-audio -no-window -wipe-data -engine auto -gpu swiftshader_indirect > /dev/null 2>&1 & )

    android-wait-for-emulator
    adb shell settings put global window_animation_scale 0 &
    adb shell settings put global transition_animation_scale 0 &
    adb shell settings put global animator_duration_scale 0 &
    adb shell input keyevent 82 &
    adb devices
    sleep 60

    # Prevent 'ENOSPC: System limit for number of file watchers reached' error
    echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
  ;;
esac

echo "Starting appium"
example_tmp/node_modules/.bin/appium --session-override > appium.out &

