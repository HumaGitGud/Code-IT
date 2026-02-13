## Wipe Current TLJH Instance (If Installed)

Run the following commands on the VM to completely remove an existing TLJH installation:

```bash
sudo systemctl stop jupyterhub || true
sudo rm -rf /opt/tljh
sudo rm -rf /etc/jupyterhub
sudo rm -rf /srv/jupyterhub
sudo rm -rf /var/lib/jupyterhub
sudo rm -rf /etc/systemd/system/jupyterhub.service
sudo systemctl daemon-reexec
sudo reboot
```

---

## Install TLJH (Official Documentation)

Follow the official TLJH DigitalOcean installation guide:

https://tljh.jupyter.org/en/latest/install/digitalocean.html

> **Note**
> - If the DigitalOcean VM is already set up, follow **Step 6 onward** in the linked guide.
> - The step numbers below do **not** correspond to the numbering in the official guide.

---

### Step 1: Bootstrap TLJH

Run the following from the VM SSH terminal. Replace `<admin-user-name>` with your desired admin username:

```bash
curl -L https://tljh.jupyter.org/bootstrap.py \
  | sudo python3 - \
    --admin <admin-user-name>
```

---

### Step 2: Install Shared Python Package (`there`)

Log in as the admin user, open a **Terminal** inside the running TLJH server, and run:

```bash
sudo -E /opt/tljh/user/bin/pip install there
```

This installs the package into the shared TLJH user environment, making it available to all users.

---

## Install TLJH Real-Time Collaboration (RTC)

Official documentation:
- https://jupyterhub.readthedocs.io/en/stable/tutorial/collaboration-users.html
- https://jupyterlab-realtime-collaboration.readthedocs.io/en/latest/

### Step 3: Install RTC Packages

From the **VM SSH root terminal** (not the TLJH web terminal), run:

```bash
sudo -E /opt/tljh/user/bin/pip install jupyter-collaboration
sudo -E /opt/tljh/user/bin/pip install jupyter-collaboration-ui
sudo tljh-config reload
```

---

## Result

At this point, real-time collaboration sessions are shareable via link, provided that all participating users have been added via the JupyterHub admin control panel.