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

Follow the official TLJH installation guide:

https://tljh.jupyter.org/en/latest/install/

DigitalOcean guide:

https://tljh.jupyter.org/en/latest/install/digitalocean.html

Note:
If the VM is already provisioned, follow Step 6 onward in the official DigitalOcean guide.

### Bootstrap TLJH

From the VM:

```bash
curl -L https://tljh.jupyter.org/bootstrap.py   | sudo python3 -     --admin <admin_username>
```

---

## Install Real-Time Collaboration (RTC)

Inside the VM:

```bash
sudo -E /opt/tljh/user/bin/pip install jupyter-collaboration
sudo -E /opt/tljh/user/bin/pip install jupyter-collaboration-ui
sudo systemctl restart jupyterhub
```

---

# Collaboration Room Setup (Secure Role-Based Configuration)

---

## OPTIONAL Step 1 — Create Collaboration User (TLJH Behavior Explained)

Important:
In TLJH deployments using UserCreatingSpawner (default in TLJH), this step is optional.
The `<project_name>-collab` user will be automatically created the first time its server is spawned.

Manual Creation (Optional):

1. Log in as an admin user.
2. Navigate to:
   ```
   https://<hub-domain>/hub/admin
   ```
3. Click **Add Users**
4. Add:
   ```
   <project_name>-collab
   ```
5. (Optional) Log in once as that user and start the server.

Manual creation is required in:

- Non-TLJH JupyterHub deployments
- Deployments not using UserCreatingSpawner
- Systems with restricted user provisioning

---

## Step 2 — Create Collaboration Config File

```bash
sudo nano /opt/tljh/config/jupyterhub_config.d/<project_name>_collab.py
```

---

## Step 3 — Paste Configuration Script

```python
from traitlets.config.loader import LazyConfigValue

project_name = "<project_name>"
members = ["<user_1>", "<user_2>", "<user_3>"]
collab_user = f"{project_name}-collab"

lg = getattr(c.JupyterHub, "load_groups", None)
if lg is None or isinstance(lg, LazyConfigValue):
    c.JupyterHub.load_groups = {}
elif not isinstance(lg, dict):
    c.JupyterHub.load_groups = dict(lg)

lr = getattr(c.JupyterHub, "load_roles", None)
if lr is None or isinstance(lr, LazyConfigValue):
    c.JupyterHub.load_roles = []
elif not isinstance(lr, list):
    c.JupyterHub.load_roles = list(lr)

c.JupyterHub.load_groups.setdefault("collaborative", {"users": []})
if collab_user not in c.JupyterHub.load_groups["collaborative"]["users"]:
    c.JupyterHub.load_groups["collaborative"]["users"].append(collab_user)

c.JupyterHub.load_groups[project_name] = {"users": members}

role_name = f"collab-access-{project_name}"
if not any(r.get("name") == role_name for r in c.JupyterHub.load_roles):
    c.JupyterHub.load_roles.append(
        {
            "name": role_name,
            "scopes": [
                f"access:servers!user={collab_user}",
                f"servers!user={collab_user}",
            ],
            "groups": [project_name],
        }
    )

def pre_spawn_hook(spawner):
    if spawner.user and spawner.user.name == collab_user:
        spawner.args = spawner.args or []
        if "--LabApp.collaborative=True" not in spawner.args:
            spawner.args.append("--LabApp.collaborative=True")

c.Spawner.pre_spawn_hook = pre_spawn_hook
```

---

## Step 4 — Restart JupyterHub

```bash
sudo systemctl restart jupyterhub
```

Verify:

```bash
sudo journalctl -u jupyterhub -n 40 --no-pager
```

---

## Using the Collaboration Room

### Accessing the Shared Environment

Project members navigate to:

```
https://<hub-domain>/hub/user/<project_name>-collab/lab
```

Behavior:

- If the server is stopped, it starts automatically.
- If running, the user joins immediately.
- No admin privileges are required.

### Real-Time Collaboration Behavior

- Multiple users can open the same notebook.
- Edits appear instantly.
- Cursor movements are visible live.
- All code executes under `<project_name>-collab`.
- Files are stored in:

```
/home/<project_name>-collab/
```

---

## Security Model

- Only designated TLJH admins have Hub-wide admin access.
- Project members cannot access `/hub/admin`.
- Project members cannot manage other users.
- Members can only access and manage the collaboration account server.
- RTC is enabled only for the collab account.

No `admin-ui` scope is granted.

---

## Verification Checklist

- `/hub/admin` returns 403 for project members.
- Members can access `/hub/user/<project_name>-collab/lab`.
- Live editing works between users.
- Files persist under the collab user home directory.
- No Hub errors appear in logs.

---

## Scaling to Multiple Projects

To create additional collaboration rooms:

1. Duplicate the config file.
2. Change `project_name` and `members`.
3. Restart JupyterHub.

Each project receives its own isolated shared execution account.
