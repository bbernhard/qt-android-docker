FROM debian:latest

ARG QT_VERSION=5.12.4
ARG NDK_VERSION=r17c
ARG SDK_INSTALL_PARAMS=platform-tool,build-tools-20.0.0,android-19
ARG QT_PACKAGES="qt,qt.qt5.5124,qt.qt5.5124.gcc_64,qt.qt5.5124.android_armv7"

RUN dpkg --add-architecture i386
RUN apt-get update

RUN apt-get install -y \
	wget \
	curl \
	unzip \
	git \
	g++ \
	make \
	lib32z1 \
	lib32ncurses6 \
	libbz2-1.0:i386 \
	lib32stdc++6 \
	&& apt-get clean

#install dependencies for Qt installer
RUN apt-get install -y \
	libgl1-mesa-glx \
	libglib2.0-0 \
	&& apt-get clean

#install dependencies for Qt modules
RUN apt-get install -y \
	libfontconfig1 \
	libdbus-1-3 \
	libx11-xcb1 \
	libnss3-dev \
	libasound2-dev \
	libxcomposite1 \
	libxrandr2 \
	libxcursor-dev \
	libegl1-mesa-dev \
	libxi-dev \
	libxss-dev \
	libxtst6 \
	libgl1-mesa-dev \
	&& apt install apt-transport-https ca-certificates wget dirmngr gnupg software-properties-common -y \
        && wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - \
        && add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ \
        && apt update && apt install adoptopenjdk-8-hotspot -y \
        && apt-get clean
 

ENV VERBOSE=1
ENV QT_CI_PACKAGES=$QT_PACKAGES

RUN wget https://raw.githubusercontent.com/homdx/qtci/master/bin/install-android-sdk --directory-prefix=/tmp \
	&& chmod u+rx /tmp/install-android-sdk \
	&& /tmp/install-android-sdk $SDK_INSTALL_PARAMS


#dependencies for Qt installer
RUN apt-get install -y \
	libgl1-mesa-glx \
	libglib2.0-0 \
	&& apt-get clean

#download + install Qt

RUN mkdir -p /tmp/qt-installer \
	cd /tmp/qt-installer \
	&& wget https://raw.githubusercontent.com/homdx/qtci/master/bin/extract-qt-installer --directory-prefix=/tmp/qt-installer/ \
	&& wget https://raw.githubusercontent.com/homdx/qtci/master/recipes/install-qt --directory-prefix=/tmp/qt-installer/ \
	&& export PATH=$PATH:/tmp/qt-installer/ \
	&& chmod u+rx /tmp/qt-installer/extract-qt-installer \
	&& chmod u+rx /tmp/qt-installer/install-qt \
	&& bash /tmp/qt-installer/install-qt $QT_VERSION \
	&& rm -rf /tmp/qt-installer

RUN wget https://raw.githubusercontent.com/homdx/qtci/master/bin/build-android-gradle-project --directory-prefix=/root/ \
	&& chmod u+rx /root/build-android-gradle-project

RUN echo $PATH

ENV PATH="/Qt/$QT_VERSION/android_armv7/bin/:${PATH}"
ENV ANDROID_NDK_ROOT="/android-ndk-$NDK_VERSION"
ENV ANDROID_SDK_ROOT="/android-sdk-linux"
ENV QT_HOME=/Qt/$QT_VERSION/

# install sdk tools to accept licenses
RUN mkdir -p /root/sdk-tools \
	&& wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip --directory-prefix=/root/sdk-tools/ \
	&& cd /root/sdk-tools/ \
	&& unzip sdk-tools-linux-4333796.zip \ 
	&& rm -f sdk-tools-linux-4333796.zip \
	&& yes | tools/bin/sdkmanager --licenses --sdk_root=$ANDROID_SDK_ROOT \
        && rm -vf /android-ndk-*.zip  /android-sdk*.tgz

RUN ln -s /root/build-android-gradle-project /usr/bin/build-android-gradle-project

CMD tail -f /var/log/faillog
