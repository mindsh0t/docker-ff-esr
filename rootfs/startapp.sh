#!/usr/bin/with-contenv sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

export HOME=/config
mkdir -p /config/profile
mkdir -p /config/profile/extensions
mkdir -p /config/iMacros/Macros
mkdir -p /config/iMacros/Datasources
unzip /setup/extensions.zip -o -d /config/profile/extensions
mv -n /macros/* /config/iMacros/Macros
mv -n /datasources/* /config/iMacros/Datasources
firefox --version
exec /usr/bin/firefox_wrapper --profile /config/profile --setDefaultBrowser >> /config/log/firefox/output.log 2>> /config/log/firefox/error.log
