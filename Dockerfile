FROM ghcr.io/astral-sh/uv:0.13.6@sha256:af22a52f5eafef3d78e551599d405c02df61919d18028f0cea8eda93bc9986d0 AS uv_source

FROM node:26-bookworm-slim@sha256:bc0a2afd3b74ce12222fc8bab99271e66257f021078f5f4a5d687a77d280c1d9 AS node_source

FROM ghcr.io/osgeo/gdal:ubuntu-full-3.13.1@sha256:aff1d5515aa0e9b50be34ab11d6c0c2cfabc23cdcb7a2e0bc5748101eedb3e4a

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

# Install Node.js
COPY --from=node_source /usr/local/bin/node /usr/local/bin/node
COPY --from=node_source /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

# Install Kart from local CI bundle if present, otherwise download release
COPY version.txt dist* /tmp/dist/
RUN if ls /tmp/dist/Kart-*.tar.gz 1> /dev/null 2>&1; then \
      echo "Installing Kart from dist bundle..." && \
      tar -xz -C /opt --strip-components=1 -f /tmp/dist/Kart-*.tar.gz; \
    else \
      echo "dist bundle not found, downloading Kart release v${KART_VERSION}..." && \
      wget https://github.com/koordinates/kart/releases/download/v${KART_VERSION}/Kart-${KART_VERSION}-linux-x86_64.tar.gz && \
      tar xvf Kart-${KART_VERSION}-linux-x86_64.tar.gz && \
      mv Kart-${KART_VERSION}-linux-x86_64/kart /opt/kart && \
      rm -fr Kart-${KART_VERSION}-linux-x86_64/ Kart-${KART_VERSION}-linux-x86_64.tar.gz; \
    fi && \
    rm -rf /tmp/dist

ENV PATH="/opt/kart:${PATH}"

RUN kart --version
RUN gdal --version
RUN jq --version
RUN git --version
RUN uv --version
RUN node --version