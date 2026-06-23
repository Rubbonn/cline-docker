FROM node:24-trixie

# Setup environment
RUN apt update && apt install -y sudo xvfb fluxbox x11vnc xdotool scrot imagemagick jq python3 python3-pip python3-venv websockify gosu \
	&& useradd -m -s /usr/bin/bash cline \
    && echo "cline ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
COPY --chown=cline:cline .cline/ /home/cline/.cline/
ADD https://github.com/novnc/noVNC.git /novnc

# Setup Cline
RUN npm install -g cline

WORKDIR /workspace
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh", "cline"]

VOLUME ["/workspace"]
EXPOSE 5900 5901