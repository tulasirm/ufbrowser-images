#!/bin/bash
set -e

# Generic Entrypoint
# 1. Customizes NoVNC if needed
# 2. Starts Supervisor (or main process)

echo "Starting Container Entrypoint..."

# Customize NoVNC if script exists
if [ -f "/opt/bin/customize_novnc.sh" ]; then
    echo "Customizing NoVNC..."
    /opt/bin/customize_novnc.sh
fi

# Execute command
exec "$@"
