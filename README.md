# Code-It

**Code-It** is a setup and extension for **The Littlest JupyterHub
(TLJH)** that enables **real-time collaborative (RTC) peer programming**
in JupyterLab.

It allows multiple students to work in the same notebook or file
simultaneously with live updates, shared execution, and role-based
access control.

------------------------------------------------------------------------

## Team Members

-   Ash Gray
-   Huma Khomidov
-   Maxwell Maslov
-   Rudolf Sirbu

------------------------------------------------------------------------

## Features

-   Real-time collaboration in JupyterLab (RTC)
-   Shared "collaboration room" per project
-   Role-based access (secure, no admin exposure)
-   HTML editing in RTC-enabled editor (not preview mode)
-   Easy deployment via script or manual setup

------------------------------------------------------------------------

## Requirements

-   The Littlest JupyterHub (TLJH)
-   JupyterLab ≥ 4.0
-   Node.js 18
-   Conda
-   sudo access (for system-wide install)
-   DigitalOcean VM (recommended)

------------------------------------------------------------------------

# Quick Start (Recommended)

## One-Command Setup

### 1. SSH into your server

``` bash
ssh root@<YOUR_SERVER_IP>
```

### 2. Create setup script

``` bash
nano setup.sh
```

``` bash
chmod +x setup.sh
```

### 3. Run the script

``` bash
sudo ./setup.sh <admin_user> <project_name> '"student1", "student2", "student3"'
```

### 4. Start collaboration server (admin only)

To access admin page and create/access users Go to:\
https://code-it.greenrivertech.net/hub/admin

### 5. Students access shared workspace

https://code-it.greenrivertech.net/user/bobby/lab

### 6. To generate and share workspaces for collaboration

Navigate to home screen of TLJH app and press 'Generate a shared link' in JupyterHub notebook. Alternatively, 
find a partners user name and insert it the link like so https://code-it.greenrivertech.net/user/<partner>/lab.
TLJH will ask for 'Authorization' after which you are the room and collaboration is live.

------------------------------------------------------------------------

# Manual Setup (Step-by-Step)

## 1. (Optional) Wipe Existing TLJH

``` bash
sudo systemctl stop jupyterhub || true
sudo rm -rf /opt/tljh /etc/jupyterhub /srv/jupyterhub /var/lib/jupyterhub
sudo rm -rf /etc/systemd/system/jupyterhub.service
sudo systemctl daemon-reexec
sudo reboot
```

## 2. Install TLJH

``` bash
curl -L https://tljh.jupyter.org/bootstrap.py | sudo python3 - --admin <admin_user>
```

## 3. Install Real-Time Collaboration

``` bash
sudo -E /opt/tljh/user/bin/pip install jupyter-collaboration
sudo -E /opt/tljh/user/bin/pip install jupyter-collaboration-ui
sudo systemctl restart jupyterhub
```

## 4. Configure Collaboration Room

``` bash
sudo nano /opt/tljh/config/jupyterhub_config.d/<project_name>_collab.py
```

``` python
project_name = "<project_name>"
members = ["<user1>", "<user2>"]
collab_user = f"{project_name}-collab"

c.JupyterHub.load_groups = {
    "collaborative": {"users": [collab_user]},
    project_name: {"users": members}
}

c.JupyterHub.load_roles = [{
    "name": f"collab-access-{project_name}",
    "scopes": [
        f"access:servers!user={collab_user}",
        f"servers!user={collab_user}",
    ],
    "groups": [project_name],
}]

def pre_spawn_hook(spawner):
    if spawner.user.name == collab_user:
        spawner.args = spawner.args or []
        spawner.args.append("--LabApp.collaborative=True")

c.Spawner.pre_spawn_hook = pre_spawn_hook
```

``` bash
sudo systemctl restart jupyterhub
```

## 5. Enable HTML Editing in RTC

``` bash
sudo mkdir -p /opt/tljh/user/share/jupyter/lab/settings
sudo nano /opt/tljh/user/share/jupyter/lab/settings/overrides.json
```

``` json
{
  "@jupyterlab/docmanager-extension:plugin": {
    "defaultViewers": {
      "html": "Editor"
    }
  }
}
```

``` bash
sudo tljh-config reload
```

------------------------------------------------------------------------

# Extension Development (Optional)

``` bash
conda create -n jlx -c conda-forge jupyterlab=4 nodejs=18 git
conda activate jlx

git clone https://github.com/HumaGitGud/Code-IT.git
cd Code-IT

jlpm install
jlpm run build
```

``` bash
sudo -E jupyter labextension develop --overwrite .
sudo -E jupyter lab build
sudo systemctl restart jupyterhub
```

------------------------------------------------------------------------

# Vulnerability

In the current implementation, real-time collaboration (RTC) functionality requires users to have **admin-level privileges** in JupyterHub. This introduces a significant security concern, as it grants elevated permissions beyond what is necessary for standard users allowing potential unwanted security issues.

------------------------------------------------------------------------

# Resources for individual setup parts

- [TLJH Setup](https://github.com/HumaGitGud/Code-IT/blob/main/TLJH-Setup.md)
- [TLJH HTML Editor](https://github.com/HumaGitGud/Code-IT/blob/main/tljh-html-editor-config.md)
- [Kubernetes Report](https://github.com/HumaGitGud/Code-IT/blob/main/Kubernetes-Report.md)

# JupyterHub Resources
-   https://tljh.jupyter.org/
-   https://jupyterlab-realtime-collaboration.readthedocs.io/
-   https://jupyterlab.readthedocs.io/
