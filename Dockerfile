# Base image, default node image
FROM node:slim

# Environment configuration
ENV GITBOOK_VERSION="3.2.3"

# Install gitbook
RUN npm install --global gitbook-cli \
  && gitbook fetch ${GITBOOK_VERSION} \
  && npm install --global markdownlint-cli \
  && apt-get update \
  && apt-get install --no-install-recommends --no-install-suggests -y \
	  vim \
		nano \
    calibre \
    fonts-roboto \
    bzip2 \
    ghostscript \
    jpegoptim \
    optipng \
  && npm install svgexport -g --unsafe-perm \
  && npm cache clear --force \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/*
