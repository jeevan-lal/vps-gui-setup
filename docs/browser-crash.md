## What Your System Info Tells Us

| Check | Result | Meaning |
|---|---|---|
| `ulimit -u` | unlimited | ✅ No process limit |
| `nproc` | 3 | Your VPS is cgroup-limited to **3 CPU cores** |
| `user_beancounters` | empty | Not OpenVZ (likely KVM/LXC — good) |
| RAM | 5859 MB total, 5419 MB available | ✅ Plenty of memory |
| Swap | 0 | ⚠️ No swap (minor concern, RAM is fine for now) |

**Root cause found:** Remember these errors from your earlier logs?
```
open /sys/devices/system/cpu/cpu23/cpufreq/... No such file or directory
pthread_create: Resource temporarily unavailable (11)
```

That means Chromium was detecting **24+ CPUs** (the physical host's CPUs are visible inside your container) and trying to spawn threads/processes for all of them — but your container's cgroup only allows **3 cores**. The excess thread creation was rejected → renderer processes died → sad face crash icon.

**Why your fix works:**
- `taskset -c 0-3` → pins Chromium to the cores it can actually use, so it stops over-detecting
- `--renderer-process-limit=2` → limits renderer processes so each tab doesn't spawn a new process

---

## Make It Permanent

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

Now just type `chromium-launcher` anytime.