## 💻 Main Comments

```bash
top
htop            # Task Manager
uname -a        # full system info
uname -r        # kernel version
lsb_release -a  # distro release info (if available)
cat /etc/os-release   # distribution details

lscpu           # CPU details
free -h         # memory info
df -h           # disk usage
lsblk           # block devices

ip addr show    # IP addresses
ip route        # routing table
netstat -tulnp  # active network connections

whoami          # current user
who             # logged-in users
ps aux          # running processes
top             # system resource usage (interactive)
```

## 👤Users Details

```bash
cat /etc/passwd        # shows all users with details
cut -d: -f1 /etc/passwd   # shows only usernames
```

## 🖥️ Check Desktop Environment

Most desktop environments (like XFCE, GNOME, KDE) are just packages. To see what’s installed:

```bash
echo $XDG_CURRENT_DESKTOP   # shows current desktop environment if running
echo $DESKTOP_SESSION       # shows session name
```

Or check installed packages (depends on distro):

- **Debian/Ubuntu**:
```bash
dpkg --get-selections | grep xfce
dpkg --get-selections | grep gnome
dpkg --get-selections | grep kde
```

- **RHEL/CentOS/Fedora**:
```bash
rpm -qa | grep xfce
rpm -qa | grep gnome
rpm -qa | grep kde
```
### 🔑 Check if XRDP is Installed

```bash
dpkg -l | grep xrdp # Debian/Ubuntu
rpm -qa | grep xrdp # RHEL/CentOS/Fedora
```
### ⚙️ Check XRDP Service Status

```bash
systemctl status xrdp
```

## Program

### **Kill** 

```bash
pkill rustdesk
pkill -u user1 rustdesk # kills processes owned by `user1` 

killall rustdesk # more explicit

pkill -9 rustdesk # force‑kil

pgrep rustdesk  #Identify the PID number
kill <PID>
```

### **Open**

```bash
systemctl restart rustdesk

# launch
# The `&` runs it in the background so your terminal stays free.
rustdesk &

# If you’re on a VPS with no GPU, no in desktop
LIBGL_ALWAYS_SOFTWARE=1 rustdesk &
su - user1 -c "LIBGL_ALWAYS_SOFTWARE=1 rustdesk &" # for user1, not root

# Launch RustDesk with the correct display for user1
su - user1 -c "DISPLAY=:10 LIBGL_ALWAYS_SOFTWARE=1 rustdesk &"

# display for your desktop
echo $DISPLAY
```

### **Check Processes**

```bash
ps aux | grep rustdesk

pgrep -a rustdesk
pgrep -u user1 rustdesk
pgrep rustdesk #Identify the PID number

systemctl status rustdesk
```

### Example

#### How to kill and open again Rustdesk

```bash
# Kill
pkill -9 rustdesk

# Check is Running or not
pgrep -a rustdesk

# Open again in vps desktop
su - user1 -c "DISPLAY=:10 LIBGL_ALWAYS_SOFTWARE=1 rustdesk &"
```

#### How to change password?

```bash

# Open RustDesk’s config for your `user1` account:
nano /home/user1/.config/rustdesk/RustDesk.toml

# Edit password param value in .toml file
password = "user123"

# Restart RustDesk
pkill -u user1 rustdesk
su - user1 -c "DISPLAY=:10 LIBGL_ALWAYS_SOFTWARE=1 rustdesk &"
```