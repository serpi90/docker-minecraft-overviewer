FROM debian:stable-slim

LABEL maintainer="guillaume.connan44@gmail.com"
LABEL version="0.1.5"

ENV DEBIAN_FRONTEND noninteractive
ENV MC_VERSION 1.12.2

# Iinstall overviewer from repository
RUN apt-get update && \
    apt-get upgrade --assume-yes && \
    apt-get install --assume-yes curl gnupg apt-transport-https && \
    echo "deb https://overviewer.org/debian ./" >> /etc/apt/sources.list.d/overviewer.list && \
    curl --fail --silent --show-error --location https://overviewer.org/debian/overviewer.gpg.asc | apt-key add - && \
    apt-get update && \
    apt-get install --assume-yes minecraft-overviewer && \
    apt-get clean all

# Create overviewer user and download minecraft.jar (required for textures)
RUN mkdir --parents /in /out /temp/.minecraft/versions/$MC_VERSION/ /opt/overviewer && \
    groupadd --gid 1000 overviewer && \
    useradd --uid 1000 --shell /bin/false --home /temp --gid overviewer overviewer && \
    curl --fail --silent --show-error --location https://s3.amazonaws.com/Minecraft.Download/versions/$MC_VERSION/$MC_VERSION.jar > /temp/.minecraft/versions/$MC_VERSION/$MC_VERSION.jar && \
    chown --recursive overviewer:overviewer /temp /opt/overviewer /out

# Cleanup
RUN apt-get clean all && \
    apt-get purge --assume-yes curl gnupg apt-transport-https && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /opt/overviewer

ADD scripts/start.sh start.sh
RUN chmod a+x start.sh

USER overviewer

# Expose volumes
VOLUME ["/in", "/out"]

# Init
CMD ["/opt/overviewer/start.sh"]
