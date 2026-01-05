FROM ubuntu:22.04

# Environment Variables
ENV DEBIAN_FRONTEND=noninteractive \
    resolutions="1920x1080x24" \
    RESOLUTION="1920x1080x24" \
    DISPLAY=":99" \
    NOVNC_HOME="/opt/novnc" \
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

# 1. Base Essentials & Display Layer
# Install minimal dependencies for X11, VNC, and common utilities
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
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

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

# note: Chrome Driver usually needs matching version. 
# We'll rely on the user or runtime to align this, OR install a generic one. 
# For "ultra-fast/light", maybe we skip pre-installing driver binary if valid CDP is goal? 
# User asked for "Selenium (Drivers ... NO Grid)". We should install the driver.
# Fetch generic stable driver (Warning: Version mismatch risk if Chrome updates)
RUN CHROME_VERSION=$(google-chrome --version | awk '{print $3}' | awk -F'.' '{print $1}') \
    && DRIVER_VERSION=$(curl -s "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROME_VERSION") \
    && wget -q "https://chromedriver.storage.googleapis.com/$DRIVER_VERSION/chromedriver_linux64.zip" \
    && unzip chromedriver_linux64.zip -d /usr/local/bin/ \
    && rm chromedriver_linux64.zip

# 4. Firefox & Driver (Selenium Support) - PPA (Non-Snap) Version
# Ubuntu 22.04 defaults to Snap for Firefox, which fails in Docker. We use the Mozilla Team PPA.
RUN install -d -m 0755 /etc/apt/keyrings \
    && wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null \
    && echo 'Package: *' > /etc/apt/preferences.d/mozilla \
    && echo 'Pin: origin packages.mozilla.org' >> /etc/apt/preferences.d/mozilla \
    && echo 'Pin-Priority: 1000' >> /etc/apt/preferences.d/mozilla \
    && apt-get update && apt-get install -y --no-install-recommends \
    firefox \
    && rm -rf /var/lib/apt/lists/*


# Install Geckodriver (Latest)
RUN GECKO_VERSION=$(curl -s https://api.github.com/repos/mozilla/geckodriver/releases/latest | grep 'tag_name' | cut -d\" -f4) \
    && wget -q "https://github.com/mozilla/geckodriver/releases/download/$GECKO_VERSION/geckodriver-$GECKO_VERSION-linux64.tar.gz" \
    && tar -xzf "geckodriver-$GECKO_VERSION-linux64.tar.gz" -C /usr/local/bin/ \
    && rm "geckodriver-$GECKO_VERSION-linux64.tar.gz"

# 5. Microsoft Edge (Stable)
RUN wget -q -O - https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
    && install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/ \
    && sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-dev.list' \
    && rm microsoft.gpg \
    && apt-get update && apt-get install -y --no-install-recommends \
    microsoft-edge-stable \
    && rm -rf /var/lib/apt/lists/*

# note: msedgedriver usually matches edge version.
# For now, we install the browser. Selenium Manager (if used) or manual driver download can be added if needed.
# We will focus on the browser binary for now as per "CDP/Drivers" goal, Selenium Manager handles drivers often now.

# 5. Playwright Installation (Browsers + Node)
# Install Playwright globally so npx playwright works
RUN npm install -g playwright
# Install native deps & browsers
RUN npx playwright install --with-deps chromium firefox webkit

# 6. Setup Scripts
COPY common/scripts /opt/bin/
RUN chmod +x /opt/bin/*.sh

# 7. Configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 8. Entrypoint
ENTRYPOINT ["/opt/bin/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
