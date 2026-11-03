# minibox 📦

Lightweight rootless Debian GUI container manager for **Podman** on Fedora Linux. Designed for complete home directory isolation, zero host pollution, automatic multi-GPU hardware acceleration, and native Wayland & PipeWire integration.

> [!WARNING]
> ### Mandatory System Requirements & Compatibility
> **minibox is strictly tailored for the following environment:**
> - **Host OS:** **Fedora Linux** (tested & officially supported on Fedora 44+, kernel 7.1+).
> - **Container Engine:** **Podman (Rootless only)**. Docker is **NOT** supported. Never run minibox as `root` or with `sudo`.
> - **Display Server:** **Pure Wayland** (`$WAYLAND_DISPLAY`, e.g. `wayland-0`). Standalone legacy X11 sessions are not supported.
> - **Audio Server:** **PipeWire** (`pipewire-0`).
>
> If your host system does not satisfy these requirements, **minibox will not work as intended**.

---

## Key Features

- **Strict Home Directory Isolation:** Prevents host pollution. All user caches, configuration files, and game saves remain isolated in `~/.local/share/minibox/boxes/<box-name>/home`.
- **1:1 Host User Mapping & Box Hostname:** Container username defaults 1:1 with your host user, while the container hostname matches the box name, yielding a clean and recognizable shell prompt (`user@box-name:~$`). You can still override via `--user=<name>`.
- **100% Native Podman Architecture (No Prescripts):** Relies on native Podman features (`--userns=keep-id`, `--passwd-entry`, `--group-entry`, `--group-add keep-groups`, `--init`, volume `:U,z`) for instant container startup and proper process reaping.
- **Automatic Multi-GPU Hardware Acceleration:** Automatically attaches available AMD/Intel DRI devices (`/dev/dri`, `/dev/kfd`) and NVIDIA GPUs via Container Device Interface (CDI `nvidia.com/gpu=all`).
- **Pure Wayland & PipeWire Integration:** Native Wayland socket forwarding (`wayland-0`) and PipeWire audio (`pipewire-0`) without legacy X11 overhead.
- **3 Flexible Image Presets (`--image=...`):**
  - `normal` *(default)*: Lightweight Debian GUI base with Mesa DRI, Vulkan, Wayland, PipeWire, and NOPASSWD sudo.
  - `wine`: Optimized for Windows & AAA offline gaming. Pre-installed with multi-arch 32-bit (`i386`), Wine, full Visual C++ (2005–2022 x86/x64), .NET Framework (Wine-Mono), DXVK (Vulkan DX9/10/11), GStreamer cutscene codecs, D3D compilers, and Microsoft core fonts. NOPASSWD sudo included.
  - `ai`: Optimized for local AI workloads. Includes Python 3, pip, venv, build tools, git-lfs, and CUDA runtime compatibility.
  - Custom images are also supported via arbitrary image URLs.

---

## ⚡ Quick Install (One-Liner)

Install `minibox` directly into `~/.local/bin` with a single command:

```bash
curl -fsSL https://raw.githubusercontent.com/chiencao2288/minibox/main/install.sh | bash
```

To install into a custom directory:
```bash
curl -fsSL https://raw.githubusercontent.com/chiencao2288/minibox/main/install.sh | bash -s /usr/local/bin
```

---

## Quickstart & Usage

### Basic Syntax
```bash
minibox <command> [options...]
```

### Container Management
```bash
# Create a new box with preset and optional custom volume mounts (-v)
./minibox create dev-box --image=normal -v /path/on/host:/data
./minibox create my-game --image=wine
./minibox create ai-lab --image=ai

# Open an interactive shell inside the container (as box user)
./minibox enter dev-box

# Run a command or launch a GUI application directly
./minibox run my-game winecfg

# Run a command with passwordless sudo (run & enter, no password needed)
./minibox run dev-box sudo apt update

# Copy files between host and container
./minibox cp ./model.bin ai-lab:/home/chiencao/
./minibox cp ai-lab:/home/chiencao/output.png ./

# Hot-mount host directory into running container (without restart)
./minibox mount dev-box /run/media/chiencao/USB /mnt/usb
./minibox umount dev-box /mnt/usb

# Container lifecycle management
./minibox list
./minibox stop my-game
./minibox start my-game
./minibox restart my-game

# Remove container while preserving home directory data
./minibox rm my-game

# Permanently delete container and its isolated home folder
./minibox rm my-game --purge
```

### Custom Storage Root (`MINIBOX_HOME`)
By default, all boxes and their isolated home directories reside in `~/.local/share/minibox/boxes`. You can override this root to any secondary NVMe, SSD, or external drive:

```bash
# Set in your environment (~/.bashrc) or per command:
export MINIBOX_HOME="/mnt/nvme/minibox"
# (or via ./.env: MINIBOX_HOME="/mnt/nvme/minibox")

# Boxes created will automatically be rooted at /mnt/nvme/minibox/boxes/<name>/home:
minibox create game-box --image=wine
```

### Hardware Diagnostics
```bash
# Probe host GPU devices, DRI nodes, and CDI configurations
./minibox gpu-probe
```

---

## Directory Structure

```text
mini-box/
├── minibox                        # Main executable CLI script
├── Containerfile.normal           # Base Debian GUI image
├── Containerfile.wine             # Debian GUI + Wine + DXVK + Windows fonts
├── Containerfile.ai               # Debian GUI + Python + CUDA tools
├── .github/workflows/
│   └── build-images.yml           # Automated CI/CD pipeline building ghcr.io images
└── README.md                      # Documentation
```
