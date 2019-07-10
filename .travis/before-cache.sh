#!/bin/bash

echo ".travis/before-cache.sh starting"

case "${TRAVIS_OS_NAME}" in
  linux)
    rm -f $HOME/.gradle/caches/modules-2/modules-2.lock
  ;;
esac

echo ".travis/before-cache.sh complete"
