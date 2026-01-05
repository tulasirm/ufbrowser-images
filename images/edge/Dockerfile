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

# 3. Microsoft Edge Stable
RUN wget -q -O - https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
    && install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/ \
    && sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-dev.list' \
    && rm microsoft.gpg \
    && apt-get update && apt-get install -y --no-install-recommends \
    microsoft-edge-stable \
    && rm -rf /var/lib/apt/lists/*

# Msedgedriver
# Note: For Edge we typically rely on Selenium Manager or manual fetch if version matching is needed. 
# We'll skip pre-installing driver binary here to keep it simple unless requested, or user can use Playwright.
# (If user uses Selenium/Python 4.10+, driver management is automatic).

# 4. (Playwright removed)

# 5. Setup Scripts
COPY common/scripts /opt/bin/
RUN chmod +x /opt/bin/*.sh

# 6. Configuration
COPY images/edge/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 7. Entrypoint
ENTRYPOINT ["/opt/bin/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
