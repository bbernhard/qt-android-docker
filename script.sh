#!/bin/bash

export ANDROID_TARGET_SDK_VERSION=23
git clone https://github.com/bbernhard/imagemonkey-thegame.git /tmp/imagemonkey-thegame
build-android-gradle-project /tmp/imagemonkey-thegame/imagemonkey_thegame.pro