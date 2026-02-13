# TLJH Configuration: HTML Files in RTC-Enabled Editor

## Overview

This configuration ensures that HTML files open in the JupyterLab Editor (RTC-enabled) with Real-Time Collaboration support, rather than the default HTML viewer.

---

## Configuration Details

**File Location:**
```
/opt/tljh/user/share/jupyter/lab/settings/overrides.json
```

**Required Content:**
```json
{
  "@jupyterlab/docmanager-extension:plugin": {
    "defaultViewers": {
      "html": "Editor"
    }
  }
}
```

---

## Implementation Instructions

### Manual Implementation

#### Step 1: Create the settings directory and file
```bash
sudo mkdir -p /opt/tljh/user/share/jupyter/lab/settings
sudo nano /opt/tljh/user/share/jupyter/lab/settings/overrides.json
```

#### Step 2: Add the configuration content

Copy and paste this into the file:
```json
{
  "@jupyterlab/docmanager-extension:plugin": {
    "defaultViewers": {
      "html": "Editor"
    }
  }
}
```

Save and exit (in nano: `Ctrl+O`, `Enter`, `Ctrl+X`)

#### Step 3: Restart JupyterHub
```bash
sudo tljh-config reload
```

**Note:** This restarts JupyterHub without affecting running user sessions.

---

### Implementation Script
#### TBC

---

## Verification

After setup, verify the configuration:

1. Log into JupyterLab
2. Create or open an HTML file
3. Confirm it opens in the Editor interface (not HTML preview)
4. Test real-time collaboration features if applicable

---

## Troubleshooting

If HTML files don't open in Editor mode:

- Verify the file exists at `/opt/tljh/user/share/jupyter/lab/settings/overrides.json`
- Check JSON syntax is valid (no trailing commas, proper formatting)
- Confirm JupyterHub service was restarted after configuration
- Check file permissions allow read access

---

## Technical Notes

- **Purpose:** Enables Editor (RTC-enabled) for HTML files using the Yjs collaborative editing framework
- **Scope:** System-wide configuration affecting all users
- **Persistence:** Configuration persists across server restarts
- **JupyterLab Version:** Compatible with JupyterLab 3.x and 4.x
- **RTC Extension:** Requires `jupyter_collaboration` extension to be installed

---

## References

- **TLJH Settings Override Documentation:** https://tljh.jupyter.org/en/latest/howto/user-env/override-lab-settings.html
- **JupyterLab Real-Time Collaboration:** https://jupyterlab-realtime-collaboration.readthedocs.io/en/latest/
- **JupyterLab File Formats:** https://jupyterlab.readthedocs.io/en/stable/user/file_formats.html
- **Finding Available Viewers:** Right-click any file in JupyterLab's file browser and check the "Open With" submenu. The names shown are the exact strings to use in `defaultViewers`.

---

**Last Updated:** February 13, 2026