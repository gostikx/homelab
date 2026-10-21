FROM ghcr.io/nexu-io/od:0.24.1

USER root

ARG OPENCODE_VERSION=1.19.3

RUN mkdir -p /home/open-design \
 && chown 1001:1001 /home/open-design \
 && npm install -g "opencode-ai@${OPENCODE_VERSION}" \
 && opencode --version \
 && rm -rf /root/.npm /tmp/*
