# wsl2-kernel-build

[![Build Status](https://github.com/pavelpikta/wsl2-kernel-build/actions/workflows/build.yml/badge.svg)](https://github.com/pavelpikta/wsl2-kernel-build/actions/workflows/build.yml)
[![WSL2](https://img.shields.io/badge/WSL2-Kernel%20Build-0078D4?logo=windows&logoColor=white)](https://github.com/microsoft/WSL2-Linux-Kernel)
[![Docker](https://img.shields.io/badge/Docker-Compatible-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Linux Kernel](https://img.shields.io/badge/Linux%20Kernel-6.6+-FCC624?logo=linux&logoColor=black)](https://www.kernel.org/)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)

A repository for building WSL2 Linux kernels with Docker compatibility and BBR (Bottleneck Bandwidth and RTT) support. This project provides automated tools and configurations to patch Microsoft's WSL2 kernel source with the necessary kernel options required for running Docker and improving network performance.

## Features

- 🐳 **Docker Compatibility**: Automatically patches WSL2 kernel config with all required options for Docker Engine
- 🚀 **BBR Support**: Enables BBR congestion control algorithm for improved network performance
- 🔧 **Automated Scripts**: Easy-to-use scripts for fetching and patching kernel configurations
- ☁️ **CI/CD Ready**: GitHub Actions workflow for automated kernel builds

## Overview

The default WSL2 kernel provided by Microsoft may not include all the kernel options required for Docker to function properly. This project addresses that by:

1. Fetching the latest WSL2 kernel configuration from Microsoft's repository
2. Applying patches to enable Docker compatibility options
3. Adding BBR congestion control for better network performance
4. Providing automated build workflows via GitHub Actions

## Prerequisites

### For Local Development

- Linux or macOS system
- `bash` shell
- `curl` or `wget` (for fetching configs)
- `sed` (usually pre-installed)
- Git

### For Building Kernels

- Build tools: `build-essential`, `flex`, `bison`, `dwarves`
- Libraries: `libssl-dev`, `libelf-dev`
- Utilities: `cpio`, `qemu-utils`
- Access to Microsoft's [WSL2-Linux-Kernel](https://github.com/microsoft/WSL2-Linux-Kernel) repository

## Usage

### Fetching WSL2 Kernel Config

Download the latest WSL2 kernel configuration from Microsoft's repository:

```bash
./scripts/fetch-wsl2-config.sh [output-filename]
```

**Example:**

```bash
./scripts/fetch-wsl2-config.sh config-wsl2.cfg
```

This will download the config to `config/config-wsl2.cfg` (default location).

### Patching Kernel Config

Apply Docker and BBR compatibility settings to a kernel configuration file:

```bash
./scripts/patch-wsl2-kernel-config.sh <config-file-path>
```

**Example:**

```bash
./scripts/patch-wsl2-kernel-config.sh config/config-wsl2.cfg
```

The script will:

- Create a backup of the original config file
- Remove existing conflicting configuration entries
- Add all required Docker and BBR options

### Building with GitHub Actions

1. Go to the **Actions** tab in your GitHub repository
2. Select the **Build** workflow
3. Click **Run workflow**
4. Configure the build parameters:
   - **kernelBranch**: WSL2-Linux-Kernel branch (default: `linux-msft-wsl-6.6.y`)
   - **build-modules**: Whether to build kernel modules (default: `false`)
   - **custom-config**: Use custom config from this repository (default: `false`)
5. Click **Run workflow**

The workflow will:

- Checkout the specified WSL2 kernel branch
- Optionally apply your custom configuration
- Build the kernel
- Optionally build kernel modules
- Upload the built kernel (`bzImage`) and modules (`modules.vhdx`) as artifacts

### Installing the Built Kernel

After downloading the artifacts from GitHub Actions:

1. Copy `bzImage` to your Windows host (e.g., `C:\Users\<YourUsername>\`)
2. Create or edit `.wslconfig` in your Windows user directory:

   ```ini
   [wsl2]
   kernel=C:\\Users\\<YourUsername>\\bzImage
   ```

3. Restart WSL2:

   ```powershell
   wsl --shutdown
   ```

## Configuration Details

### Docker Kernel Compatibility Options

The following kernel options are enabled for Docker compatibility:

```bash
# Bridge networking
CONFIG_BRIDGE=y
CONFIG_BRIDGE_NETFILTER=y

# Netfilter and iptables
CONFIG_NFT_COMPAT=y
CONFIG_NETFILTER_XT_NAT=y
CONFIG_NETFILTER_XT_TARGET_MASQUERADE=y
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y
CONFIG_NETFILTER_XT_MARK=y

# IP tables
CONFIG_IP_NF_IPTABLES=y
CONFIG_IP_NF_FILTER=y
CONFIG_IP_NF_NAT=y
CONFIG_IP_NF_TARGET_MASQUERADE=y
CONFIG_IP_NF_MANGLE=y

# IP Virtual Server
CONFIG_IP_VS=y
CONFIG_NETFILTER_XT_MATCH_IPVS=y
CONFIG_IP_VS_RR=y

# IPsec
CONFIG_XFRM_USER=y
CONFIG_XFRM_ALGO=y
CONFIG_INET_ESP=y

# Network classification
CONFIG_NET_CLS_CGROUP=y
CONFIG_IP_NF_TARGET_REDIRECT=y

# Virtual network interfaces
CONFIG_IPVLAN=y
CONFIG_MACVLAN=y
CONFIG_DUMMY=y

# FTP/TFTP NAT helpers
CONFIG_NF_NAT_FTP=y
CONFIG_NF_CONNTRACK_FTP=y
CONFIG_NF_NAT_TFTP=y
CONFIG_NF_CONNTRACK_TFTP=y

# Filesystem support
CONFIG_BTRFS_FS=y
```

### BBR (Bottleneck Bandwidth and RTT)

BBR is a TCP congestion control algorithm developed by Google that can significantly improve network throughput and latency:

```bash
CONFIG_TCP_CONG_BBR=y
CONFIG_NET_SCH_FQ_CODEL=y
CONFIG_NET_SCH_FQ=y
```

To enable BBR on your WSL2 instance, add the following to `/etc/sysctl.conf`:

```bash
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
```

Then apply the changes:

```bash
sudo sysctl -p
```

## Project Structure

```text
wsl2-kernel-build/
├── config/
│   ├── config-wsl2.cfg          # Base WSL2 kernel config
│   └── config-wsl2-docker.cfg   # Pre-patched config with Docker support
├── scripts/
│   ├── fetch-wsl2-config.sh     # Script to fetch latest WSL2 config
│   └── patch-wsl2-kernel-config.sh  # Script to patch config with Docker/BBR options
├── .github/
│   └── workflows/
│       └── build.yml            # GitHub Actions build workflow
└── README.md
```

## Troubleshooting

### Docker Issues

If Docker still doesn't work after using a patched kernel:

1. Verify the kernel options are present:

   ```bash
   zcat /proc/config.gz | grep CONFIG_BRIDGE
   ```

2. Check Docker's kernel compatibility requirements:
   - [Docker Kernel Compatibility Documentation](https://docs.docker.com/engine/daemon/troubleshoot/#kernel-compatibility)

### Build Issues

- Ensure all build dependencies are installed
- Check that you have sufficient disk space (kernel builds require several GB)
- Verify the kernel branch exists in Microsoft's repository

## References

- [Docker Engine Daemon Troubleshooting - Kernel Compatibility](https://docs.docker.com/engine/daemon/troubleshoot/#kernel-compatibility)
- [WSL2 Docker Issue Discussion](https://github.com/microsoft/WSL/issues/11742#issuecomment-2272557613)
- [Microsoft WSL2-Linux-Kernel Repository](https://github.com/microsoft/WSL2-Linux-Kernel)
- [BBR Congestion Control](https://github.com/google/bbr)
