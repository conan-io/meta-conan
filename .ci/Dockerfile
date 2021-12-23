FROM ubuntu:20.04


RUN apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends --no-install-suggests \
       git \
       python3 \
       build-essential \
       chrpath \
       cpio \
       diffstat \
       file \
       gawk \
       wget \
    && groupadd 1001 -g 1001 \
    && groupadd 1000 -g 1000 \
    && groupadd 2000 -g 2000 \
    && groupadd 999 -g 999 \
    && useradd -ms /bin/bash conan -g 1001 -G 1000,2000,999 \
    && printf "conan:conan" | chpasswd \
    && adduser conan sudo \
    && printf "conan ALL= NOPASSWD: ALL\\n" >> /etc/sudoers

USER conan
WORKDIR /home/conan