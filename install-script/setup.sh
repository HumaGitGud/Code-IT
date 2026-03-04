#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Script: setup_complete.sh
# Description: A script for deployment of TLJH, Live RTC (also html editing), and Code-IT
# -----------------------------------------------------------------------------
set -euo pipefail

ADMIN_USER=${1:-"admin"}
PROJECT_NAME=${2:-"html-collab"}
TEAM_MEMBERS=${3:-'"student1", "student2"'}
USER_BIN="/opt/tljh/user/bin"

if [[ $EUID -ne 0 ]]; then
   echo "[ERROR] This script must be run as root."
   exit 1
fi

echo "================================================="
echo " STARTING DEPLOYMENT - ETA: 5-10 mins"
echo "================================================="

# --- PHASE 1: Install TLJH ---
echo -e "\n[PHASE 1] Bootstrapping TLJH..."
if [[ ! -d /opt/tljh ]]; then
    curl -L https://tljh.jupyter.org/bootstrap.py | sudo python3 - --admin "$ADMIN_USER"
fi

echo "[INFO] Installing RTC modules into TLJH user environment..."
sudo -E /opt/tljh/user/bin/python3 -m pip install -q jupyter-collaboration jupyter-collaboration-ui

# Create a collaboration config room
mkdir -p /opt/tljh/config/jupyterhub_config.d
cat << EOF > /opt/tljh/config/jupyterhub_config.d/${PROJECT_NAME}_collab.py
from traitlets.config.loader import LazyConfigValue
project_name = "${PROJECT_NAME}"
members = [${TEAM_MEMBERS}]
collab_user = f"{project_name}-collab"
lg = getattr(c.JupyterHub, "load_groups", None)
if lg is None or isinstance(lg, LazyConfigValue): c.JupyterHub.load_groups = {}
elif not isinstance(lg, dict): c.JupyterHub.load_groups = dict(lg)
lr = getattr(c.JupyterHub, "load_roles", None)
if lr is None or isinstance(lr, LazyConfigValue): c.JupyterHub.load_roles = []
elif not isinstance(lr, list): c.JupyterHub.load_roles = list(lr)
c.JupyterHub.load_groups.setdefault("collaborative", {"users": []})
if collab_user not in c.JupyterHub.load_groups["collaborative"]["users"]:
    c.JupyterHub.load_groups["collaborative"]["users"].append(collab_user)
c.JupyterHub.load_groups[project_name] = {"users": members}
role_name = f"collab-access-{project_name}"
if not any(r.get("name") == role_name for r in c.JupyterHub.load_roles):
    c.JupyterHub.load_roles.append({
        "name": role_name,
        "scopes": [f"access:servers!user={collab_user}", f"servers!user={collab_user}"],
        "groups": [project_name],
    })
def pre_spawn_hook(spawner):
    if spawner.user and spawner.user.name == collab_user:
        spawner.args = spawner.args or []
        if "--LabApp.collaborative=True" not in spawner.args:
            spawner.args.append("--LabApp.collaborative=True")
c.Spawner.pre_spawn_hook = pre_spawn_hook
EOF
sudo systemctl restart jupyterhub

# --- PHASE 2: Override .json file to allow HTML editing ---
echo -e "\n[PHASE 2] Applying HTML Editor Overrides..."
sudo mkdir -p /opt/tljh/user/share/jupyter/lab/settings
cat << 'EOF' > /opt/tljh/user/share/jupyter/lab/settings/overrides.json
{"@jupyterlab/docmanager-extension:plugin": {"defaultViewers": {"html": "Editor"}}}
EOF
sudo tljh-config reload

# --- PHASE 3: Install and apply Code-IT Extension & RTC Build ---
echo -e "\n[PHASE 3] Deploying Code-IT Extension..."

# 1. Install NodeJS-20 globally
if ! command -v node >/dev/null 2>&1; then
    echo "[INFO] Installing NodeJS 20..."
    sudo apt-get update -qq && sudo apt-get install -y -qq ca-certificates curl gnupg
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
    sudo apt-get update -qq
    sudo apt-get install -y -qq nodejs
fi

# 2. Setup Conda build factory
if [[ ! -d /opt/miniconda3 ]]; then
    curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh
    bash miniconda.sh -b -p /opt/miniconda3 && rm miniconda.sh
fi
export PATH="/opt/miniconda3/bin:$PATH"
eval "$(conda shell.bash hook)"

if ! conda info --envs | grep -q "^jlx "; then
    echo "[INFO] Solving Conda environment (approx 5-10 mins)..."
    conda create -y -n jlx --override-channels --strict-channel-priority -c conda-forge -c nodefaults jupyterlab=4 nodejs=18 git copier=7 jinja2-time
fi
conda activate jlx

if [[ ! -d "/opt/Code-IT" ]]; then
    cd /opt && git clone -q https://github.com/HumaGitGud/Code-IT.git
fi
cd /opt/Code-IT

# 3. Build & Production Install
echo "[INFO] Compiling extension frontend..."
jlpm install
jlpm run build
sudo -E /opt/tljh/user/bin/python3 -m pip install -e .
sudo -E /opt/tljh/user/bin/jupyter labextension develop --overwrite .

echo "[INFO] Activating server extensions..."
sudo -E /opt/tljh/user/bin/jupyter server extension enable jupyter_collaboration --sys-prefix
sudo -E /opt/tljh/user/bin/jupyter server extension enable code_it --sys-prefix

echo "[INFO] Final Jupyter build (Memory-Safe)..."
sudo -E /opt/tljh/user/bin/jupyter lab build --dev-build=False --minimize=False

sudo systemctl restart jupyterhub

# --- PHASE 4: Automated Verification ---
echo "-------------------------------------------------"
echo " POST-DEPLOYMENT VERIFICATION"
echo "-------------------------------------------------"

# Post Deployment Checks
CHECK_RTC=$($USER_BIN/jupyter labextension list 2>&1 | grep -c "@jupyter/collaboration-extension.*enabled OK" || true)
CHECK_EXT=$($USER_BIN/jupyter labextension list 2>&1 | grep -c "code-it.*enabled OK" || true)
CHECK_HUB=$(systemctl is-active jupyterhub)

if [[ "$CHECK_HUB" == "active" ]]; then echo "JupyterHub Service: ONLINE"; else echo "JupyterHub Service: OFFLINE"; fi
# if [[ $CHECK_RTC -gt 0 ]]; then echo "RTC Core Engine: ENABLED"; else echo "RTC Core Engine: NOT DETECTED"; fi
# if [[ $CHECK_EXT -gt 0 ]]; then echo "Code-IT Extension: ENABLED"; else echo "Code-IT Extension: NOT DETECTED"; fi

echo "================================================="
echo " DEPLOYMENT COMPLETE"
echo " URL: http://$(curl -s ifconfig.me)/hub/user/${PROJECT_NAME}-collab/lab"
echo "================================================="