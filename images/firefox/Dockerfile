FROM ubuntu:22.04

# Environment Variables
ENV DEBIAN_FRONTEND=noninteractive \
    resolutions="1920x1080x24" \
    RESOLUTION="1920x1080x24" \
    DISPLAY=":99" \
    NOVNC_HOME="/opt/novnc" \
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright \
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

# 1. Base Essentials
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    gnupg \
    ca-certificates \
    xvfb \
    fluxbox \
    x11vnc \
    supervisor \
    ffmpeg \
    python3 \
    python3-pip \
    python3-numpy \
    git \
    && rm -rf /var/lib/apt/lists/*

# 1.1 (Node.js removed)

# 2. NoVNC
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /opt/novnc \
    && git clone --depth 1 https://github.com/novnc/websockify /opt/novnc/utils/websockify \
    && ln -s /opt/novnc/vnc.html /opt/novnc/index.html

# 3. Firefox (Release PPA)
RUN install -d -m 0755 /etc/apt/keyrings \
    && wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null \
    && echo 'Package: *' > /etc/apt/preferences.d/mozilla \
    && echo 'Pin: origin packages.mozilla.org' >> /etc/apt/preferences.d/mozilla \
    && echo 'Pin-Priority: 1000' >> /etc/apt/preferences.d/mozilla \
    && apt-get update && apt-get install -y --no-install-recommends \
    firefox \
    && rm -rf /var/lib/apt/lists/*

# (Drivers removed)



# 4. (Playwright removed)

# 5. Setup Scripts
COPY common/scripts /opt/bin/
RUN chmod +x /opt/bin/*.sh

# 6. Configuration
COPY images/firefox/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 7. Entrypoint
ENTRYPOINT ["/opt/bin/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
