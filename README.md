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
  - `wine`: Optimized for Windows games and applications. Includes multi-arch 32-bit (`i386`), Wine-staging, Winetricks, DXVK, and Microsoft core fonts.
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
# Create a new box with the desired preset
./minibox create my-game --image=wine --mounts
./minibox create dev-box --image=normal
./minibox create ai-lab --image=ai

# Open an interactive shell inside the container (as box user)
./minibox shell my-game

# Launch a GUI application directly
./minibox shell my-game winecfg

# Execute a command as root from the host
./minibox root my-game apt update

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
