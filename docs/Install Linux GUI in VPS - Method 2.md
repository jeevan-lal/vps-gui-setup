
```bash
sudo apt update && sudo apt upgrade -y
```
### 👤 Create the User

```bash
sudo adduser --gecos "" user1        # create user and set password
sudo usermod -aG sudo user1   # give sudo privileges (optional)
```

### 🖥️ Assign Desktop Environment

The desktop environment itself (XFCE, GNOME, etc.) is installed system‑wide, not per user. Once installed, every user can log in to it. To make sure `user1` uses it:

1. **Install XFCE (lightweight desktop)**
    
    ```bash
    sudo apt install xfce4 -y
    ```
    
2. **Install XRDP for remote desktop access**
    
    ```bash
    sudo apt install xrdp -y
    sudo systemctl enable xrdp
    sudo systemctl start xrdp
    ```
    
3. **Set XFCE as default session for XRDP**  
    Edit the startup file for `user1`:
    
    ```bash
    echo "startxfce4" | sudo tee /home/user1/.xsession
    sudo chown user1:user1 /home/user1/.xsession
    ```
    
    This ensures that when `user1` logs in via XRDP, XFCE will start.
    
- Restart XRDP service:
    
    ```bash
    sudo systemctl restart xrdp
    ```

## Install browsers

**Edge:**

```bash
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list
sudo apt update
sudo apt install microsoft-edge-stable -y
```

**Chrome**

```bash
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb

# REMOVE
sudo apt purge google-chrome-stable
```

**Chromium**

```bash
sudo apt install chromium-browser
```

Brave

```bash
sudo apt install curl -y
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
  https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] \
https://brave-browser-apt-release.s3.brave.com/ stable main" | \
sudo tee /etc/apt/sources.list.d/brave-browser-release.list

sudo apt update
sudo apt install brave-browser -y
```

## Zip

```bash
sudo apt update && sudo apt install thunar-archive-plugin -y

# Restart
sudo reboot
```

