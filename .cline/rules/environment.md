# Environment

You are operating inside a **Debian Docker container**. The only directory that may be mounted from the host machine is `/workspace` — treat everything else as ephemeral and fully under your control.

## Freedom to act

You can install packages, modify system files, and do anything you need without restrictions. The container is disposable: there is no risk of permanently damaging the host system.

```bash
sudo apt install -y <package>   # install anything you need
```

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

## Suggested workflow for GUI tasks

1. Launch the target application with `DISPLAY=:0`
2. Take a screenshot with `scrot` to observe the current state
3. Use `imagemagick` to crop or analyze the relevant region if needed
4. Use `xdotool` to interact (click, type, key press)
5. Repeat from step 2 until the task is complete
