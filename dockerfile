FROM firusv/base

# JAVA

RUN apt-get update && \
    apt-get -y install openjdk-11-jdk-headless unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    java -version

ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64

# ANDROID https://developer.android.com/studio/#downloads

ENV ANDROID_SDK_URL="https://dl.google.com/android/repository/commandlinetools-linux-9123335_latest.zip" \
    ANDROID_BUILD_TOOLS_VERSION=33.0.1 \
    GRADLE_URL="https://services.gradle.org/distributions/gradle-8.0.2-all.zip" \
    ANT_HOME="/usr/share/ant" \
    MAVEN_HOME="/usr/share/maven" \
    GRADLE_HOME="/opt/gradle-8.0.2" \
    ANDROID_SDK_ROOT="/opt/android" \
    ANDROID_HOME="/opt/android"

ENV PATH $PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/tools:$ANDROID_SDK_ROOT/build-tools/$ANDROID_BUILD_TOOLS_VERSION:$ANT_HOME/bin:$MAVEN_HOME/bin:$GRADLE_HOME/bin

WORKDIR /opt

RUN apt-get -qq update && \
    apt-get -qq install -y wget curl maven ant && \
    wget -O gradle.zip ${GRADLE_URL} && \
    unzip gradle.zip && rm gradle.zip

# Installs Android SDK
RUN cd /opt && mkdir android && cd android && \
    wget -O tools.zip ${ANDROID_SDK_URL} && \
    unzip tools.zip && rm tools.zip && \
    cd cmdline-tools && \
    mkdir latest && \
    ls | grep -v latest | xargs mv -t latest

RUN mkdir /root/.android && touch /root/.android/repositories.cfg && \
    while true; do echo 'y'; sleep 2; done | sdkmanager "platform-tools" "tools" "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" && \
    while true; do echo 'y'; sleep 2; done | sdkmanager "platforms;android-28" "platforms;android-29" "platforms;android-30" && \
    while true; do echo 'y'; sleep 2; done | sdkmanager "platforms;android-31" "platforms;android-32" "platforms;android-33" && \
    while true; do echo 'y'; sleep 2; done | sdkmanager "extras;android;m2repository" "extras;google;google_play_services" "extras;google;instantapps" "extras;google;m2repository" &&  \
    while true; do echo 'y'; sleep 2; done | sdkmanager "add-ons;addon-google_apis-google-22" "add-ons;addon-google_apis-google-23" "add-ons;addon-google_apis-google-24" "skiaparser;1" "skiaparser;2" "skiaparser;3"

RUN chmod a+x -R $ANDROID_SDK_ROOT && \
    chown -R root:root $ANDROID_SDK_ROOT && \
    rm -rf /opt/android/licenses && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get autoremove -y && \
    apt-get clean && \
    mvn -v && gradle -v && java -version && ant -version
