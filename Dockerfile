# syntax=docker/dockerfile:1
ARG BASE_IMAGE=ubuntu:jammy
FROM $BASE_IMAGE AS builder
RUN apt-get update && apt-get install -y build-essential git libsdl2*-dev libdrm-dev libgbm-dev
WORKDIR /build
COPY . ./
ARG TARGET_SUBVARIANT
RUN <<EOF
  set -eu
  case "${TARGET_SUBVARIANT-}" in
    rpi?) sed -i "/#platform =/a platform = ${TARGET_SUBVARIANT}" Makefile.libretro ;;
  esac
  make clean -f Makefile.libretro
  make -f Makefile.libretro
  tar c -zf "$(uname -m)${TARGET_SUBVARIANT:+-${TARGET_SUBVARIANT}}.tar.gz" *.so
EOF

FROM scratch
COPY --from=builder /build/*.tar.gz ./
