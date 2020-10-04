#FROM alpine
#
#COPY nabla.c /
#RUN apk add build-base \
#    && gcc -o nabla nabla.c \
#    && apk del build-base linux-headers pcre-dev openssl-dev && \
#    rm -rf /var/cache/apk/*

# See https://hub.docker.com/_/python
FROM python:3 AS builder

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive \
  apt-get install -qy --no-install-recommends \
  cmake \
  git \
  g++ \
#  python3.8 \
#  audacious-dev \
#  libaudclient-dev \
#  libcairo2-dev \
#  libcurl4-openssl-dev \
#  libical-dev \
#  libimlib2-dev \
#  libircclient-dev \
#  libiw-dev \
#  liblua5.3-dev \
#  libmicrohttpd-dev \
#  libmysqlclient-dev \
#  libpulse-dev \
#  librsvg2-dev \
#  libsystemd-dev \
#  libxdamage-dev \
#  libxext-dev \
#  libxft-dev \
#  libxinerama-dev \
  libxml2-dev \
#  libxmmsclient-dev \
#  libxnvctrl-dev \
#  libxml2-utils \
  ncurses-dev \
  libboost-filesystem-dev \
  libboost-system-dev \
  libboost-thread-dev \
  libcppunit-dev

COPY . /nabla
WORKDIR /nabla/build
ARG X11=yes

RUN pip install --no-cache-dir -r ../requirements-current-3.8.txt

RUN ../conan.sh

RUN pwd
RUN ls -lrta
RUN ls -lrta ..

RUN sh -c 'if [ "$X11" = "yes" ] ; then \
  export PROJECT_SRC=/nabla \
  && cmake \
  -DCMAKE_INSTALL_PREFIX=/opt/nabla \
#  -DBUILD_AUDACIOUS=ON \
#  -DBUILD_HTTP=ON \
#  -DBUILD_ICAL=ON \
#  -DBUILD_ICONV=ON \
#  -DBUILD_IRC=ON \
#  -DBUILD_JOURNAL=ON \
#  -DBUILD_LUA_CAIRO=ON \
#  -DBUILD_LUA_CAIRO=ON \
#  -DBUILD_LUA_IMLIB2=ON \
#  -DBUILD_LUA_RSVG=ON \
#  -DBUILD_MYSQL=ON \
#  -DBUILD_NVIDIA=ON \
#  -DBUILD_PULSEAUDIO=ON \
#  -DBUILD_RSS=ON \
#  -DBUILD_WLAN=ON \
#  -DBUILD_XMMS2=ON \
  ../sample/microsoft/ \
  ; else \
  export PROJECT_SRC=/nabla \
  && cmake \
  -DCMAKE_INSTALL_PREFIX=/opt/nabla \
#  -DBUILD_AUDACIOUS=ON \
#  -DBUILD_HTTP=ON \
#  -DBUILD_ICAL=ON \
#  -DBUILD_ICONV=ON \
#  -DBUILD_IRC=ON \
#  -DBUILD_JOURNAL=ON \
#  -DBUILD_LUA_CAIRO=ON \
#  -DBUILD_LUA_CAIRO=ON \
#  -DBUILD_LUA_IMLIB2=ON \
#  -DBUILD_LUA_RSVG=ON \
#  -DBUILD_MYSQL=ON \
#  -DBUILD_PULSEAUDIO=ON \
#  -DBUILD_RSS=ON \
#  -DBUILD_WLAN=ON \
#  -DBUILD_X11=OFF \
#  -DBUILD_XMMS2=ON \
  ../sample/microsoft/ \
  ; fi' \
  && make -j5 all \
  && make -j5 install

#FROM ubuntu:bionic
FROM ubuntu:20.04

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive \
  apt-get install -qy --no-install-recommends \
#  libaudclient2 \
#  libcairo2 \
#  libcurl4 \
#  libical3 \
#  libimlib2 \
#  libircclient1 \
#  libiw30 \
#  liblua5.3-0 \
#  libmicrohttpd12 \
#  libmysqlclient20 \
#  libncurses5 \
#  libpulse0 \
#  librsvg2-2 \
#  libsystemd0 \
#  libxcb-xfixes0 \
#  libxdamage1 \
#  libxext6 \
#  libxfixes3 \
#  libxft2 \
#  libxinerama1 \
#  libxmmsclient6 \
#  libxnvctrl0 \
  libxml2 \
  libboost-filesystem1.71.0 \
  libboost-system1.71.0 \
  libboost-thread1.71.0 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/nabla /opt/nabla

ENV PATH="/opt/nabla/bin:${PATH}"
ENV LD_LIBRARY_PATH="/opt/nabla/lib:${LD_LIBRARY_PATH}"

ENTRYPOINT [ "/opt/nabla/bin/run_app" ]
