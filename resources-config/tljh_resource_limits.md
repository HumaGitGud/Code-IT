# TLJH: Resource Limits & Monitoring
 
## 1. systemd Resource Limits
 
TLJH runs each user's Jupyter server as a systemd service, so limits are applied via systemd configuration.
 
## Set Limits via TLJH Config
 
The recommended way is through tljh-config:
 
### Memory limit (hard cap — process is killed if exceeded)
``` bash
sudo tljh-config set limits.memory 1G
```
 
### CPU limit (fraction of a core; 1.0 = one full core)
``` bash
sudo tljh-config set limits.cpu 1.0
```
 
### Apply changes
``` bash
sudo tljh-config reload
```
 
These map to MemoryLimit and CPUQuota in the user systemd slices. 
 
Note: For these limits to take effect, users with active sessions must Stop and Start their server via the JupyterHub Control Panel.
 
## Verify Limits Are Active
 
### Check what tljh-config has stored

``` bash
sudo tljh-config show
```

---
 
# User Monitor for Resource Usage

## jupyter-resource-usage Extension
 
This extension displays each user's current memory (and optionally CPU) consumption directly in the Jupyter toolbar.
 
### Install
 
The most reliable method in TLJH is installing with the extension manager.
 
## Configure Limits Displayed in the UI
 
Set the memory warning/limit thresholds so the toolbar widget reflects your systemd limits:
 
```
sudo nano /opt/tljh/config/jupyterhub_config.d/resource_usage.py
```
 
### Add the following to the file:
### Show a warning when the user exceeds this memory usage
```
c.ResourceUseDisplay.mem_warning_threshold = 0.8   # 80% of limit
```
 
### Set the memory limit shown in the toolbar (bytes)
```
c.ResourceUseDisplay.mem_limit = 1 * 1024**3       # 1 GiB — match your systemd limit
```
 
### Optionally track CPU too (disabled by default)

```
c.ResourceUseDisplay.track_cpu_percent = True
c.ResourceUseDisplay.cpu_limit = 1.0               # Match your CPUQuota
```
 
### Apply and Verify
 
Reload the Hub to pick up the Python configuration:
 
```sudo tljh-config reload```
 
After logging in as a user, the memory usage should appear in the status bar of the JupyterLab interface.
 
---
 
Tip: Always keep mem_limit in ResourceUseDisplay in sync with your systemd MemoryLimit so the toolbar warning accurately reflects the real hardware cap.