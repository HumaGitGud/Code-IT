# JupyterHub Hosting Comparison Report: TLJH on a DigitalOcean VM vs. Kubernetes on DigitalOcean

## Executive summary

This report compares two realistic deployment paths for JupyterHub:

1. **TLJH on a single DigitalOcean Droplet**
2. **Zero to JupyterHub (Z2JH) on DigitalOcean Kubernetes (DOKS)**

For a **single classroom of roughly 20–30 students**, the best starting point is usually **TLJH on a single VM** because it has the lowest monthly cost, the smallest operational footprint, and the fastest path to a usable service. TLJH is explicitly recommended by Project Jupyter when the hub and users can live on a **single machine**, while Zero to JupyterHub is the recommended path when JupyterHub needs to run on **multiple machines** or use **container technology**. DigitalOcean’s current pricing also strongly favors a single 8 GiB VM for a pilot: a **Basic 8 GiB Droplet is $48/month**, while even a lean Kubernetes deployment usually adds persistent storage and a load balancer on top of worker-node costs. For an organization that expects more than one classroom, repeated course rollouts, or future automation and autoscaling, Kubernetes becomes more compelling despite the higher operational complexity and higher steady-state cost floor.

The most important strategic conclusion is this: **TLJH is the better pilot platform; Kubernetes is the better platform architecture.** If the department expects this to become a shared, long-lived academic service spanning multiple classes and semesters, Kubernetes is the stronger long-term recommendation. If the department wants the lowest-risk and lowest-cost way to support one class soon, TLJH on a VM is the better fit.

---

## Scope and assumptions

This report evaluates:

- **TLJH on a fresh Linux VM** hosted on a DigitalOcean Droplet
- **JupyterHub on Kubernetes** using **Zero to JupyterHub** on **DigitalOcean Kubernetes**
- Cost behavior for:
  - one classroom of about 20–30 students
  - growth beyond 30 students
  - multiple classrooms using one shared platform

Assumptions used in the pricing comparison:

- The VM baseline is a **Basic 8 GiB DigitalOcean Droplet** with **4 vCPUs, 160 GiB SSD, and 5,000 GiB transfer for $48/month**.
- A stronger single-VM comparator is a **General Purpose 8 GiB Droplet** with **2 dedicated vCPUs, 25 GiB SSD, and 4,000 GiB transfer for $63/month**.
- DigitalOcean Kubernetes control-plane management is included at no extra baseline charge; you pay for the **worker nodes**, **block storage**, and **load balancers**.
- DOKS pricing starts with **worker nodes from $12/month**, **block storage from $10/month**, and **load balancers from $12/month**.
- Worker nodes and Droplets are billed per-second with a monthly cap, which matters when autoscaling is used.
- Local proof-of-concept testing for Kubernetes was performed on a **Windows machine using WSL2**, Docker Desktop, KIND, and Helm; production comparison in this report is against **DigitalOcean-hosted** options.

---

## Recommended deployment methods

### TLJH recommendation

For the single-VM option, the recommended deployment method is **The Littlest JupyterHub (TLJH)**. Project Jupyter describes TLJH as a JupyterHub distribution for roughly **0–100 users on a single server**, and it explicitly recommends TLJH when the deployment can live on **one machine** and does not require container-based cluster management.

### Kubernetes recommendation

For the Kubernetes option, the recommended deployment method is **Zero to JupyterHub (Z2JH)** using the official **JupyterHub Helm chart**. The official Z2JH documentation states that once a Kubernetes cluster and Helm are available, JupyterHub is installed into the cluster with the Helm chart and configured via a `config.yaml` values file.

These two options are therefore the most appropriate apples-to-apples comparison:

- **TLJH on a DigitalOcean Droplet** for the single-server path
- **Z2JH on DOKS** for the Kubernetes path

---

## Pricing comparison

### 1. Single VM baseline: TLJH on DigitalOcean

A **Basic 8 GiB Droplet** currently costs **$48/month** and includes **4 vCPUs, 160 GiB SSD, and 5,000 GiB transfer**. This is the most cost-effective straightforward starting point for a single class.

A **General Purpose 8 GiB Droplet** costs **$63/month** and includes **2 dedicated vCPUs, 25 GiB SSD, and 4,000 GiB transfer**. This option is worth considering if the department wants more predictable CPU performance than a Basic shared-CPU Droplet can provide.

