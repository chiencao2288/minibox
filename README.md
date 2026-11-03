# minibox 📦

**Lightweight rootless Debian GUI & Gaming container manager for Podman on Fedora Linux.**

Designed for complete home directory isolation, zero host pollution, automatic multi-GPU hardware acceleration, native Wayland & PipeWire integration, and out-of-the-box AAA gaming & AI support.

---

> [!WARNING]
> ### Mandatory System Requirements
> **minibox is strictly tailored for the following environment:**
> - **Host OS:** **Fedora Linux** (tested & officially supported on Fedora 40+, kernel 5.2+).
> - **Container Engine:** **Podman (Rootless only)**. Docker is **NOT** supported. Never run minibox as `root` or with `sudo`.
> - **Display Server:** **Pure Wayland** (`$WAYLAND_DISPLAY`, e.g. `wayland-0`). Standalone legacy X11 sessions are not supported.
> - **Audio Server:** **PipeWire** (`pipewire-0`).

---

## ✨ Key Features

- **🛡️ Strict Home Directory Isolation:** Prevents host pollution. All user caches, configuration files, and game saves remain isolated in your designated box home folder (`~/.local/share/minibox/boxes/<box-name>/home` or custom `MINIBOX_HOME`).
- **👤 1:1 Host User Mapping & Custom Hostname:** Container username and UID/GID default 1:1 with your host user, while the container hostname matches the box name, yielding a clean shell prompt (`user@box-name:~$`).
- **🚀 100% Native Podman Architecture (No Prescripts):** Built on native Podman rootless primitives (`--userns=keep-id`, `--passwd-entry`, `--group-entry`, `--group-add keep-groups`, `--init`, volume `:U,z`) for instant container startup and proper process reaping.
- **⚡ Automatic Multi-GPU Hardware Acceleration:** Automatically attaches AMD/Intel DRI devices (`/dev/dri`, `/dev/kfd`) and NVIDIA GPUs via Container Device Interface (CDI `nvidia.com/gpu=all`).
- **🎵 Pure Wayland & PipeWire Integration:** Native Wayland socket forwarding (`wayland-0`) and PipeWire audio (`pipewire-0`) without legacy X11 overhead.
- **🔌 Kernel-Level Live Hot-Mounting (`mount` / `umount`):** Dynamically inject or remove host directories (like USB drives or external storage) into a running container's mount namespace on the fly using Linux Mount API (`open_tree` + `setns` + `move_mount`), without restarting the container.
- **📁 Bidirectional File Transfer (`cp`):** Copy files and directories seamlessly between host and container (`minibox cp`) at any time, whether the box is running or stopped.
- **💾 Flexible Storage Root (`MINIBOX_HOME`):** Easily relocate all box data and isolated home directories to secondary NVMe SSDs or external drives via the `MINIBOX_HOME` environment variable or local `.env`.
- **🎮 Out-of-the-Box AAA Offline Gaming Stack:** Pre-baked Visual C++ (2005–2022 x86 & x64), .NET runtime (Wine-Mono), DXVK (DirectX 9/10/11 -> Vulkan), D3D compilers, and full GStreamer cutscene codecs for hassle-free offline gaming.
- **🔑 Passwordless Sudo:** The box user has full `sudo` privileges configured with `NOPASSWD: ALL`—just run commands and hit Enter without typing passwords.

---

## 📦 Container Image Presets

| Preset | Image URL | Description |
| :--- | :--- | :--- |
| **`normal`** *(default)* | `ghcr.io/chiencao2288/debian-box:normal` | Lightweight Debian GUI base with Mesa DRI, Vulkan, Wayland, PipeWire, and NOPASSWD sudo. |
| **`wine`** | `ghcr.io/chiencao2288/debian-box:wine` | Optimized for Windows apps & AAA offline games. Includes multi-arch 32-bit (`i386`), Wine, full Visual C++ (2005–2022), .NET (Wine-Mono), DXVK, D3D compilers, GStreamer cutscene codecs, and core fonts. |
| **`ai`** | `ghcr.io/chiencao2288/debian-box:ai` | Optimized for local AI/ML workloads. Includes Python 3, pip, venv, build tools, git-lfs, and CUDA runtime compatibility (PyTorch, ComfyUI, etc.). |

*Custom images are also supported via any valid container image URL (e.g. `--image=docker.io/...`).*

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

## 📖 Command Reference

| Command | Syntax | Description |
| :--- | :--- | :--- |
| **`create`** | `minibox create <box-name> [options...]` | Create a new container box. |
| **`enter`** | `minibox enter <box-name>` | Enter interactive shell (`/bin/bash --login`) as box user. |
| **`run`** | `minibox run <box-name> <command...>` | Execute a command directly inside the box (supports `sudo`). |
| **`mount`** | `minibox mount <box> <host-path> <dest>` | Hot-mount a host path into a running container on the fly. |
| **`umount`** | `minibox umount <box> <dest>` | Unmount a hot-mounted path from a running container. |
| **`cp`** | `minibox cp <src> <dest>` | Copy files/folders between host and container. |
| **`start`** | `minibox start <box-name>` | Start box daemon in the background. |
| **`stop`** | `minibox stop <box-name>` | Stop a running box. |
| **`restart`** | `minibox restart <box-name>` | Restart a running box. |
| **`list`**, **`ls`** | `minibox list` | List all managed boxes and their current statuses. |
| **`rm`** | `minibox rm <box-name> [--purge]` | Remove container. Add `--purge` to permanently delete home folder. |
| **`gpu-probe`** | `minibox gpu-probe` | Probe host GPU hardware (DRI, KFD, Nvidia CDI). |
| **`provision`** | `minibox provision [preset]` | Pre-pull or build container images (`normal`, `wine`, `ai`). |

