FROM ubuntu:22.04

# Environment Variables
ENV DEBIAN_FRONTEND=noninteractive \
    resolutions="1920x1080x24" \
    RESOLUTION="1920x1080x24" \
    DISPLAY=":99" \
    NOVNC_HOME="/opt/novnc" \
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright \
    # Skip downloading all Playwright browsers, we will install only relevant one or rely on system
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

# 1. Base Essentials & Display Layer
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

# 2. NoVNC Installation
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /opt/novnc \
    && git clone --depth 1 https://github.com/novnc/websockify /opt/novnc/utils/websockify \
    && ln -s /opt/novnc/vnc.html /opt/novnc/index.html

# 3. Google Chrome & Driver (Selenium Support)
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update && apt-get install -y --no-install-recommends \
    google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*



# 4. (Playwright removed as per request)

# 5. Setup Scripts
COPY common/scripts /opt/bin/
RUN chmod +x /opt/bin/*.sh

# 6. Configuration
COPY images/chrome/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 7. Entrypoint
ENTRYPOINT ["/opt/bin/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
