### Update system

```bash
sudo apt update && sudo apt upgrade -y
```
### Install XFCE desktop

```bash
sudo apt install xfce4 xfce4-goodies -y
```
### Install xrdp

```bash
sudo apt install xrdp -y
sudo systemctl enable xrdp
sudo systemctl start xrdp
```

### Create a new user

Run these commands in your VPS terminal:

```bash
# Create a new user (replace 'user1' with any name you like)
adduser user1

# Add the new user to the sudo group so it can run admin commands
usermod -aG sudo user1
```
#### Switch to the new user

```bash
su - user1
```

### Configure session for `user1`

```bash
echo "xfce4-session" > /home/user1/.xsession
chown user1:user1 /home/user1/.xsession
```

Edit the xrdp start script:

```bash
sudo nano /etc/xrdp/startwm.sh
```

Replace the last two lines with:

```bash
startxfce4
```

Restart services:

```bash
sudo systemctl restart xrdp
sudo systemctl restart xrdp-sesman
```

### Open firewall port 3389

If UFW is available:

```bash
sudo apt install ufw -y
sudo ufw allow 3389/tcp # For RDP
sudo ufw allow 22/tcp   # For SSH
sudo ufw enable
```

If not, use iptables:

```bash
sudo iptables -A INPUT -p tcp --dport 3389 -j ACCEPT
```

## Install browsers

**Edge:**

```bash
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list
sudo apt update
sudo apt install microsoft-edge-stable -y
```

## Install RustDesk

Download the latest `.deb` from RustDesk releases:

```bash
wget https://github.com/rustdesk/rustdesk/releases/download/1.4.9/rustdesk-1.4.9-x86_64.deb
sudo apt install -fy ./rustdesk-1.4.9-x86_64.deb
```

## Q&A

if rustdesk given error "Display not found" then run this cmd `startxfce4 &`

---