---

## 🚀 Quickstart & Practical Usage

### 1. Creating Containers

```bash
# Create a standard development container
minibox create dev-box --image=normal

# Create a gaming container with custom directory mounts (-v)
minibox create game-box --image=wine -v /run/media/chiencao/Games:/games

# Create an AI workspace
minibox create ai-lab --image=ai
```

#### Creation Options:
- `--image=<preset|url>`: Choose preset (`normal`, `wine`, `ai`) or an arbitrary container image URL.
- `--user=<name>`: Override container username (default: matches your host user).
- `-v, --volume=<host_path>:<container_path>[:opts]`: Mount host directories into the container. Can be specified multiple times.

---

### 2. Working Inside the Box

#### Interactive Shell
```bash
minibox enter dev-box
```

#### Running Commands Directly (with Passwordless Sudo)
```bash
# Run package management commands without password prompts
minibox run dev-box sudo apt update
minibox run dev-box sudo apt install htop neofetch -y

# Launch GUI tools or games directly
minibox run game-box winecfg
minibox run game-box wine /games/MyGame/game.exe
```

---

### 3. Dynamic Hot-Mounting (Live Mount / Umount)

You can attach or detach host folders and USB drives to a **running container** without stopping or restarting it:

```bash
# Hot-mount a USB drive into the container
minibox mount game-box /run/media/chiencao/USB /mnt/usb

# Hot-mount a local data directory
minibox mount ai-lab ~/Downloads/models /home/chiencao/models

# Unmount when done
minibox umount game-box /mnt/usb
minibox umount ai-lab /home/chiencao/models
```

---

### 4. Copying Files Between Host and Box (`cp`)

Copy files and directories in both directions, even when the container is stopped:

```bash
# Host -> Container
minibox cp ./archive.zip ai-lab:/home/chiencao/
minibox cp in ai-lab ./archive.zip /home/chiencao/

# Container -> Host
minibox cp ai-lab:/home/chiencao/output.png ./
minibox cp out ai-lab /home/chiencao/output.png ./
```

---

### 5. Relocating Storage Root (`MINIBOX_HOME`)

By default, all boxes and their isolated home directories reside in `~/.local/share/minibox/boxes`. You can relocate this storage to any secondary SSD, NVMe, or external drive:

```bash
# Option A: Export globally in ~/.bashrc:
export MINIBOX_HOME="/mnt/nvme/minibox"

# Option B: Use per-command:
MINIBOX_HOME="/mnt/nvme/minibox" minibox create game-box --image=wine

# Option C: Use a local .env file in your working directory:
echo 'MINIBOX_HOME="/mnt/nvme/minibox"' > .env
minibox create game-box --image=wine
```

---

### 6. Container Lifecycle & Cleanup

```bash
# View all boxes and their storage locations
minibox list

# Start, stop, or restart a box
minibox stop game-box
minibox start game-box
minibox restart game-box

# Remove container while preserving home folder data
minibox rm game-box

# Permanently delete container AND purge its isolated home folder
minibox rm game-box --purge
```

---

### 7. Hardware Diagnostics

Verify your host GPU devices, DRI nodes, and Container Device Interface (CDI) configuration:

```bash
minibox gpu-probe
```

---

## 🎮 AAA Offline Gaming Guide (Preset `wine`)

The `wine` image preset is pre-configured specifically for running modern Windows single-player and offline AAA titles on Linux:

1. **Pre-baked Visual C++ (2005–2022):** All `vcrun` DLLs (`msvcp140.dll`, `vcruntime140.dll`, etc.) are pre-seeded in the container template, eliminating missing DLL errors.
2. **.NET Support:** Wine-Mono is pre-installed for launchers, trainers, and modding tools.
3. **Vulkan Translation (DXVK):** Translates DirectX 9, 10, and 11 to Vulkan for native-speed GPU rendering on NVIDIA and AMD cards.
4. **Multimedia & Cutscene Fixes:** Full multi-arch GStreamer plugin stack (`good`, `bad`, `ugly`, `libav`) prevents black-screen errors during in-game cutscenes and intro videos.

```bash
# Example: Launch an offline AAA game from an external drive
minibox create gaming --image=wine -v /run/media/chiencao/Games:/games
minibox run gaming wine /games/Cyberpunk2077/bin/x64/Cyberpunk2077.exe
```

---

## 🤖 AI / Machine Learning Guide (Preset `ai`)

The `ai` image preset provides an isolated sandbox for running CUDA-accelerated workloads (ComfyUI, Ollama, PyTorch, vLLM) with direct access to host NVIDIA hardware:

```bash
# Create an AI box
minibox create ai-lab --image=ai

# Run interactive bash and set up Python virtual environment
minibox enter ai-lab
python3 -m venv ~/venv
source ~/venv/bin/activate
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124
```

---

## 📂 Project Structure

```text
minibox/
├── minibox                        # Main executable CLI script
├── install.sh                     # One-liner automated installer
├── Containerfile.normal           # Base Debian GUI image
├── Containerfile.wine             # Debian GUI + Gaming runtime stack (VC++, .NET, DXVK)
├── Containerfile.ai               # Debian GUI + Python + CUDA tools
├── .github/workflows/
│   └── build-images.yml           # Automated CI/CD pipeline building ghcr.io images
└── README.md                      # Documentation
```

---

## 📄 License

Distributed under the [MIT License](LICENSE).
