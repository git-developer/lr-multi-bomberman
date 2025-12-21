# syntax=docker/dockerfile:1
ARG BASE_OS=ubuntu
ARG BASE_CODENAME=jammy
ARG TARGET_ARCH
FROM $BASE_OS:$BASE_CODENAME AS builder
ARG TARGET_ARCH
RUN apt-get update && apt-get install -y build-essential git libsdl2*-dev libdrm-dev libgbm-dev
WORKDIR /build
COPY . ./
RUN <<EOF
  case "${TARGET_ARCH}" in
    rpi?) sed -i "/#platform =/a platform = ${TARGET_ARCH}/" Makefile.libretro ;;
  esac
  make clean -f Makefile.libretro
  make -f Makefile.libretro
EOF

FROM scratch
COPY --from=builder /build/*.so ./
