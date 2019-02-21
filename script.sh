#!/bin/bash

# This is a sample script that illustrates how to build a Qt android app inside the docker container.
# This script here runs _inside_ the docker container. It clones the imagemonkey-thegame project
# (that's the one we want to build) and then starts the building process.

export ANDROID_TARGET_SDK_VERSION=23
git clone https://github.com/bbernhard/imagemonkey-thegame.git /tmp/imagemonkey-thegame
build-android-gradle-project /tmp/imagemonkey-thegame/imagemonkey_thegame.pro
