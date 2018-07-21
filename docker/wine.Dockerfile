FROM vsiri/recipe:gosu as gosu
FROM vsiri/recipe:tini-alpine as tini
FROM vsiri/recipe:vsi as vsi

# FROM fedora:28

# SHELL ["/usr/bin/env", "bash", "-euxvc"]

# RUN dnf install -y wine; \
#     dnf clean all

FROM alpine:3.8

SHELL ["/usr/bin/env", "sh", "-euxvc"]

RUN apk add --no-cache wine ncurses bash freetype

ARG WINE_MONO_VERSION=4.7.1
ARG WINE_GECKO_VERSION=2.47

RUN apk add --no-cache --virtual .deps curl; \
    export WINEPREFIX=/home/wine; \
    mkdir -p /root/.cache/wine; \
    cd /root/.cache/wine; \
    curl -LO http://dl.winehq.org/wine/wine-mono/${WINE_MONO_VERSION}/wine-mono-${WINE_MONO_VERSION}.msi; \
    curl -LO http://dl.winehq.org/wine/wine-gecko/${WINE_GECKO_VERSION}/wine_gecko-${WINE_GECKO_VERSION}-x86.msi; \
    curl -LO http://dl.winehq.org/wine/wine-gecko/${WINE_GECKO_VERSION}/wine_gecko-${WINE_GECKO_VERSION}-x86_64.msi; \
    wineboot; \
    wineserver -w; \
    cd /; \
    rm -rf /root/.cache; \
    apk del .deps

COPY --from=tini /usr/local/bin/tini /usr/local/bin/tini
COPY --from=gosu /usr/local/bin/gosu /usr/local/bin/gosu
# Allow non-privileged to run gosu (remove this to take root away from user)
RUN chmod u+s /usr/local/bin/gosu
COPY --from=vsi /vsi /vsi
ADD docker/wine_entrypoint.bsh /

# Not sure if this is necessary, but it's never bad
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    TERM=xterm-256color \
    WINEPREFIX=/home/wine

ENTRYPOINT ["/usr/local/bin/tini", "/usr/bin/env", "bash", "/wine_entrypoint.bsh"]
# Does not require execute permissions, unlike:
# ENTRYPOINT ["/usr/local/bin/tini", "/wine_entrypoint.bsh"]

CMD ["wine"]
