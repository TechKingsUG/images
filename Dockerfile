# ----------------------------------
# Wine Dockerfile for Steam Servers
# Environment: Debian Unstable Slim + Wine
# Minimum Panel Version: 0.7.6
# ----------------------------------
FROM        debian:unstable-slim

LABEL       author="Kenny B " maintainer="kenny@venatus.digital"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update \
 && apt upgrade -y \
 && apt install -y wget gnupg2

# Install Dependencies
RUN dpkg --add-architecture i386 \
  && wget -nc https://dl.winehq.org/wine-builds/winehq.key \
  && apt-key add winehq.key \
  && echo \"deb https://dl.winehq.org/wine-builds/debian/ buster main\" > /etc/apt/sources.list.d/wine.list

RUN apt update \
 && apt upgrade -y \
 && apt install -y software-properties-common \
 && apt install -y --install-recommends winehq-stable lib32gcc-s1 libntlm0 wget winbind iproute2 \
 && useradd -d /home/container -m container

USER        container
ENV         HOME /home/container
ENV         WINEARCH win64
ENV         WINEPREFIX /home/container/.wine64
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]