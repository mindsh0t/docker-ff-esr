# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.8-v3.5.3

# Docker image version is provided via build arg.
ARG DOCKER_IMAGE_VERSION=unknown

# Define software versions.
ARG FIREFOX_VERSION=52.9.0-r0
ARG JSONLZ4_VERSION=c4305b8
ARG LZ4_VERSION=1.8.1.2

# Define software download URLs.
ARG JSONLZ4_URL=https://github.com/avih/dejsonlz4/archive/${JSONLZ4_VERSION}.tar.gz
ARG LZ4_URL=https://github.com/lz4/lz4/archive/v${LZ4_VERSION}.tar.gz

# Define working directory.
WORKDIR /tmp

# Install JSONLZ4 tools.
RUN \
    add-pkg --virtual build-dependencies \
        curl \
        build-base \
        && \
    mkdir jsonlz4 && \
    mkdir lz4 && \
    curl -# -L {$JSONLZ4_URL} | tar xz --strip 1 -C jsonlz4 && \
    curl -# -L {$LZ4_URL} | tar xz --strip 1 -C lz4 && \
    mv jsonlz4/src/ref_compress/*.c jsonlz4/src/ && \
    cp lz4/lib/lz4.* jsonlz4/src/ && \
    cd jsonlz4 && \
    gcc -static -Wall -o dejsonlz4 src/dejsonlz4.c src/lz4.c && \
    gcc -static -Wall -o jsonlz4 src/jsonlz4.c src/lz4.c && \
    strip dejsonlz4 jsonlz4 && \
    cp -v dejsonlz4 /usr/bin/ && \
    cp -v jsonlz4 /usr/bin/ && \
    cd .. && \
    # Cleanup.
    del-pkg build-dependencies && \
    rm -rf /tmp/* /tmp/.[!.]*

# Install Firefox.
RUN \
add-pkg firefox-esr=${FIREFOX_VERSION}

# Install extra packages.
RUN \
    add-pkg \
        desktop-file-utils \
        adwaita-icon-theme \
        ttf-dejavu \
        ffmpeg-libs \
        # The following package is used to send key presses to the X process.
        xdotool

# Set default settings.
RUN \
CFG_FILE="$(ls /usr/lib/firefox-*/browser/defaults/preferences/firefox-branding.js)" && \
    echo '' >> "$CFG_FILE" && \
    echo '// Default download directory.' >> "$CFG_FILE" && \
    echo 'pref("browser.download.dir", "/config/downloads");' >> "$CFG_FILE" && \
    echo 'pref("browser.download.folderList", 2);' >> "$CFG_FILE"


# Enable log monitoring.
RUN \
    add-pkg yad && \
    sed-patch 's|LOG_FILES=|LOG_FILES=/config/log/firefox/error.log|' /etc/logmonitor/logmonitor.conf && \
    sed-patch 's|STATUS_FILES=|STATUS_FILES=/tmp/.firefox_shm_check|' /etc/logmonitor/logmonitor.conf

# Adjust the openbox config.
RUN \
    # Maximize only the main window.
    sed-patch 's/<application type="normal">/<application type="normal" title="Mozilla Firefox">/' \
        /etc/xdg/openbox/rc.xml && \
    # Make sure the main window is always in the background.
    sed-patch '/<application type="normal" title="Mozilla Firefox">/a \    <layer>below</layer>' \
        /etc/xdg/openbox/rc.xml

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://github.com/jlesage/docker-templates/raw/master/jlesage/images/firefox-icon.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /

# Set environment variables.
ENV APP_NAME="Firefox"
ENV KEEP_APP_RUNNING="1"
ENV FF_PREF_UPDATE1="app.update.auto=false"
ENV FF_PREF_UPDATE2="app.update.enabled=false"
ENV FF_PREF_UPDATE3="app.update.checkInstallTime=false"
ENV FF_PREF_DONTCLOSE="browser.tabs.closeWindowWithLastTab=false"
ENV FF_PREF_SIGNATURES="xpinstall.signatures.required=false"
ENV FF_PREF_FIRSTRUN="app.normandy.first_run=false"
ENV FF_PREF_AUTOSTART="browser.startup.homepage=\"imacros://run/?m=Autostart.iim\""
ENV FF_PREF_EXT="extensions.autoDisableScopes=0"
ENV FF_PREF_CRASH1="browser.sessionstore.resume_from_crash=false"
ENV FF_PREF_CRASH2="browser.sessionstore.max_resumed_crashes=0"
ENV FF_PREF_CRASH3="browser.tabs.crashReporting.sendReport=false"

# Define mountable directories.
VOLUME ["/config"]

# Metadata.
LABEL \
      org.label-schema.name="firefox" \
      org.label-schema.description="Docker container for Firefox" \
      org.label-schema.version="$DOCKER_IMAGE_VERSION" \
