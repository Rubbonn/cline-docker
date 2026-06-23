#!/usr/bin/bash

if [ -n "${CLINE_PROVIDER}" ] && [ -n "${CLINE_MODEL}" ] && [ -n "${CLINE_APIKEY}" ]; then
  echo "Called cline with provider ${PROVIDER} and model ${CLINE_MODEL} and api key ${CLINE_APIKEY}"
  gosu cline cline auth -p ${CLINE_PROVIDER}$([ -n "${CLINE_BASEURL}" ] && echo " -b ${CLINE_BASEURL}") -k ${CLINE_APIKEY} -m ${CLINE_MODEL}
else
  echo 'Missing parameters $CLINE_PROVIDER [$CLINE_BASEURL] $CLINE_MODEL $CLINE_APIKEY'
  exit 1
fi

Xvfb :0 -screen 0 1280x1024x24 &
export DISPLAY=:0
sleep 1

fluxbox -display :0 &
x11vnc -display :0 -nopw &
websockify --web /novnc --daemon 0.0.0.0:5901 localhost:5900

exec gosu cline "$@"