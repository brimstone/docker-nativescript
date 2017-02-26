FROM ubuntu:16.04

EXPOSE 8100
EXPOSE 35729

ARG NODE_VERSION=6.10.0

LABEL org.label-schema.url=https://github.com/brimstone/docker-nativescript \
      org.label-schema.vcs-url=https://github.com/brimstone/docker-nativescript.git

ENV ANDROID_HOME=/opt/android-sdk-linux \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/android-sdk-linux/tools:/opt/android-sdk-linux/platform-tools:/opt/node-v6.9.2-linux-x64/bin \
    HOME=/myapp \
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64


ENTRYPOINT ["/loader"]

# install packages we need on the system
RUN dpkg --add-architecture i386 \
 && echo "deb [arch=i386] http://us.archive.ubuntu.com/ubuntu xenial main restricted multiverse universe" > /etc/apt/sources.list.d/i386.list \
 && echo "deb [arch=i386] http://us.archive.ubuntu.com/ubuntu xenial-updates main restricted multiverse universe" >> /etc/apt/sources.list.d/i386.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends wget openjdk-8-jdk ant lib32z1 \
      lib32ncurses5 libbz2-1.0:i386 libc6:i386 zlib1g:i386 libstdc++6:i386 g++ paxctl \
 && apt-get clean \
 && paxctl -cm /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java \
 && paxctl -cm /usr/lib/jvm/java-8-openjdk-amd64/bin/javac \
 && paxctl -cm /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/keytool \
 && /var/lib/dpkg/info/ca-certificates-java.postinst configure

# install the android sdk
# download stuff for platform 6.0 - 23
RUN wget -qO - http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz \
  | tar -C /opt -zx \
 && chmod 755 /opt/android-sdk-linux/tools/android \
 && ( sleep 10; printf "y\n") \
  | android update sdk --no-ui \
        --filter tools,platform-tools,android-23,build-tools-23.0.3,extra-android-m2repository,extra-google-m2repository,extra-android-support --all \
 && android list targets | grep -q android-23 \
 && paxctl -cm /opt/android-sdk-linux/build-tools/23.0.3/aapt

# install cordova and ionic
RUN set -x && wget -qO - https://nodejs.org/dist/latest-v6.x/node-v${NODE_VERSION}-linux-x64.tar.gz \
  | tar -zxC /opt \
 && paxctl -cm /opt/node-v${NODE_VERSION}-linux-x64/bin/node \
 && ln -s /opt/node-v${NODE_VERSION}-linux-x64/bin/node /usr/local/bin/node \
 && ln -s /opt/node-v${NODE_VERSION}-linux-x64/bin/npm /usr/local/bin/npm \
 && mkdir /myapp \
 && npm install nativescript -g --unsafe-perm \
 && rm -rf /myapp

COPY loader /
