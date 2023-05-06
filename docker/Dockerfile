# See supported distros here: https://docs.yoctoproject.org/current/ref-manual/system-requirements.html#supported-linux-distributions
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN apt-get update && \
    # Install the packages from https://docs.yoctoproject.org/current/brief-yoctoprojectqs/index.html
    apt-get install -y findutils file gawk wget git diffstat unzip texinfo gcc build-essential chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev pylint xterm python3-subunit mesa-common-dev zstd liblz4-tool locales && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    useradd builder && \
    mkdir -p /home/builder/.cache

ENV YOCTO_VERSION_NAME=langdale
ENV YOCTO_VERSION_NUMBER=4.1.3
ENV YOCTO_RELEASE="${YOCTO_VERSION_NAME}-${YOCTO_VERSION_NUMBER}"
RUN git clone -b "${YOCTO_RELEASE}" --depth 1 git://git.yoctoproject.org/poky.git /poky

WORKDIR /poky
RUN scripts/install-buildtools --without-extended-buildtools --base-url https://downloads.yoctoproject.org/releases/yocto --release "yocto-${YOCTO_VERSION_NUMBER}" --installer-version "${YOCTO_VERSION_NUMBER}" && \
    chown -R builder:builder . /home/builder/.cache

COPY ./entrypoint.sh /entrypoint.sh

USER builder
RUN git clone --branch "${YOCTO_VERSION_NAME}" --depth=1 https://github.com/kraj/meta-clang.git && \
    git clone --branch "${YOCTO_VERSION_NAME}" --depth=1 git://git.yoctoproject.org/meta-intel && \
    git clone --branch "${YOCTO_VERSION_NAME}" --depth=1 git://git.yoctoproject.org/meta-raspberrypi && \
    git clone --branch "${YOCTO_VERSION_NAME}" --depth=1 git://git.yoctoproject.org/meta-virtualization && \
    git clone --branch "${YOCTO_VERSION_NAME}" --depth=1 git://git.openembedded.org/meta-openembedded

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
