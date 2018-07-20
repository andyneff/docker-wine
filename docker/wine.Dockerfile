FROM vsiri/recipe:gosu as gosu
FROM vsiri/recipe:tini as tini
FROM vsiri/recipe:vsi as vsi

FROM debian:stretch

SHELL ["/usr/bin/env", "bash", "-euxvc"]

# Example of installing packages
RUN build_deps="wget ca-certificates"; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ${build_deps} python3; \
    wget -q https://www.vsi-ri.com/bin/deviceQuery; \
    DEBIAN_FRONTEND=noninteractive apt-get purge -y --autoremove ${build_deps}; \
    rm -rf /var/lib/apt/lists/*

COPY --from=tini /usr/local/bin/tini /usr/local/bin/tini

COPY --from=gosu /usr/local/bin/gosu /usr/local/bin/gosu
# Allow non-privileged to run gosu (remove this to take root away from user)
RUN chmod u+s /usr/local/bin/gosu

COPY --from=vsi /vsi /vsi
ADD docker/wine_entrypoint.bsh /

ENTRYPOINT ["/usr/local/bin/tini", "/usr/bin/env", "bash", "/wine_entrypoint.bsh"]
# Does not require execute permissions, unlike:
# ENTRYPOINT ["/usr/local/bin/tini", "/wine_entrypoint.bsh"]

CMD ["wine"]
