
## Condition

### Check Display Number

If you running from SSH/`su`, not from the XRDP (GUI) terminal. 
So `DISPLAY` was empty after `su - user1`.

```bash
# Login with root user
# Switch to user1
su - user1

# Check Display Number
echo $DISPLAY

# then show output empty
# try `echo $DISPLAY` in root user or GUI xrdp terminal
# You will usually see something like :10, :11, or :1.
```

### Check XAUTHORITY

```bash
echo $XAUTHORITY

# Output: /home/user1/.Xauthority

# Sometime output comes empty
export XAUTHORITY=/home/user1/.Xauthority
```

## How to Start?

```bash
# Switch to user1
su - user1

# stop old rustdesk
pkill -u user1 -x rustdesk 2>/dev/null
sudo pkill -9 rustdesk 2>/dev/null

# use the WORKING display
export DISPLAY=:11.0
unset XAUTHORITY

# allow access
xhost +SI:localuser:user1
xhost +SI:localuser:root

# verify
xdpyinfo | head -3
```

You should see:

```text
name of display:    :11.0
```

### Set password (needs privileges)

#### Method-1

```bash
sudo rustdesk --password 'P3#456'
rustdesk --get-id
```

#### Method-2

```bash
# if `RustDesk.toml` file not exists then run this cmd.
rustdesk --get-id

# Open RustDesk’s config for your `user1` account:
nano /home/user1/.config/rustdesk/RustDesk.toml

# Edit password param value in .toml file
password = "abcd@1234"
```

## Run Rustdesk Service mode on `:11.0` Display

```bash
nohup env DISPLAY=:11.0 XAUTHORITY=/dev/null /usr/bin/rustdesk --service \
  > /tmp/rustdesk-service.log 2>&1 &
disown

# Check is Running or not
pgrep -a rustdesk

# Check logs
tail -50 /tmp/rustdesk-service.log
```

✅ **RustDesk Processes**:
- `133495 /usr/bin/rustdesk --service` (headless service)
- `135011 /usr/share/rustdesk/rustdesk --server` (backend)
- `135020 /usr/share/rustdesk/rustdesk --tray` (minimal UI)

### 🚫 **Close the GUI Window (If Open)**

If you see a RustDesk window in your XRDP session, close it with:

```bash
pkill -f "rustdesk --tray"
```

⚠️ **Do NOT kill `--service`

### 📊 **Check RAM Usage (Headless Mode)**
Run this to confirm low RAM usage:

```bash
ps -u user1 -o pid,rss,comm | grep rustdesk | awk '{sum+=$2} END {print "Total RustDesk RAM: " sum/1024 " MB"}'
```

- **Expected**: ~15-30 MB (vs 100MB with full GUI)
- If it's still high, the GUI window might still be open.