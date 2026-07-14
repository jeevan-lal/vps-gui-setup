# VPS GUI Setup

This repository contains scripts to easily set up a Desktop Environment (GUI) and other essential software on a Linux Virtual Private Server (VPS).

## Features

The `vps_setup.sh` script provides an interactive, step-by-step menu to install and configure:
- System updates and upgrades
- New system user creation (with sudo privileges)
- Lightweight Desktop Environment (XFCE4) & Remote Desktop Protocol (XRDP)
- Web Browsers (Google Chrome, Microsoft Edge, Chromium, Brave)
- Zip & Archive Utilities (Thunar Archive Plugin)

## Download and Run

You can download and execute the `vps_setup.sh` script directly from this repository using either `wget` or `curl`.

### Using `wget`
```bash
wget https://raw.githubusercontent.com/jeevan-lal/vps-gui-setup/main/method-01/vps_setup.sh
chmod +x vps_setup.sh
./vps_setup.sh
```

### Using `curl`
```bash
curl -O https://raw.githubusercontent.com/jeevan-lal/vps-gui-setup/main/method-01/vps_setup.sh
chmod +x vps_setup.sh
./vps_setup.sh
```

## How to Use
1. Run the script as a user with `sudo` privileges (or as `root`).
2. The script will ask you whether you want to execute or skip each section. Type `y` or `yes` to execute, and any other key to skip.
3. For software like web browsers, it allows multi-selection via a numbered menu.
4. After completion, a summary report will be displayed, and you will have the option to reboot your VPS to finalize the setup.
