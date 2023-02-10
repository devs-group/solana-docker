FROM --platform=$BUILDPLATFORM debian:latest as base
WORKDIR /app
ARG TARGETARCH

RUN dpkg --add-architecture ${TARGETARCH}

RUN apt-get update && apt-get upgrade
RUN apt-get install -y curl git libssl-dev libudev-dev pkg-config zlib1g-dev llvm clang cmake make libprotobuf-dev protobuf-compiler gcc-multilib

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup component add rustfmt

ARG SOLANA_VERSION=1.14
RUN git clone https://github.com/solana-labs/solana.git
WORKDIR /app/solana
RUN git checkout origin/v${SOLANA_VERSION}


FROM base as build-amd64
ARG RUST_TARGET=x86_64-unknown-linux-gnu
RUN cargo build --release --target ${RUST_TARGET}


FROM base as build-arm64
ARG RUST_TARGET=aarch64-unknown-linux-gnu

ENV SYSROOT=/usr/aarch64-linux-gnu
ENV PKG_CONFIG_ALLOW_CROSS=1
ENV PKG_CONFIG_LIBDIR=/usr/lib/aarch64-linux-gnu/pkgconfig
ENV PKG_CONFIG_SYSROOT_DIR=/usr/aarch64-linux-gnu
ENV PKG_CONFIG_SYSTEM_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu
ENV PKG_CONFIG_SYSTEM_INCLUDE_PATH=/usr/aarch64-linux-gnu/include

RUN rustup target add ${RUST_TARGET}
RUN apt-get install -y libudev-dev:arm64
RUN apt-get install -y gcc-aarch64-linux-gnu g++-aarch64-linux-gnu

RUN CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=/usr/bin/aarch64-linux-gnu-gcc cargo build --release --target ${RUST_TARGET}


FROM alpine:3.17

WORKDIR /solana

COPY --from=build-${TARGETARCH} /app/solana/target/${RUST_TARGET}/release ./bin

ENV PATH="/solana"/bin:"$PATH"

CMD ["solana-test-validator", "--reset"]
