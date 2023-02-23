FROM --platform=$BUILDPLATFORM debian:latest as base
WORKDIR /app
ARG TARGETARCH
ARG RUST_VERSION=1.60
ARG SOLANA_VERSION=1.14.16

RUN dpkg --add-architecture ${TARGETARCH}

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y curl git libssl-dev libudev-dev pkg-config zlib1g-dev llvm clang cmake make libprotobuf-dev protobuf-compiler gcc-multilib

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup component add rustfmt
RUN rustup install ${RUST_VERSION}

RUN git clone https://github.com/solana-labs/solana.git
WORKDIR /app/solana
RUN git checkout tags/v${SOLANA_VERSION} -b ${SOLANA_VERSION}


FROM base as build-amd64
ARG RUST_TARGET=x86_64-unknown-linux-gnu
RUN ./cargo build --release --target ${RUST_TARGET}


FROM base as build-arm64
ARG RUST_TARGET=aarch64-unknown-linux-gnu

ENV SYSROOT=/usr/aarch64-linux-gnu
ENV PKG_CONFIG_ALLOW_CROSS=1
ENV PKG_CONFIG_LIBDIR=/usr/lib/aarch64-linux-gnu/pkgconfig
ENV PKG_CONFIG_SYSROOT_DIR=/usr/aarch64-linux-gnu
ENV PKG_CONFIG_SYSTEM_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu
ENV PKG_CONFIG_SYSTEM_INCLUDE_PATH=/usr/aarch64-linux-gnu/include

RUN rustup target add --toolchain ${RUST_VERSION} ${RUST_TARGET}
RUN apt-get install -y libudev-dev:arm64
RUN apt-get install -y gcc-aarch64-linux-gnu g++-aarch64-linux-gnu

RUN CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=/usr/bin/aarch64-linux-gnu-gcc ./cargo build --release --target ${RUST_TARGET}


FROM build-${TARGETARCH} as binaries

WORKDIR /app/solana/bin

RUN cp -fr /app/solana/target/${RUST_TARGET}/release/. .


FROM debian:latest as final

EXPOSE 8899/tcp
# RPC pubsub
EXPOSE 8900/tcp
# entrypoint
EXPOSE 8001/tcp
# (future) bank service
EXPOSE 8901/tcp
# bank service
EXPOSE 8902/tcp
# faucet
EXPOSE 9900/tcp
# tvu
EXPOSE 8000/udp
# gossip
EXPOSE 8001/udp
# tvu_forwards
EXPOSE 8002/udp
# tpu
EXPOSE 8003/udp
# tpu_forwards
EXPOSE 8004/udp
# retransmit
EXPOSE 8005/udp
# repair
EXPOSE 8006/udp
# serve_repair
EXPOSE 8007/udp
# broadcast
EXPOSE 8008/udp
# tpu_vote
EXPOSE 8009/udp

WORKDIR /solana

RUN apt-get update
RUN apt-get install  -y bzip2

COPY --from=binaries /app/solana/bin ./bin

ENV PATH="/solana"/bin:"$PATH"

CMD ["solana-test-validator", "--reset"]