In practical terms, TLJH on an 8 GiB VM has a very simple price model:

- **Basic 8 GiB TLJH VM:** $48/month
- **General Purpose 8 GiB TLJH VM:** $63/month

This is the full hosting baseline unless optional add-ons such as backups or floating IPs are added.

### 2. Kubernetes baseline: Z2JH on DigitalOcean Kubernetes

DigitalOcean Kubernetes does **not** add a mandatory control-plane fee under its standard pricing. Instead, you pay for:

- worker nodes
- persistent storage
- load balancers
- any optional HA add-ons or overages

For a minimal DOKS classroom deployment, realistic baseline components are:

- at least **one worker node**
- **persistent block storage** for user data
- a **load balancer** for external access

A practical **lean** Kubernetes baseline using a single **Basic 8 GiB worker node** works out approximately as:

- **1 × Basic 8 GiB node:** $48/month
- **100 GiB block storage:** $10/month
- **1 load balancer:** $12/month
- **Estimated baseline total:** **$70/month**

A more resilient Kubernetes baseline using **two Basic 8 GiB worker nodes** works out approximately as:

- **2 × Basic 8 GiB nodes:** $96/month
- **100 GiB block storage:** $10/month
- **1 load balancer:** $12/month
- **Estimated baseline total:** **$118/month**

A dedicated-CPU Kubernetes comparison using **two General Purpose 8 GiB nodes** works out approximately as:

- **2 × General Purpose 8 GiB nodes:** $126/month
- **100 GiB block storage:** $10/month
- **1 load balancer:** $12/month
- **Estimated baseline total:** **$148/month**

### 3. Autoscaled classroom Kubernetes baseline

Kubernetes becomes more financially interesting when the workload is highly bursty. DigitalOcean’s cluster autoscaler supports scaling a node pool **down to zero**, and its documentation recommends keeping at least **one small fixed node pool** available while letting larger pools scale down aggressively.

A common classroom cost pattern would be:

- one **small fixed node** for the Hub, proxy, and cluster overhead
- one **autoscaled user node pool** that grows during active class sessions
- block storage for user homes
- one load balancer

Two reasonable small-core baselines are:

**Option A: 2 GiB core node**

- **1 × Basic 2 GiB node:** $18/month
- **100 GiB block storage:** $10/month
- **1 load balancer:** $12/month
- **Idle baseline:** **$40/month**

**Option B: 4 GiB core node**

- **1 × Basic 4 GiB node:** $24/month
- **100 GiB block storage:** $10/month
- **1 load balancer:** $12/month
- **Idle baseline:** **$46/month**

On top of that idle baseline, larger user nodes only run when classes are active. A **Basic 8 GiB node** costs **$0.07143/hour**. That means:

- **40 hours/month of one 8 GiB user node:** about **$2.86**
- **60 hours/month of one 8 GiB user node:** about **$4.29**
- **80 hours/month of one 8 GiB user node:** about **$5.71**
- **120 hours/month of one 8 GiB user node:** about **$8.57**

If **two 8 GiB user nodes** are needed during class windows, those hourly figures double.

This means autoscaled Kubernetes can sometimes approach or beat the apparent flat monthly cost of an always-on 8 GiB VM **if** most student capacity is turned off outside class hours. The tradeoff is that the design and operations are much more complex than running TLJH on one server.

---

## Pricing summary table

| Scenario | Approx. monthly cost | Notes |
|---|---:|---|
| TLJH on Basic 8 GiB Droplet | **$48** | Lowest-cost pilot option |
| TLJH on General Purpose 8 GiB Droplet | **$63** | More predictable CPU performance |
| Z2JH on DOKS, 1 × Basic 8 GiB node + storage + LB | **$70** | Lean Kubernetes baseline |
| Z2JH on DOKS, 2 × Basic 8 GiB nodes + storage + LB | **$118** | More realistic/resilient classroom baseline |
| Z2JH on DOKS, 2 × GP 8 GiB nodes + storage + LB | **$148** | Dedicated-CPU Kubernetes baseline |
| Z2JH autoscaled, 2 GiB core + storage + LB | **$40 idle baseline** | Student compute billed on demand |
| Z2JH autoscaled, 4 GiB core + storage + LB | **$46 idle baseline** | Student compute billed on demand |

---

## How costs change beyond 30 students

