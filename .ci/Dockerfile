FROM ubuntu:20.04


ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC

RUN apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends --no-install-suggests \
       git \
       python2-dev \
       python3-dev \
       build-essential \
       chrpath \
       cpio \
       diffstat \
       file \
       gawk \
       wget \
       lz4 \
       zstd \
       sudo \
       locales \
       texinfo \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 \
    && groupadd _1001 -g 1001 \
    && groupadd _1000 -g 1000 \
    && groupadd _2000 -g 2000 \
    && groupadd _999 -g 999 \
    && useradd -ms /bin/bash conan -g _1001 -G _1000,_2000,_999 \
    && printf "conan:conan" | chpasswd \
    && adduser conan sudo \
    && printf "conan ALL= NOPASSWD: ALL\\n" >> /etc/sudoers

USER conan
WORKDIR /home/conan
