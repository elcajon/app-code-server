ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base:9.4.0

# Everything that is only downloaded and unpacked is done on the build
# platform instead of the target platform, so it does not run through QEMU
# emulation when building for a foreign architecture. The results are copied
# into the final image further down.
# hadolint ignore=DL3006,DL3029
FROM --platform=${BUILDPLATFORM} ${BUILD_FROM} AS fetch

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG BUILD_ARCH=amd64
ARG CODE_SERVER_VERSION="v4.137.0"
ARG HA_CLI_VERSION="5.5.0"
ARG TAILSCALE_VERSION="v1.102.4"
ARG YQ_VERSION="v4.53.6"

# Tooling needed to download and unpack, never part of the final image
# hadolint ignore=DL3008
RUN \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        libarchive-tools \
    \
    && rm -fr /var/lib/apt/lists/*

# Code Server
# hadolint ignore=DL3059
RUN \
    ARCH="${BUILD_ARCH}" \
    && if [[ "${BUILD_ARCH}" = "aarch64" ]]; then ARCH="arm64"; fi \
    \
    && mkdir -p /out/usr/local/lib/code-server \
    && curl -J -L -f -o /tmp/code.tar.gz \
        "https://github.com/coder/code-server/releases/download/${CODE_SERVER_VERSION}/code-server-${CODE_SERVER_VERSION#v}-linux-${ARCH}.tar.gz" \
    && tar zxf \
        /tmp/code.tar.gz \
        --strip 1 -C /out/usr/local/lib/code-server \
    && rm -f /tmp/code.tar.gz

# Copy in extensions list
COPY code-server.extensions /etc/code-server.extensions

# Code Server extensions
RUN \
    uuid="$(cat /proc/sys/kernel/random/uuid)" \
    && while read -r ext; do \
        extension="${ext%%#*}"; \
        vendor="${extension%%.*}"; \
        slug="${extension#*.}"; \
        version="${ext##*#}"; \
        target="/out/usr/local/lib/code-server/lib/vscode/extensions/${extension}-${version}"; \
        \
        echo "Installing Code Server extension: ${slug} by ${vendor} @ ${version}"; \
        \
        curl -J -L -f --retry 5 -o "/tmp/${extension}-${version}.vsix" \
            -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36" \
            -H "x-market-user-id: ${uuid}" \
            "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/${vendor}/vsextensions/${slug}/${version}/vspackage" \
            || exit 1; \
        mkdir -p "${target}"; \
        bsdtar --strip-components=1 -xf "/tmp/${extension}-${version}.vsix" \
            -C "${target}" extension \
            || exit 1; \
        rm -f "/tmp/${extension}-${version}.vsix"; \
    done < /etc/code-server.extensions \
    && ls -la /out/usr/local/lib/code-server/lib/vscode/extensions/

# Home Assistant CLI, Tailscale and yq
# hadolint ignore=DL3059
RUN \
    ARCH="${BUILD_ARCH}" \
    && if [[ "${BUILD_ARCH}" = "aarch64" ]]; then ARCH="arm64"; fi \
    \
    && mkdir -p /out/usr/bin /out/opt \
    \
    && curl -L -f -s -o /out/usr/bin/ha \
        "https://github.com/home-assistant/cli/releases/download/${HA_CLI_VERSION}/ha_${BUILD_ARCH}" \
    && chmod a+x /out/usr/bin/ha \
    \
    && curl -L -f -s \
        "https://pkgs.tailscale.com/stable/tailscale_${TAILSCALE_VERSION#v}_${ARCH}.tgz" \
        | tar zxf - -C /out/opt/ --strip-components 1 \
    \
    && curl -J -L -f -s -o /out/usr/bin/yq \
        "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${ARCH}" \
    && chmod +x /out/usr/bin/yq

# Oh My Zsh and its plugins
# hadolint ignore=DL3059
RUN \
    git clone --branch master --single-branch --depth 1 \
        "https://github.com/robbyrussell/oh-my-zsh.git" /out/root/.oh-my-zsh \
    \
    && git clone --branch master --single-branch --depth 1 \
        "https://github.com/zsh-users/zsh-autosuggestions" \
        /out/root/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && git clone --branch master --single-branch --depth 1 \
        "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
        /out/root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Confiure locale
ENV \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    PIP_BREAK_SYSTEM_PACKAGES=1 \
    S6_VERBOSITY="1"

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Copy Python requirements file
COPY requirements.txt /tmp/requirements.txt

# Setup base system
# renovate: datasource=deb depName=build-essential versioning=deb
ARG build_essential_version="12.12"
# renovate: datasource=deb depName=locales versioning=deb
ARG locales_version="2.41-12+deb13u4"
# renovate: datasource=deb depName=gnupg versioning=deb
ARG gnupg_version="2.4.7-21+deb13u1"
# renovate: datasource=deb depName=openssh-server versioning=deb
ARG openssh_server_version="1:10.0p1-7+deb13u4"
# renovate: datasource=deb depName=openssh-client versioning=deb
ARG openssh_client_version="1:10.0p1-7+deb13u4"
# renovate: datasource=deb depName=docker-ce-cli versioning=deb
ARG docker_ce_cli_version="5:29.8.1-1~debian.13~trixie"

# hadolint ignore=DL3008
RUN \
    apt-get update \
    \
    && apt-get install -y --no-install-recommends \
        ack=3.8.1-1 \
        build-essential="${build_essential_version}" \
        colordiff=1.0.21-1 \
        git=1:2.47.3-0+deb13u1 \
        iputils-ping=3:20240905-3 \
        locales="${locales_version}" \
        mariadb-client=1:11.8.6-0+deb13u1 \
        mosquitto-clients=2.0.21-1 \
        net-tools=2.10-1.3 \
        nmap=7.95+dfsg-3 \
        openssh-client="${openssh_client_version}" \
        openssl=3.5.7-1~deb13u2 \
        python3-dev=3.13.5-1 \
        python3=3.13.5-1 \
        unzip=6.0-29+deb13u1 \
        "wget>=1.25.0-2" \
        zip=3.0-15+deb13u1 \
        zsh=5.9-8+b24 \
        less=668-1 \
        nano=8.4-1+deb13u1 \
        apt-transport-https=3.0.3 \
        gnupg="${gnupg_version}" \
        cron=3.0pl1-197 \
        lsb-release=12.1-1 \
        openssh-server="${openssh_server_version}" \
        "git-crypt>=0.7.0-0.1+b1" \
        php=2:8.4+96 \
        php-curl=2:8.4+96 \
        netcat-openbsd=1.229-1 \
        htop=3.4.1-5 \
        shellcheck=0.10.0-1 \
    \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    \
    && curl https://bootstrap.pypa.io/get-pip.py | python3 \
    && update-alternatives \
        --install /usr/bin/python python /usr/bin/python3 10 \
    && pip3 install --no-cache-dir --no-compile -r /tmp/requirements.txt \
    \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg &> /dev/null \
    && echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list \
    \
    && curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
        gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
        tee /etc/apt/sources.list.d/1password.list \
    \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        docker-ce-cli="${docker_ce_cli_version}" \
        1password-cli \
    \
    && mv /usr/bin/docker /usr/local/bin/.undocked \
    \
    && sed -i -e "s#bin/bash#bin/zsh#" /etc/passwd \
    \
    && apt-get purge -y --auto-remove \
        build-essential \
        python3-dev \
    \
    && find /usr/local \
        \( -type d -a -name test -o -name tests -o -name '__pycache__' \) \
        -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
        -exec rm -rf '{}' + \
    \
    && rm -fr \
        /root/.cache \
        /tmp/* \
        /var/{cache,log}/* \
        /var/lib/apt/lists/* \
    \
    && touch /var/log/lastlog \
    \
    && rm -fr \
        /etc/cron.d/* \
        /etc/cron.daily/*

# Everything fetched on the build platform. Kept after the package layer so
# that a version bump here does not invalidate it.
COPY --from=fetch /out/usr/local/lib/code-server /usr/local/lib/code-server
COPY --from=fetch /out/usr/bin/ha /out/usr/bin/yq /usr/bin/
COPY --from=fetch /out/opt /opt
COPY --from=fetch /out/root/.oh-my-zsh /root/.oh-my-zsh

RUN \
    ln -s /usr/local/lib/code-server/bin/code-server /usr/local/bin/code-server \
    && ln -s /opt/tailscale /usr/local/bin/ \
    && ln -s /opt/tailscaled /usr/local/bin/ \
    && mkdir -p /root/.code-server/extensions

# Copy root filesystem
COPY rootfs /

# Health check
HEALTHCHECK \
    CMD curl --fail http://127.0.0.1:1337/healthz || exit 1

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Elcajon" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Home Assistant App" \
    org.opencontainers.image.authors="Elcajon" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/elcajon-dev/repository-stable" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
