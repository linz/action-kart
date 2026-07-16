ARG UV_VERSION=0.9.16
FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv_source

FROM ghcr.io/osgeo/gdal:ubuntu-full-latest@sha256:4e1e948152523520c1d479ce852e494c5cdbe34e27d00a67b66a66810da8c8c8

ARG GIT_VERSION
ENV GIT_VERSION=${GIT_VERSION}

ARG GIT_HASH=unknown
ENV GIT_HASH=${GIT_HASH}

ARG KART_VERSION=0.17.1

ENV KART_ALLOW_FROM_GIT=1

COPY --from=uv_source /uv /uvx /bin/

RUN apt-get update && apt-get install -y jq software-properties-common wget

# Get the latest GIT
RUN add-apt-repository ppa:git-core/ppa -y && apt update && apt install git -y

# Install Node.js 24
RUN wget -qO- https://deb.nodesource.com/setup_24.x | bash - && apt-get install -y nodejs

RUN wget https://github.com/koordinates/kart/releases/download/v${KART_VERSION}/Kart-${KART_VERSION}-linux-x86_64.tar.gz  && \
  tar xvf Kart-${KART_VERSION}-linux-x86_64.tar.gz && \
  mv Kart-${KART_VERSION}-linux-x86_64/kart /opt/kart && \
  rm -fr Kart-${KART_VERSION}-linux-x86_64/ Kart-${KART_VERSION}-linux-x86_64.tar.gz

ENV PATH="/opt/kart:${PATH}"

RUN kart --version
RUN gdal --version
RUN jq --version
RUN git --version
RUN uv --version
RUN node --version