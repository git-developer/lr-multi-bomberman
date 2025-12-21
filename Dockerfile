# syntax=docker/dockerfile:1
ARG BASE_IMAGE=ubuntu:jammy
FROM $BASE_IMAGE AS builder
RUN apt-get update && apt-get install -y build-essential git libsdl2*-dev libdrm-dev libgbm-dev
WORKDIR /build
COPY . ./
ARG LR_PLATFORM
RUN <<EOF
  set -eu
  case "${LR_PLATFORM}" in
    rpi?) sed -i "/#platform =/a platform = ${LR_PLATFORM}" Makefile.libretro ;;
  esac
  make clean -f Makefile.libretro
  make -f Makefile.libretro
EOF

FROM scratch
COPY --from=builder /build/*.so ./
