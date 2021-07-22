FROM ubuntu:20.04

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get -y update && apt-get -y upgrade && apt-get install -y software-properties-common && \
        add-apt-repository ppa:rock-core/qt4 && \
        apt-get install -y tzdata git p7zip-full p7zip-rar \
        aria2 curl pv jq ffmpeg python3 python3-pip unzip \
        locales python3-lxml g++ gcc autoconf automake \
        m4 libtool qt4-qmake make libqt4-dev libcurl4-openssl-dev \
        libcrypto++-dev libsqlite3-dev libc-ares-dev \
        libsodium-dev libnautilus-extension-dev \
        libssl-dev libfreeimage-dev swig && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/cache/apt/archives/* /var/tmp/* /etc/apt/sources.list.d/*
        
RUN apt-get purge -y software-properties-common && apt-get -y update && \
        apt-get -y upgrade && apt-get -y autoremove && apt-get -y autoclean

# Installing mega sdk python binding
ENV MEGA_SDK_VERSION="3.9.2"
RUN git clone https://github.com/meganz/sdk.git sdk && cd sdk \
    && git checkout v$MEGA_SDK_VERSION \
    && ./autogen.sh && ./configure --disable-silent-rules --enable-python --with-sodium --disable-examples \
    && make -j$(nproc --all) \
    && cd bindings/python/ && python3 setup.py bdist_wheel \
    && cd dist/ && pip3 install --no-cache-dir megasdk-$MEGA_SDK_VERSION-*.whl \
    && cd ~
    
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /usr/src/app
RUN chmod 777 /usr/src/app

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt
