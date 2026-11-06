#!/usr/bin/env bash
# Source this file in the managed cloud environment.
export FLUTTER_ROOT="${FLUTTER_ROOT:-/workspace/toolchains/flutter}"
export ANDROID_HOME="${ANDROID_HOME:-/workspace/toolchains/android-sdk}"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export CHROME_EXECUTABLE="${CHROME_EXECUTABLE:-/usr/bin/chromium}"
export JAVA_HOME="${MOOD_JAVA_HOME:-/workspace/toolchains/jdk-21}"
export PATH="$JAVA_HOME/bin:$PATH"
export PATH="$FLUTTER_ROOT/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
# Java/Gradle does not automatically consume HTTPS_PROXY. Keep the platform's
# proxy and TLS verification when downloading Gradle and Android dependencies.
if [[ -n "${HTTPS_PROXY:-}" ]]; then
  mood_proxy_host="$(python3 -c 'import os,urllib.parse; print(urllib.parse.urlparse(os.environ["HTTPS_PROXY"]).hostname)')"
  mood_proxy_port="$(python3 -c 'import os,urllib.parse; print(urllib.parse.urlparse(os.environ["HTTPS_PROXY"]).port or 80)')"
  export JAVA_TOOL_OPTIONS="${JAVA_TOOL_OPTIONS:-} -Djavax.net.ssl.trustStore=/etc/ssl/certs/java/cacerts -Dhttps.proxyHost=$mood_proxy_host -Dhttps.proxyPort=$mood_proxy_port -Dhttp.proxyHost=$mood_proxy_host -Dhttp.proxyPort=$mood_proxy_port"
fi
