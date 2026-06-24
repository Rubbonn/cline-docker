#!/usr/bin/bash

PROVIDERS_FILE="/home/cline/.cline/data/settings/providers.json"
if ! [ -f "${PROVIDERS_FILE}" ] && [ -n "${CLINE_PROVIDER}" ] && [ -n "${CLINE_MODEL}" ] && { [ -n "${CLINE_BASEURL}" ] || [ -n "${CLINE_APIKEY}" ]; }; then
  echo "Called cline with provider ${CLINE_PROVIDER} and model ${CLINE_MODEL} and api key ${CLINE_APIKEY}"
  gosu cline cline auth -p ${CLINE_PROVIDER}$([ -n "${CLINE_BASEURL}" ] && echo " -b ${CLINE_BASEURL}")$([ -n "${CLINE_APIKEY}" ] && echo " -k ${CLINE_APIKEY}") -m ${CLINE_MODEL}

  # Add reasoning configuration via jq if CLINE_REASONING is provided
  if [ -n "${CLINE_REASONING}" ] && ! echo "none low medium high xhigh" | grep -qw "${CLINE_REASONING}"; then
    echo "Error: unsupported CLINE_REASONING value '${CLINE_REASONING}'. Allowed: none, low, medium, high, xhigh"
    exit 1
  fi
  if [ -n "${CLINE_REASONING}" ] && [ -f "${PROVIDERS_FILE}" ]; then
    jq --arg provider "${CLINE_PROVIDER}" \
      --arg effort "${CLINE_REASONING}" \
      --argjson enabled "$([ "${CLINE_REASONING}" = "none" ] && echo "false" || echo "true")" \
      '
      .providers[$provider].settings.reasoning = {
        enabled: $enabled,
        effort: $effort
      }
      | .lastUsedProvider = $provider
      ' "${PROVIDERS_FILE}" > "${PROVIDERS_FILE}.tmp" \
      && mv "${PROVIDERS_FILE}.tmp" "${PROVIDERS_FILE}" \
      && chown cline:cline /home/cline/.cline/data/settings/providers.json
    echo "Reasoning effort set to ${CLINE_REASONING} for provider ${CLINE_PROVIDER}"
  elif [ -n "${CLINE_REASONING}" ]; then
    echo "Warning: providers.json not found at ${PROVIDERS_FILE}"
  fi
else
  echo 'Missing parameters: $CLINE_PROVIDER $CLINE_MODEL and ($CLINE_APIKEY required if $CLINE_BASEURL is not set)'
  exit 1
fi

Xvfb :0 -screen 0 1280x1024x24 &
export DISPLAY=:0
sleep 1

fluxbox -display :0 -log /dev/null &
x11vnc -display :0 -nopw -alwaysshared -capslock -repeat -forever -quiet -xdamage &
websockify --web /novnc --daemon 0.0.0.0:5901 localhost:5900

exec gosu cline "$@"