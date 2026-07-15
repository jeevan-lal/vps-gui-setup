# VPS GUI Setup

This repository contains scripts to easily set up a Desktop Environment (GUI) and other essential software on a Linux Virtual Private Server (VPS).

## Features

The repository includes two scripts for your convenience:
- `vps_setup.sh`: An interactive, step-by-step menu that asks for your input before running each section.
- `vps_setup_auto.sh`: An automated version that asks all configuration questions upfront and then runs all selected sections without further intervention.

Both scripts install and configure:
- System updates and upgrades
- New system user creation (with sudo privileges)
- Lightweight Desktop Environment (XFCE4) & Remote Desktop Protocol (XRDP)
- Web Browsers (Google Chrome, Microsoft Edge, Chromium, Brave)
- Zip & Archive Utilities (Thunar Archive Plugin)

## Download and Run

You can download and execute the scripts directly from this repository using either `wget` or `curl`.

### Using `wget`
```bash
# For the step-by-step interactive script
wget https://raw.githubusercontent.com/jeevan-lal/vps-gui-setup/main/method-01/vps_setup.sh
chmod +x vps_setup.sh
./vps_setup.sh

# OR for the fully automated script
wget https://raw.githubusercontent.com/jeevan-lal/vps-gui-setup/main/method-01/vps_setup_auto.sh
chmod +x vps_setup_auto.sh
./vps_setup_auto.sh
```

### Using `curl`
```bash
# For the step-by-step interactive script
curl -O https://raw.githubusercontent.com/jeevan-lal/vps-gui-setup/main/method-01/vps_setup.sh
chmod +x vps_setup.sh
./vps_setup.sh

# OR for the fully automated script
curl -O https://raw.githubusercontent.com/jeevan-lal/vps-gui-setup/main/method-01/vps_setup_auto.sh
chmod +x vps_setup_auto.sh
./vps_setup_auto.sh
```

## How to Use
1. Run the script as a user with `sudo` privileges (or as `root`).
2. Depending on the script you chose:
   - `vps_setup.sh`: The script will ask you whether you want to execute or skip each section, step-by-step. Type `y` or `yes` to execute, and any other key to skip.
   - `vps_setup_auto.sh`: The script will ask you all your configuration preferences at the very beginning. Once answered, it will proceed to run all the selected sections automatically without further prompts.
3. For software like web browsers, it allows multi-selection via a numbered menu.
4. After completion, a summary report will be displayed, and you will have the option to reboot your VPS to finalize the setup.
