FROM debian:bullseye-slim as build

WORKDIR /build

RUN apt-get update && apt-get install --no-install-recommends --no-install-suggests -y \
    ca-certificates git build-essential debhelper libusb-1.0-0-dev \
    librtlsdr-dev librtlsdr0 pkg-config \
    libncurses-dev zlib1g-dev zlib1g

RUN git clone --depth 1 https://github.com/wiedehopf/readsb.git -b stale

WORKDIR /build/readsb

RUN DEB_BUILD_OPTIONS=noddebs RTLSDR=yes STATIC=yes make readsb



FROM debian:bullseye-slim

WORKDIR /app

RUN apt-get update && apt-get upgrade -y && apt-get install libncurses6 libusb-1.0-0 -y

COPY --from=build /build/readsb/readsb /app/readsb

EXPOSE 30005

ENTRYPOINT [ ./readsb $RECEIVER_OPTIONS $DECODER_OPTIONS $NET_OPTIONS $JSON_OPTIONS ]