### If the deployment stays on a single TLJH VM

As concurrency rises, the single-server model eventually forces a **vertical scaling** decision. The next common step is a **Basic 16 GiB Droplet at $96/month** or a **General Purpose 16 GiB Droplet at $126/month**.

This works well if:

- there is still only one main classroom active at a time
- workloads are predictable
- administration simplicity is more important than elasticity

But this model becomes less comfortable when:

- multiple classrooms need to run simultaneously
- heavy Python or data-science kernels become common
- the organization needs more isolation between classes or environments

### If the deployment is on Kubernetes

Kubernetes scales **horizontally** instead of only vertically. That means the department can add more workers or larger user node pools as demand rises.

Examples using Basic 8 GiB workers:

- **3 nodes:** $144 in worker cost before storage and LB
- **4 nodes:** $192 in worker cost before storage and LB

Adding the same **$10 storage + $12 LB** gives rough totals of:

- **3-node Basic DOKS setup:** **$166/month**
- **4-node Basic DOKS setup:** **$214/month**

This is clearly more expensive than a single 8 GiB VM, but it also supports:

- more simultaneous classrooms
- stronger isolation between user workloads
- better room to absorb bursty lab usage
- cleaner future automation for course-specific images and services

### Multiple classrooms

If the department expects **multiple active classrooms**, the economics shift away from TLJH. One large TLJH VM can keep scaling upward for a while, but eventually one box becomes both a technical and operational bottleneck.

At that point, Kubernetes becomes much more attractive because:

- one shared platform can serve multiple classes
- user node pools can scale based on demand
- classes can share the same base infrastructure while using separate profiles, groups, images, or namespaces
- maintenance becomes more standardized across courses

A good rule of thumb is:

- **1 class / one active course:** TLJH is usually the better value
- **2–3 classrooms or >30 highly active students at once:** Kubernetes starts becoming more defensible
- **department-wide service across multiple courses and semesters:** Kubernetes becomes the stronger strategic choice

---

## Benefits and limitations

### TLJH on a DigitalOcean VM

#### Benefits

- Lowest monthly cost for one class
- Fastest deployment path
- Lowest operational complexity
- Easier to understand, backup, and troubleshoot
- Good fit for a pilot, single classroom, or instructor-managed deployment

#### Limitations

- Single-machine architecture
- Vertical scaling only
- Less natural fit for containerized environments and automated rollouts
- Harder to support multiple classrooms cleanly from one long-lived platform
- Collaboration automation and course-specific isolation are harder to generalize

### Z2JH on DigitalOcean Kubernetes

#### Benefits

- Better long-term architecture for a shared service
- Horizontal scaling across multiple nodes
- Stronger fit for multiple classrooms and future growth
- Better alignment with containerized user images and standardized environments
- Better support for autoscaling and idle-cost reduction when configured well
- Better foundation for custom services such as collaboration-room automation

#### Limitations

- Higher operational complexity
- Higher baseline cost in most always-on configurations
- More moving parts: Kubernetes, Helm, storage classes, load balancers, images, logs
- More setup time and more ways for the platform to fail if not managed carefully

---

## Local testing notes

The local proof-of-concept for Kubernetes was performed on a **Windows workstation using WSL2**, not on a cloud VM. The test stack used:

- Windows host
- WSL2 Ubuntu
- Docker Desktop with WSL integration
- KIND for a local Kubernetes cluster
- Helm
- JupyterHub via the Z2JH Helm chart
- a custom single-user image with JupyterLab RTC support

That local setup was useful for validating:

- basic Helm deployment flow
- custom single-user images
- RTC behavior
- the feasibility of room-sharing architecture concepts

This local test proved the Kubernetes path was technically workable before comparing DigitalOcean production-hosting options.

---

## Installation and local testing steps

## A. TLJH on a fresh Linux VM (DigitalOcean-style single server)

These are the basic documented steps for a fresh Ubuntu VM.

### 1. Create the VM

Use Ubuntu 22.04 LTS or newer, assign a public IP, and SSH into the VM.

### 2. Install prerequisite packages

```bash
sudo apt update
sudo apt install -y python3 python3-dev git curl
```

### 3. Run the TLJH installer

Replace `adminuser` with the first JupyterHub admin account name.

```bash
curl -L https://tljh.jupyter.org/bootstrap.py | sudo -E python3 - --admin adminuser
```

