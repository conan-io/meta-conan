FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y upgrade

# Required Packages for the Host Development System
# http://www.yoctoproject.org/docs/latest/mega-manual/mega-manual.html#required-packages-for-the-host-development-system
RUN apt-get install -y gawk wget git-core diffstat unzip texinfo gcc-multilib \
        build-essential chrpath socat cpio python3 python3-pip python3-pexpect python-is-python3 \
        xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev \
        pylint3 xterm xterm zstd liblz4-tool

# Additional host packages required by poky/scripts/wic
RUN apt-get install -y curl dosfstools mtools parted syslinux tree zip

# Add "repo" tool (used by many Yocto-based projects)
RUN curl http://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo
RUN chmod a+x /usr/local/bin/repo

# Create user "jenkins"
# RUN id jenkins 2>/dev/null || useradd --uid 1000 --create-home jenkins

#RUN groupadd --gid 1000 build \
#    && useradd --uid 1000 --gid 1000 -m build
# Create a non-root user that will perform the actual build
#RUN id build 2>/dev/null || useradd --uid 30000 --create-home build
#RUN apt-get install -y sudo
#RUN echo "build ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

RUN groupadd _1001 -g 1001 \
    && groupadd _1000 -g 1000 \
    && groupadd _2000 -g 2000 \
    && groupadd _999 -g 999 \
    && useradd -ms /bin/bash conan -g _1001 -G _1000,_2000,_999 \
    && printf "conan:conan" | chpasswd

# Fix error "Please use a locale setting which supports utf-8."
# See https://wiki.yoctoproject.org/wiki/TipsAndTricks/ResolvingLocaleIssues
RUN apt-get install -y locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
        echo 'LANG="en_US.UTF-8"'>/etc/default/locale && \
        dpkg-reconfigure --frontend=noninteractive locales && \
        update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

USER conan
WORKDIR /home/conan
CMD "/bin/bash"
