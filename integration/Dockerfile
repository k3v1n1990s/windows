# syntax=docker/dockerfile:1.7
ARG BASE_IMAGE=ghcr.io/dockur/windows@sha256:16fd7c39a3e48bb946d29c59dc6015942e5b900a1fa5d7e5552053bfc48ee2ea
FROM debian:trixie-slim AS builder
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git ninja-build python3 python3-venv python3-pip pkg-config \
    libglib2.0-dev libpixman-1-dev libslirp-dev libusb-1.0-0-dev \
    libusbredirparser-dev libaio-dev liburing-dev libcap-ng-dev libfdt-dev \
    libgnutls28-dev libepoxy-dev libzstd-dev zlib1g-dev libattr1-dev libcap-dev \
    && rm -rf /var/lib/apt/lists/*
ADD --checksum=sha256:784b296ff29c1417aa72323abcb2d2ea9ab9771724f577dcd785c3b04f21e176 \
    https://download.qemu.org/qemu-10.2.2.tar.xz /tmp/qemu.tar.xz
COPY integration/patches/qemu-10.2.2.patch /tmp/qemu.patch
RUN mkdir /tmp/qemu && tar -xJf /tmp/qemu.tar.xz -C /tmp/qemu --strip-components=1 \
    && cd /tmp/qemu && git apply --check /tmp/qemu.patch && git apply /tmp/qemu.patch \
    && ./configure --prefix=/opt/qemu-zhaodice --target-list=x86_64-softmmu \
       --enable-kvm --enable-vnc --enable-slirp --enable-libusb --enable-usb-redir \
       --enable-virtfs --disable-docs --disable-guest-agent --disable-werror --disable-modules \
    && ninja -C build -j4 && ninja -C build install
FROM ${BASE_IMAGE}
USER root
COPY --from=builder /opt/qemu-zhaodice /opt/qemu-zhaodice
RUN rm /usr/bin/qemu-system-x86_64 \
    && ln -s /opt/qemu-zhaodice/bin/qemu-system-x86_64 /usr/bin/qemu-system-x86_64 \
    && qemu-system-x86_64 --version \
    && ! ldd /opt/qemu-zhaodice/bin/qemu-system-x86_64 | grep 'not found'
LABEL org.opencontainers.image.description="Windows for WinApps with QEMU 10.2.2 and zhaodice patch" \
      io.local.qemu.version="10.2.2" \
      io.local.qemu.patch.commit="2750c86d2d045243ba6617951487e41b25c05557" \
      io.local.qemu.patch.sha256="0d05f1a0ced91cef3fe33203b7d81c955d64694f30085544dc5e154809da110e"
