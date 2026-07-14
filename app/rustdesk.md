# Rustdesk

## Installation

```bash
VER_TAG=$(curl -s https://api.github.com/repos/rustdesk/rustdesk/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//') 
wget https://github.com/rustdesk/rustdesk/releases/download/${VER_TAG}/rustdesk-${VER_TAG}-x86_64.deb
sudo apt install -y ./rustdesk-${VER_TAG}-x86_64.deb
rm ./rustdesk-${VER_TAG}-x86_64.deb
```

## Example

### How to kill and open again Rustdesk GUI

#### Method-1

```bash
# Kill
pkill -9 rustdesk

# Check is Running or not
pgrep -a rustdesk

# Open again in vps desktop
su - user1 -c "DISPLAY=:10 LIBGL_ALWAYS_SOFTWARE=1 rustdesk &"
```

#### Method-2

```bash
# Kill old rustdesk
pkill rustdesk

# Set environment
# if `echo $XAUTHORITY` cmd retrun empty
# check display no - `echo $DISPLAY`
export DISPLAY=:10.0
export XAUTHORITY=/home/user1/.Xauthority

# Set password
rustdesk --password mypass123

# Start it (try normal mode first, not --service)
rustdesk &
disown
```

### How to change password?

```bash

# Open RustDesk’s config for your `user1` account:
nano /home/user1/.config/rustdesk/RustDesk.toml

# Edit password param value in .toml file
password = "abcd@1234"

# Restart RustDesk
pkill -u user1 rustdesk
su - user1 -c "DISPLAY=:10 LIBGL_ALWAYS_SOFTWARE=1 rustdesk &"
```

### Without GUI (NOT WORKING)

```bash
# Kill
pkill -9 rustdesk

# Check is Running or not
pgrep -a rustdesk

# Get Rustdesk ID
sudo -u user1 rustdesk --get-id

# Set Password
sudo -u user1 rustdesk --password Pr@123#456

# Open RustDesk’s config for your `user1` account:
nano /home/user1/.config/rustdesk/RustDesk.toml

# Restart
sudo systemctl restart rustdesk

# Check status
sudo systemctl status rustdesk

```


## Notes

If you are switching to `RustDesk` for remote access, you can uninstall `xRDP` to save even more RAM, as you won't need it anymore.

```bash
sudo apt remove xrdp
```

| Component | Status | Approx RAM |
| :--- | :--- | :--- |
| **RustDesk GUI** | **Closed** | 0 MB |
| **RustDesk Service** | **Running** | ~15 MB |
| **XFCE Desktop** | Running | ~300-400 MB (Required for screen capture) |
| **xRDP** | **Uninstalled** | Saves ~50-100 MB |