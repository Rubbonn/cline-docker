FROM node:24-trixie

# Environment variables
ENV \
    # Provider to use for the agent
    CLINE_PROVIDER= \
    # (Optional) Custom endpoint for custom provider
    CLINE_BASEURL='' \
    # (Optional) Api key for the provider
    CLINE_APIKEY= \
    # Model to use with the agent
    CLINE_MODEL= \
    # Reasoning level; supported values are 'none', 'low', 'medium', 'high', 'xhigh'; default to 'medium'
    CLINE_REASONING='medium'

# Setup environment
RUN apt-get update && apt-get install -y sudo xvfb fluxbox x11vnc xdotool scrot imagemagick jq python3 python3-pip python3-venv websockify gosu \
	&& useradd -m -s /usr/bin/bash cline \
    && echo "cline ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
	&& mkdir -p /workspace && chown -R cline:cline /workspace
COPY --chown=cline:cline .cline/ /home/cline/.cline/
ADD https://github.com/novnc/noVNC.git /novnc
RUN npm install -g @playwright/cli@latest \
    && (cd /home/cline && gosu cline playwright-cli install --skills agents)

# Setup Cline
RUN npm install -g cline

WORKDIR /workspace
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh", "cline"]

VOLUME ["/workspace"]
EXPOSE 5900 5901