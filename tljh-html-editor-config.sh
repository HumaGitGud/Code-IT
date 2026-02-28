bash#!/bin/bash

# TLJH HTML Editor Configuration Script
# Configures HTML files to open in Editor (RTC-enabled)

set -e  # Exit on any error
sudo -v # ask for sudo password

echo "Creating TLJH settings directory..."
sudo mkdir -p /opt/tljh/user/share/jupyter/lab/settings

echo "Writing overrides.json configuration..."
sudo tee /opt/tljh/user/share/jupyter/lab/settings/overrides.json > /dev/null <<'EOF'
{
  "@jupyterlab/docmanager-extension:plugin": {
    "defaultViewers": {
      "html": "Editor"
    }
  }
}
EOF

echo "Setting file permissions..."
sudo chmod 644 /opt/tljh/user/share/jupyter/lab/settings/overrides.json

echo "Restarting JupyterHub..."
sudo tljh-config reload

echo "✓ Configuration complete!"
echo "HTML files will now open in the Editor (RTC-enabled)"