# syntax=docker/dockerfile:1
ARG BASE_IMAGE=ubuntu:jammy
FROM $BASE_IMAGE AS builder
RUN apt-get update && apt-get install -y build-essential git libsdl2*-dev libdrm-dev libgbm-dev
WORKDIR /build
COPY . ./
ARG BUILD_PLATFORM
RUN <<EOF
  set -eu
  platform="${BUILD_PLATFORM:-$(uname -m)}"
  case "${platform}" in
    rpi?) sed -i "/#platform =/a platform = ${platform}" Makefile.libretro ;;
  esac
  make clean -f Makefile.libretro
  make -f Makefile.libretro
  tar c -zf "${platform}.tar.gz" *.so
EOF

FROM scratch
COPY --from=builder /build/*.tar.gz ./
