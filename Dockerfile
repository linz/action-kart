FROM ghcr.io/osgeo/gdal:ubuntu-full-3.11.3@sha256:984938ae4ffda015d5e806a8048eb29fc4eeddaf97ada04e627f7f27b51feddb

ARG KART_VERSION=0.16.1

RUN wget https://github.com/koordinates/kart/releases/download/v${KART_VERSION}/Kart-${KART_VERSION}-linux-x86_64.tar.gz  && \
  tar xvf Kart-${KART_VERSION}-linux-x86_64.tar.gz  && \
  mv Kart-${KART_VERSION}-linux-x86_64/kart /opt/kart && \
  rm -fr Kart-${KART_VERSION}-linux-x86_64/ Kart-${KART_VERSION}-linux-x86_64.tar.gz

ENV PATH="/opt/kart:${PATH}"

RUN kart --version
RUN gdal --version