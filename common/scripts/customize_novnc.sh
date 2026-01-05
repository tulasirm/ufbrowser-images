#!/bin/bash
set -e

NOVNC_HOME=${NOVNC_HOME:-/opt/novnc}
UI_TITLE=${UI_TITLE:-"Ultra Fast Browsers"}
LOGO_PATH=${LOGO_PATH:-/opt/novnc/images/custom_logo.png}

if [ -d "$NOVNC_HOME" ]; then
    echo "Applying NoVNC Branding..."
    
    # 1. Change Page Title
    find "$NOVNC_HOME" -name "vnc.html" -type f -exec sed -i "s|<title>.*</title>|<title>$UI_TITLE</title>|g" {} +
    
    # 2. Replace Logo (if custom logo provided)
    # Note: NoVNC structure varies slightly by version, but usually has images/
    # We will assume the Docker construction places a custom logo at $LOGO_PATH env or specific location
    
    # 3. Inject Custom CSS (Hide Pattern / Solid Background)
    # We inject a style block before </head> to override defaults.
    # - Sets background to solid dark color
    # - Hides the "screen" background pattern usually defined in base.css or app.css
    STYLE_BLOCK="<style> \
        :root, body, #noVNC_container { background-color: #1b1b1b !important; background-image: none !important; } \
        #noVNC_status { color: #f0f0f0 !important; } \
        /* Hide specific background elements if present in newer NoVNC versions */ \
        .noVNC_center { background: #1b1b1b !important; } \
    </style>"
    
    find "$NOVNC_HOME" -name "vnc.html" -type f -exec sed -i "s|</head>|$STYLE_BLOCK</head>|g" {} +
    
    echo "Branding applied: $UI_TITLE (Dark Theme, No Pattern)"
else
    echo "NoVNC directory not found at $NOVNC_HOME, skipping branding."
fi
