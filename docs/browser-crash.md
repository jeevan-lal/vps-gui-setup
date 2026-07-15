# Chromium / Browser Crash on VPS (Sad Face Icon)

## The Real Root Cause: systemd TasksMax
Your entire user session (XFCE + xrdp + panel + terminal + Chrome and **every thread of every process**) is confined to a cgroup with a hard limit of **675 tasks (threads)**.

- Your session at idle already uses ~269 threads (`ps -eLf | wc -l`)
- Chrome spawns a process per tab/extension/utility, each with 20–40 threads
- Opening Settings/Extensions pages spawns extra renderer + utility processes → limit hit → `pthread_create: Resource temporarily unavailable (11)` → `Zygote could not fork` → sad-face tab

*Why 675?* systemd's `DefaultTasksMax` is 15% of the kernel/container pid limit. 675 = 15% of 4500, which suggests your VPS container itself has a ~4500 pid ceiling set by the host. Setting `TasksMax=infinity` means you're now only bound by that container limit (~4500), which is plenty for Chrome.

## Verify It (optional but satisfying)
In one terminal:
```bash
watch -n1 cat /sys/fs/cgroup/user.slice/user-1000.slice/pids.current
```
Then launch Chrome and open Settings. You'll see the counter climb toward ~675 right as it crashes.

## The Primary Fix

Raise the systemd `TasksMax` limit. Setting `TasksMax=infinity` will prevent the session from artificially capping threads.

```bash
# Raise the limit for your user slice (persistent across reboots)
sudo systemctl set-property user-1000.slice TasksMax=infinity

# Also raise the global default so it applies to new sessions/users
sudo mkdir -p /etc/systemd/system/user-.slice.d
sudo tee /etc/systemd/system/user-.slice.d/override.conf <<EOF
[Slice]
TasksMax=infinity
EOF

sudo systemctl daemon-reload
```

Verify the limits:
```bash
systemctl show --property TasksMax user-1000.slice
# Should now show: TasksMax=infinity

cat /sys/fs/cgroup/user.slice/user-1000.slice/pids.max
# Should show: max
```

**Important:** Log out of your XRDP session completely and reconnect (so your session picks up the new limit), and run:
```bash
google-chrome --no-sandbox --disable-gpu --disable-dev-shm-usage
```
*No `taskset`, no `--renderer-process-limit`, no `--no-zygote` needed.*

---

## Legacy Workaround (Taskset & Process Limits)
*(Note: The `TasksMax` fix above is the proper solution. This older workaround is kept for historical context.)*

Initially, it seemed Chromium crashed because it detected 24+ physical CPUs and tried to spawn threads for all of them, ignoring the cgroup limit of 3 CPU cores (`nproc`).

The workaround was to create a launcher script pinning the CPU and limiting renderer processes:

### 1. Create a wrapper script (as root):
```bash
sudo nano /usr/local/bin/chromium-launcher
```

```bash
#!/bin/bash
taskset -c 0-3 /snap/bin/chromium --no-sandbox --disable-gpu --disable-dev-shm-usage --renderer-process-limit=2 "$@"
```

```bash
sudo chmod +x /usr/local/bin/chromium-launcher
```

Now you could launch the browser using `chromium-launcher`. This worked because restricting cores and renderers kept the thread count artificially low, staying under the hidden `TasksMax=675` limit.