### 4. Wait for installation to finish

The TLJH docs note that installation takes roughly **5–10 minutes**.

### 5. Open the hub

Navigate to `http://<public-ip>` in a browser and log in with the admin account you created.

### 6. Post-install tasks

Recommended immediate follow-up work:

- configure HTTPS
- set memory and CPU expectations for users
- install course packages into the user environment
- configure backups
- add students/admins

This is the shortest path from a fresh Linux VM to a working JupyterHub.

## B. Local Kubernetes testing path (used in the proof of concept)

This is the path that was used for local testing before evaluating DigitalOcean Kubernetes.

### 1. Host setup

- Windows machine
- WSL2 Ubuntu
- Docker Desktop with WSL integration enabled

### 2. Install tooling inside WSL

Install:

- `kubectl`
- `kind`
- `helm`

### 3. Create a local KIND cluster

Example:

```bash
kind create cluster --name jhub-rtc
kubectl get nodes
```

### 4. Prepare a single-user image

Build a Jupyter single-user image that includes:

- JupyterLab
- `jupyter-collaboration`

Load that image into KIND.

```bash
docker build -t jupyterhub-singleuser-rtc:0.1.0 .
kind load docker-image jupyterhub-singleuser-rtc:0.1.0 --name jhub-rtc
```

### 5. Add the JupyterHub Helm repository

```bash
helm repo add jupyterhub https://hub.jupyter.org/helm-chart/
helm repo update
```

### 6. Create a Helm `config.yaml`

At minimum, configure:

- an authentication method for local testing
- the single-user image name and tag
- `defaultUrl: /lab`
- basic user storage
- CPU and memory guarantees/limits

### 7. Install JupyterHub with Helm

```bash
helm upgrade --cleanup-on-fail \
  --install jhub jupyterhub/jupyterhub \
  --namespace jhub \
  --create-namespace \
  --values config.yaml
```

### 8. Access the hub locally

Port-forward the proxy service:

```bash
kubectl port-forward -n jhub svc/proxy-public 8080:80
```

Then open `http://localhost:8080`.

### 9. Validate RTC

- log in with one test user in two browser sessions
- open the same notebook
- verify real-time edits are visible in both sessions

This local path is not the production design, but it is the cleanest way to prove the Kubernetes approach before paying for DOKS resources.

## C. DigitalOcean Kubernetes production-style deployment

### 1. Create a DOKS cluster

Create either:

- a small fixed node pool plus autoscaled user node pool, or
- a fixed small two-node cluster for a simple first deployment

### 2. Enable autoscaling if desired

DigitalOcean supports autoscaling on node pools and supports scaling a node pool down to zero. A good classroom design is:

- one small fixed pool with one node
- one larger autoscaled pool for student user pods

### 3. Install Helm locally

Use Helm from your admin workstation or a deployment VM.

### 4. Create `config.yaml` for Z2JH

Include settings for:

- authentication
- storage
- image choice
- user scheduler
- idle culler
- resource requests and limits
- optional node affinity / taints for user workloads

### 5. Install JupyterHub

```bash
helm repo add jupyterhub https://hub.jupyter.org/helm-chart/
helm repo update

helm upgrade --cleanup-on-fail \
  --install jhub jupyterhub/jupyterhub \
  --namespace jhub \
  --create-namespace \
  --values config.yaml
```

### 6. Validate operations

After deployment, verify:

- hub and proxy pods are healthy
- storage provisioning works
- student servers spawn successfully
- idle culling works
- autoscaling behavior works under class load
- ingress or load balancer access is stable

---

## Recommendation

### Lowest-cost, lowest-risk start

Choose **TLJH on a Basic 8 GiB DigitalOcean Droplet**.

This is the strongest recommendation for:

- one classroom
- a pilot phase
- small operational teams
- fast implementation

### Long-term infrastructure

Choose **Zero to JupyterHub on DigitalOcean Kubernetes**.

This is the stronger recommendation for:

- multiple classrooms
- future enrollment growth beyond 30 concurrent students
- standardized course environments
- automated deployments and lifecycle management
- future collaboration-room or service-level customization

### Final judgment

For a **single initial classroom**, TLJH on a DigitalOcean VM is the better value.

For a **department-wide service**, Kubernetes is the better long-term architecture even though it costs more and takes more effort to operate.

