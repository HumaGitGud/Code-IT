# code-it

[![Github Actions Status](https://github.com/HumaGitGud/Code-IT/workflows/Build/badge.svg)](https://github.com/HumaGitGud/Code-IT/actions/workflows/build.yml)

An extension for The Littlest JupyterHub to facilitate RTC peer-programming.

## Team Members
- Ash Gray
- Huma Khomidov
- Maxwell Maslov
- Rudolf Sirbu

## Project Description
This extension enables real-time collaborative programming in JupyterHub, allowing students to work together on code in the same notebook.

This extension is composed of a Python package named `code_it` for the server extension and a NPM package named `code-it` for the frontend extension.

## Requirements
- The Littlest JupyterHub (TLJH)
- JupyterLab >= 4.0.0
- NodeJS 18
- Conda
- sudo access for system-wide installation

## Development Setup for TLJH

### 1. Create a Conda Environment
```bash
conda create -n jlx --override-channels --strict-channel-priority -c conda-forge -c nodefaults jupyterlab=4 nodejs=18 git copier=7 jinja2-time
```

### 2. Activate the Conda Environment
```bash
conda activate jlx
```

### 3. Clone and Navigate to the Repository
```bash
git clone https://github.com/HumaGitGud/Code-IT.git
cd Code-IT
```

### 4. Install Dependencies
```bash
jlpm install
```

### 5. Build the Extension
The settings are stored in yarn.lock
```bash
jlpm run build
```

### 6. Install the Extension on TLJH
```bash
# Update the extension (with sudo)
sudo -E jupyter labextension develop --overwrite .

# Rebuild JupyterLab (with sudo)
sudo -E jupyter lab build

# Restart JupyterHub
sudo systemctl restart jupyterhub
```

### 7. Verify Installation
Check that the extension is installed and enabled:
```bash
jupyter labextension list
```

Look for `code-it` in the list with a note indicating it's in development mode.

Hard refresh your browser: `Ctrl+Shift+R` (Windows/Linux) or `Cmd+Shift+R` (Mac)

## Development Workflow

### Watch Mode (for active development)
In a separate terminal, run:
```bash
jlpm run watch
```
This automatically rebuilds when you make changes to TypeScript files.

### After Making Code Changes
1. If watch mode is running, it will rebuild automatically
2. If not, run `jlpm run build`
3. Update and rebuild:
```bash
sudo -E jupyter labextension develop --overwrite .
sudo -E jupyter lab build
sudo systemctl restart jupyterhub
```
4. Hard refresh your browser (`Ctrl+Shift+R`)

## Troubleshooting

### Extension not updating after changes?
Try a full clean rebuild:
```bash
jlpm run clean
rm -rf node_modules lib
jlpm install
jlpm run build
sudo -E jupyter labextension develop --overwrite .
sudo -E jupyter lab build
sudo systemctl restart jupyterhub
```

### Check if server extension is enabled
```bash
jupyter server extension list
```

### Check if frontend extension is installed
```bash
jupyter labextension list
```

### Check JupyterHub logs
```bash
sudo journalctl -u jupyterhub -f
```

### Browser console errors
Open browser DevTools (F12) and check the Console tab for errors.

## Project Structure
```
code-it/
├── src/              # TypeScript source files
├── style/            # CSS styles
├── code_it/          # Python server extension
├── package.json      # Node.js dependencies
├── tsconfig.json     # TypeScript configuration
└── pyproject.toml    # Python package configuration
```

## Uninstalling

### Remove the extension from TLJH
```bash
sudo -E jupyter labextension uninstall code-it
sudo -E jupyter lab build
sudo systemctl restart jupyterhub
```

### Uninstall Python package
```bash
pip uninstall code_it
```

## Resources
- [JupyterLab Extension Developer Guide](https://jupyterlab.readthedocs.io/en/stable/extension/extension_dev.html)
- [TLJH Documentation](https://tljh.jupyter.org/)
- [JupyterLab RTC Documentation](https://jupyterlab.readthedocs.io/en/stable/user/rtc.html)