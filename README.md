This Dockerfile allows to build Qt applications inside a container container. It uses the awesome [qtci](https://github.com/benlau/qtci) scripts from [@benlau](https://github.com/benlau) for installing Qt, the android SDK + NDK. 

# Usage
* Download the Dockerfile to your host system with 
`wget https://raw.githubusercontent.com/bbernhard/qt-android-docker/master/Dockerfile`

* Change to the directory where the Dockerfile resides and build the docker container with: 

   ```docker build -t qt-android .```

  If no build arguments are specified, a docker container with Qt 5.12.0, Android NDK r17c and android-19 will be created. 

  In case you want to create a docker image with different versions, change the following line accordingly: 

```bash
docker build -t qt-android --build-arg QT_VERSION="5.12.0" --build-arg NDK_VERSION="r17c" --build-arg SDK_INSTALL_PARAMS="platform-tool,build-tools-20.0.0,android-19" --build-arg QT_PACKAGES="qt,qt.qt5.5120,qt.qt5.5120.gcc_64,qt.qt5.5120.android_armv7" .
```

* Next, create a bash script on your host system, which will then be executed inside the docker container. 
  
  e.q: The script to build [Imagemonkey - TheGame](https://github.com/bbernhard/imagemonkey-thegame) looks like this: 

```bash
# script.sh
#!/bin/bash

export ANDROID_TARGET_SDK_VERSION=23
git clone https://github.com/bbernhard/imagemonkey-thegame.git /tmp/imagemonkey-thegame
build-android-gradle-project /tmp/imagemonkey-thegame/imagemonkey_thegame.pro
```

* Now, create a folder named `android-build` on your host system and run the docker container with 

`docker run --mount type=bind,source="$(pwd)/android-build",target=/android-build -i qt < script.sh` 

to build your application. Inside the `android-build` folder you should now find the apk. 
