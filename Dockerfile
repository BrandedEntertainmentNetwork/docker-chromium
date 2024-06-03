FROM debian:bookworm
LABEL version="12.0"
LABEL description="Headless Chromium with rich font support."

ENV DEBIAN_FRONTEND noninteractive

ENV APT_PACKAGES wget curl unzip apt-transport-https apt-utils ca-certificates  fontconfig

# Proper font support.
ENV FONT_MISC fonts-symbola fonts-ubuntu fonts-ubuntu-console ttf-bitstream-vera
ENV FONT_CHI fonts-arphic-ukai fonts-arphic-uming
ENV FONT_JPN fonts-ipafont-mincho fonts-ipafont-gothic
ENV FONT_KOR fonts-unfonts-core
ENV FONT_THA fonts-thai-tlwg
ENV FONT_EMOJI fonts-noto-color-emoji

ENV FONT_PACKAGES ${FONT_MISC} ${FONT_EMOJI} ${FONT_CHI} ${FONT_JPN} ${FONT_KOR} ${FONT_THA}

RUN mkdir -p /home/chromium && \
    groupadd --system chromium && \
    useradd --system --gid chromium chromium && \
    chown -R chromium:chromium /home/chromium

# Install fonts so we can render properly.
RUN apt-get update && \
    apt-get install --yes ${APT_PACKAGES} && \
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections && \
    echo "deb http://deb.debian.org/debian bookworm contrib non-free" > /etc/apt/sources.list.d/contrib.list && \
    apt-get update && \
    apt-get install --yes ttf-mscorefonts-installer ${FONT_PACKAGES} && \
    apt-get install --yes --no-install-recommends chromium && \
    fc-cache --force --verbose && \
    apt-get remove --yes ${APT_PACKAGES} && \
    rm -rf /var/lib/apt/lists/*

USER chromium

WORKDIR /home/chromium

EXPOSE 9222

ENTRYPOINT [ "/usr/bin/chromium", \
             "--headless", "--disable-gpu", "--no-sandbox", \
             "--remote-debugging-address=0.0.0.0", \
             "--remote-debugging-port=9222" ]
