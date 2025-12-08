FROM ghcr.io/osgeo/gdal:ubuntu-full-3.12.0

ARG GIT_VERSION
ENV GIT_VERSION=${GIT_VERSION}

ARG GIT_HASH=unknown
ENV GIT_HASH=${GIT_HASH}

ARG KART_VERSION=0.17.0
ARG UV_VERSION=0.9.16

COPY --from=ghcr.io/astral-sh/uv:${UV_VERSION} /uv /uvx /bin/

RUN apt-get update && apt-get install -y jq software-properties-common wget

# Get the latest GIT
RUN add-apt-repository ppa:git-core/ppa -y && apt update && apt install git -y

RUN wget https://github.com/koordinates/kart/releases/download/v${KART_VERSION}/Kart-${KART_VERSION}-linux-x86_64.tar.gz  && \
  tar xvf Kart-${KART_VERSION}-linux-x86_64.tar.gz  && \
  mv Kart-${KART_VERSION}-linux-x86_64/kart /opt/kart && \
  rm -fr Kart-${KART_VERSION}-linux-x86_64/ Kart-${KART_VERSION}-linux-x86_64.tar.gz

ENV PATH="/opt/kart:${PATH}"

RUN kart --version
RUN gdal --version
RUN jq --version
RUN git --version
RUN uv --version