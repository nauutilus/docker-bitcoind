# Smallest base image, latests stable image
# Alpine would be nice, but it's linked again musl and breaks the bitcoin core download binary
#FROM alpine:latest
FROM ubuntu:latest

LABEL maintainer="Kyle Manna <kyle@kylemanna.com>"

EXPOSE 8332 8333
VOLUME ["/bitcoin"]

ENTRYPOINT ["docker-entrypoint.sh"]
ENV HOME /bitcoin
ENV LND_SUPPORT=false

ARG GROUP_ID=1000
ARG USER_ID=1000
RUN groupadd -g ${GROUP_ID} bitcoin \
    && useradd -u ${USER_ID} -g bitcoin -d /bitcoin bitcoin

# Testing: gosu
#RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories \
#    && apk add --update --no-cache gnupg gosu gcompat libgcc
RUN apt update \
    && apt install -y --no-install-recommends \
        ca-certificates \
        gosu \
        wget \
        gnupg \
    && apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG VERSION=0.20.1
ARG ARCH=x86_64
ARG BITCOIN_CORE_SIGNATURE=01EA5486DE18A882D4C2684590C8019E36C2E964

# Don't use base image's bitcoin package for a few reasons:
# 1. Would need to use ppa/latest repo for the latest release.
# 2. Some package generates /etc/bitcoin.conf on install and that's dangerous to bake in with Docker Hub.
# 3. Verifying pkg signature from main website should inspire confidence and reduce chance of surprises.
# Instead fetch, verify, and extract to Docker image
RUN cd /tmp \
    && wget https://bitcoincore.org/bin/bitcoin-core-${VERSION}/SHA256SUMS.asc \
    && gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys ${BITCOIN_CORE_SIGNATURE} \
    && gpg --verify SHA256SUMS.asc \
    && grep bitcoin-${VERSION}-${ARCH}-linux-gnu.tar.gz SHA256SUMS.asc > SHA25SUM \
    && wget https://bitcoincore.org/bin/bitcoin-core-0.20.1/bitcoin-${VERSION}-${ARCH}-linux-gnu.tar.gz \
    && sha256sum -c SHA25SUM \
    && tar -xzvf bitcoin-${VERSION}-${ARCH}-linux-gnu.tar.gz -C /opt \
    && ln -sv bitcoin-${VERSION} /opt/bitcoin \
    && ln -sv /opt/bitcoin/bin/* /usr/local/bin

ADD ./bin docker-entrypoint.sh /usr/local/bin/

WORKDIR /bitcoin
CMD ["btc_oneshot"]
