ARG BUILDARCH=amd64
FROM --platform=linux/${BUILDARCH} rust:latest as build

WORKDIR /app

RUN apt-get update
RUN apt-get install -y wget libssl-dev libudev-dev zlib1g-dev llvm clang cmake make libprotobuf-dev protobuf-compiler
RUN 8 | apt-get install -y pkg-config

RUN rustup component add rustfmt

ARG SOLANA_VERSION=1.14.13
RUN wget -O /app/solana.tar.gz https://github.com/solana-labs/solana/archive/refs/tags/v${SOLANA_VERSION}.tar.gz

RUN mkdir solana; tar -C solana --strip-components=1 -xvf solana.tar.gz
RUN cd solana; ./scripts/cargo-install-all.sh .

FROM --platform=linux/$BUILD_ARCHITECTURE ubuntu:20.04 as final

WORKDIR /app

COPY --from=build /app/solana ./solana

ENV PATH=/app/solana/bin:$PATH

CMD ["solana-test-validator", "--reset"]