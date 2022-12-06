ARG CI_REGISTRY_IMAGE
ARG TAG
ARG DOCKERFS_TYPE
ARG DOCKERFS_VERSION
FROM ${CI_REGISTRY_IMAGE}/${DOCKERFS_TYPE}:${DOCKERFS_VERSION}${TAG}
LABEL maintainer="nathalie.casati@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG CARD
ARG CI_REGISTRY
ARG APP_NAME
ARG APP_VERSION

LABEL app_version=$APP_VERSION
LABEL app_tag=$TAG

WORKDIR /apps/${APP_NAME}

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \ 
    curl unzip libgomp1 libgtk-3-0 libglib2.0-0 \
    libglib2.0-0 dbus-x11 at-spi2-core && \
    curl -OL# https://github.com/hbp-HiBoP/HiBoP/releases/download/${APP_VERSION}/HiBoP.${APP_VERSION}.linux64.zip && \
    mkdir ./install && \
    unzip -q -d ./install HiBoP.${APP_VERSION}.linux64.zip && \
    chmod 755 ./install/HiBoP.${APP_VERSION}.linux64/HiBoP.x86_64 && \
    rm HiBoP.${APP_VERSION}.linux64.zip && \
    apt-get remove -y --purge curl unzip && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV APP_SPECIAL="no"
ENV APP_CMD="/apps/${APP_NAME}/install/HiBoP.${APP_VERSION}.linux64/HiBoP.x86_64"
ENV PROCESS_NAME="/apps/${APP_NAME}/install/HiBoP.${APP_VERSION}.linux64/HiBoP.x86_64"
ENV APP_DATA_DIR_ARRAY=".config/unity3d"
ENV DATA_DIR_ARRAY=""

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/

ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
