FROM rust AS build
LABEL lighthouse.base=rust

ARG DEBIAN_FRONTEND="noninteractive"

WORKDIR /build

RUN apt-get update
RUN apt-get install --yes protobuf-compiler
ENV PROTOC=/usr/bin/protoc
RUN --mount=type=cache,target=/app/target/ \
    --mount=type=cache,target=/usr/local/cargo/registry/

RUN set -e
# RUN mkdir /translations
# ENV RUST_BACKTRACE=1
# ENV EXTRA_FTL_ROOT=/translations
# RUN git clone https://github.com/ankitects/anki.git --branch 2.1.66 .
# RUN cargo build -r --bin anki-sync-server
# RUN cp ./target/release/anki-sync-server /anki-sync-server
RUN cargo install --git https://github.com/ankitects/anki.git --tag 23.12.1 anki-sync-server
# RUN type anki-sync-server && false
# EOF

FROM debian:stable-slim AS final
LABEL lighthouse.base=debian:stable-slim

COPY --from=build /usr/local/cargo/bin/anki-sync-server /

RUN apt-get update
RUN apt-get install --yes curl

HEALTHCHECK --interval=30s --timeout=3s CMD curl localhost:8080 || exit 1

EXPOSE 8080

ENTRYPOINT ["/anki-sync-server"]
