# TLJH: Resource Limits & Monitoring
 
## 1. systemd Resource Limits
 
TLJH runs each user's Jupyter server as a systemd service, so limits are applied via systemd configuration.
 
### Set Limits via TLJH Config
 
The recommended way is through `tljh-config`:
 
```bash
# Memory limit (hard cap — process is killed if exceeded)
sudo tljh-config set limits.memory 1G
 
# CPU limit (fraction of a core; 1.0 = one full core)
sudo tljh-config set limits.cpu 1.0
 
# Apply changes
sudo tljh-config reload
```
 
These map to `MemoryLimit` and `CPUQuota` in the user systemd.
 
### Verify Limits Are Active
 
```bash
# Check what tljh-config has stored
sudo tljh-config show
```
 
---
 
## 2. jupyter-resource-usage Extension
 
This extension displays each user's current memory (and optionally CPU) consumption directly in the Jupyter toolbar.
 
### Install
 
```bash
sudo -E pip install jupyter-resource-usage
```
 
> The `-E` flag preserves the TLJH environment. Alternatively use the TLJH plugin mechanism:
 
```bash
sudo tljh-config set user_environment.extra_pip_packages jupyter-resource-usage
sudo tljh-config reload
```
 
### Enable the Extension
 
For JupyterLab (TLJH 1.x+):
 
```bash
sudo -E jupyter labextension enable @jupyter-server/resource-usage
```
 
The extension auto-enables in classic Notebook — no extra step needed.
 
### Configure Limits Displayed in the UI
 
Set the memory warning/limit thresholds so the toolbar widget reflects your systemd limits:
 
```bash
sudo nano /opt/tljh/config/jupyterhub_config.d/resource_usage.py
```
 
```python
# Show a warning when the user exceeds this memory usage
c.ResourceUseDisplay.mem_warning_threshold = 0.8   # 80% of limit
 
# Set the memory limit shown in the toolbar (bytes)
c.ResourceUseDisplay.mem_limit = 1 * 1024**3       # 1 GiB — match your systemd limit
 
# Optionally track CPU too (disabled by default)
c.ResourceUseDisplay.track_cpu_percent = True
c.ResourceUseDisplay.cpu_limit = 1.0               # Match your CPUQuota
```
 
Then reload:
 
```bash
sudo tljh-config reload
```
 
### Verify
 
After logging in as a user, the memory usage should appear in the bottom-left of the JupyterLab toolbar.
 
---
 
> **Tip:** Always keep `mem_limit` in `ResourceUseDisplay` in sync with your systemd `MemoryLimit` so the toolbar warning accurately reflects the real cap.