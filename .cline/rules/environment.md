# Environment

You are operating inside a **Debian Docker container**. Your current working directory is `/workspace`. The only directory that may be mounted from the host machine is `/workspace` — treat everything else as ephemeral and fully under your control.

## Freedom to act

You can install packages, modify system files, and do anything you need without restrictions. The container is disposable: there is no risk of permanently damaging the host system.

```bash
sudo apt install -y <package>   # install anything you need
```

## File visibility caveat (Docker overlay filesystem)

Files created by a command may **not be visible** to a subsequent command when each is executed as a **separate shell invocation**. This is due to Docker's overlay filesystem caching: newly created files in the upper layer can have a delayed visibility for new process lookups.

**Symptoms:** a command like `scrot /tmp/img.png` exits successfully (exit 0) and the file is correctly written, but a following `ls /tmp/img.png` in a **separate command** reports "No such file or directory".

**Workaround:** chain commands that depend on each other's files with `&&` in a **single shell string**:

```bash
# ❌ File may not be visible in the second command
scrot /tmp/img.png
ls /tmp/img.png          # → "No such file or directory"

# ✅ Chained commands share the same process context
scrot /tmp/img.png && ls /tmp/img.png   # → file exists
```

This applies to **all** tools (scrot, dd, echo, python, etc.), not just scrot.

## Background process timeout caveat (run_commands tool)

The `run_commands` tool has a **30-second timeout** per command. When the timeout expires, the tool kills the **entire process group** of the shell, including any background processes launched with `&`.

**Why this matters:** Long-running GUI applications (e.g., `xeyes`, `firefox`, `vlc`) launched with `DISPLAY=:0 app &` will be killed after 30 seconds because they share the same process group as the parent shell.

**Symptoms:** An application appears to start but is not visible in subsequent screenshots — it was silently killed by the timeout.

**Workaround:** Use `setsid` to detach the process into its own session and process group, so it survives independently:

```bash
# ❌ Killed after 30s timeout
DISPLAY=:0 xeyes &

# ✅ Survives — runs in its own session
DISPLAY=:0 setsid xeyes </dev/null >/dev/null 2>&1 &
```

Key points:
- `setsid` creates a new session (SID) and process group (PGID) for the child, independent of the parent shell's group
- Redirect stdin/stdout/stderr (`</dev/null >/dev/null 2>&1`) prevents the shell from waiting on the process's I/O
- The process will persist until explicitly killed (e.g., `killall xeyes`)
- This is critical for **any long-running background process** — not just GUI apps

## Virtual desktop

A virtual X11 display is running on `DISPLAY=:0` (1280×1024), powered by **Xvfb** (X Virtual Framebuffer) with **Fluxbox** as the window manager. You can launch and interact with graphical applications (GUI) on it. The desktop is also accessible via browser through noVNC on port 5901.

Always set `DISPLAY=:0` when launching GUI applications:

```bash
DISPLAY=:0 <application> &
```

## Available runtimes

- **Python 3**: `python3`, `pip3`, `venv`
- **Node.js**: `node`, `npm`

## Available tools

### scrot — screenshots

Take a screenshot of the virtual desktop:

```bash
DISPLAY=:0 scrot /tmp/screenshot.png
```

### xdotool — mouse and keyboard automation

Simulate user input and control windows on the virtual desktop:

```bash
DISPLAY=:0 xdotool type "hello world"
DISPLAY=:0 xdotool key Return
DISPLAY=:0 xdotool mousemove 640 512 click 1
DISPLAY=:0 xdotool getactivewindow windowfocus
```

### imagemagick — image manipulation

Process, crop, resize or inspect screenshots and images:

```bash
convert /tmp/screenshot.png -crop 300x200+100+50 /tmp/region.png
convert /tmp/screenshot.png -resize 50% /tmp/small.png
identify /tmp/screenshot.png   # get image info (size, format, …)
```

### playwright-cli — browser automation

Automate browser interactions and test web pages headlessly or on the virtual desktop. This tool is also available as a **skill**, which provides direct structured access to browser automation actions.

Basic usage:

```bash
# Open a browser and navigate to a page
playwright-cli open https://example.com

# Take a snapshot of the page (ARIA tree — preferred over screenshots)
playwright-cli snapshot

# Click an element by its ref from the snapshot
playwright-cli click e3

# Type text into the focused element
playwright-cli type "hello world"

# Take a screenshot
playwright-cli screenshot --filename=/tmp/page.png

# Close the browser
playwright-cli close
```

## Suggested workflow for GUI tasks

1. Launch the target application with `DISPLAY=:0`
2. Take a screenshot with `scrot` to observe the current state
3. Use `imagemagick` to crop or analyze the relevant region if needed
4. Use `xdotool` to interact (click, type, key press)
5. Repeat from step 2 until the task is complete
