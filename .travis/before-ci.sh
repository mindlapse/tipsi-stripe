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

    # Cleanup (if rerun)
    adb -s emulator-5554 emu kill || true
    adb kill-server || true
    avdmanager delete avd -n ${EMULATOR_NAME} || true

    echo "### Creating AVD ${EMULATOR_NAME} for image ${EMULATOR}"
    echo no | avdmanager create avd --force -n ${EMULATOR_NAME} -k "${EMULATOR}" -d "4.7in WXGA"

    echo "### Starting emulator"
    # Run emulator in a subshell, this seems to solve the travis QT issue
    ( ${ANDROID_SDK_ROOT}/emulator/emulator -avd ${EMULATOR_NAME} -memory 2048 -verbose -show-kernel -selinux permissive -no-audio -no-window -engine auto -gpu swiftshader_indirect -wipe-data > /dev/null 2>&1 & )

    android-wait-for-emulator
    adb shell settings put global window_animation_scale 0 &
    adb shell settings put global transition_animation_scale 0 &
    adb shell settings put global animator_duration_scale 0 &
    adb shell input keyevent 82 &
    adb devices

    # Prevent 'ENOSPC: System limit for number of file watchers reached' error
    echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

    for i in 6 5 4 3 2 1
    do
      secondsLeft=$(($i*30))
      echo "Warming up, ${secondsLeft}s remaining..."
      sleep 30
    done
    echo "Warmup complete."

  ;;
esac

echo "Starting appium"
example_tmp/node_modules/.bin/appium --session-override > appium.out &

