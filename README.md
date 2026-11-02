![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/dariogriffo/zapfast-debian/total)
![GitHub Downloads (all assets, latest release)](https://img.shields.io/github/downloads/dariogriffo/zapfast-debian/latest/total)
![GitHub Release](https://img.shields.io/github/v/release/dariogriffo/zapfast-debian)
![GitHub Release Date](https://img.shields.io/github/release-date/dariogriffo/zapfast-debian)

<h1>
   <p align="center">
     <a href="https://zapfast.rocks"><img src="https://github.com/dariogriffo/zapfast-debian/blob/main/zapfast-logo.svg" alt="ZapFast Logo" width="128" style="margin-right: 20px"></a>
     <a href="https://www.debian.org/"><img src="https://github.com/dariogriffo/zapfast-debian/blob/main/debian-logo.png" alt="Debian Logo" width="104" style="margin-left: 20px"></a>
     <br>ZapFast for Debian
   </p>
</h1>
<p align="center">
 WhatsApp, native and fast: a lightweight WhatsApp desktop client written in Rust.
</p>

# ZapFast for Debian

This repository contains build scripts to produce the _unofficial_ Debian and
Ubuntu packages (.deb) for [ZapFast](https://github.com/crmne/zapfast/) hosted at
[deb.griffo.io](https://deb.griffo.io)

The package and the command are both called `zapfast`. It is a desktop (egui)
application: launch it from the application menu, or run `zapfast`.
ZapFast is an unofficial WhatsApp client, not affiliated with WhatsApp or Meta.

Currently supported distros are:
- Debian Bookworm (v12), Trixie (v13), Forky (v14), Sid
- Ubuntu Noble (24.04), Questing (25.10), Resolute (26.04)

Supported architectures:
- amd64 (x86_64) - All distributions above
- arm64 (aarch64) - All distributions above

Ubuntu Jammy (22.04) is not supported: ZapFast needs PipeWire 0.3.50 or later
(`pw_stream_get_time_n`) and Jammy ships 0.3.48, so the package declares
`libpipewire-0.3-0 (>= 0.3.50)` and the mirror does not publish it for Jammy.
Upstream only publishes Linux builds for these two architectures, so there are
no i386, armhf, armel or riscv64 packages.

One package per architecture is built and shared by every suite
(`zapfast_<version>-<build>~griffo_<arch>.deb`). It repackages upstream's own
Linux build: the `zapfast` binary, the desktop entry, the icon and the Omarchy
theme hook in `/usr/share/zapfast/omarchy`. The dependencies are declared so
they resolve on every supported suite (including the t64 library renames),
with `xdg-utils` for opening links and `zenity` recommended as the file-dialog
fallback when no desktop portal runs.

The message archive is encrypted with a key kept in the session's Secret
Service keyring (GNOME Keyring, KWallet or KeePassXC). Every mainstream desktop
runs one; on a bare window manager install `gnome-keyring` (suggested).

Updates come through apt. ZapFast's built-in updater only acts on upstream's
portable download (it refuses dpkg-owned files and needs a
`zapfast-portable.txt` marker that this package does not ship), so it stays off.

This is an unofficial community project to provide a package that's easy to
install on Debian. If you're looking for the ZapFast source code, see
[ZapFast](https://github.com/crmne/zapfast/).

## Install/Update

📖 **Step-by-step install guide:** [Debian](https://deb.griffo.io/install-latest-zapfast-in-debian.html) · [Ubuntu](https://deb.griffo.io/install-latest-zapfast-in-ubuntu.html)

### The Debian way

> ⚠️ **apt access requires a yearly subscription**
> ([deb.griffo.io](https://deb.griffo.io)). To use this tool for free, download
> the .deb from the [Releases](https://github.com/dariogriffo/zapfast-debian/releases) page
> and install it manually (see below).

```sh
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://deb.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc | sudo gpg --dearmor --yes -o /etc/apt/keyrings/deb.griffo.io.gpg
echo "deb [signed-by=/etc/apt/keyrings/deb.griffo.io.gpg] https://deb.griffo.io/apt $(lsb_release -sc 2>/dev/null) main" | sudo tee /etc/apt/sources.list.d/deb.griffo.io.list
sudo apt update
sudo apt install -y zapfast
```

### Manual Installation

1. Download the .deb package for your architecture from
   the [Releases](https://github.com/dariogriffo/zapfast-debian/releases) page.
2. Install it with apt, so the dependencies are pulled in.

```sh
sudo apt install ./<filename>.deb
```
## Updating

To update to a new version, just follow any of the installation methods above. There's no need to uninstall the old version; it will be updated correctly.

## Building

### Build for single architecture
```sh
./build.sh <zapfast_version> <build_version> <architecture>
# Example: ./build.sh 0.21.0 1 arm64
```

### Build for all architectures
```sh
./build.sh <zapfast_version> <build_version> all
# Example: ./build.sh 0.21.0 1 all
```

## Roadmap

- [x] Produce a .deb package on GitHub Releases
- [x] Set up a debian mirror for easier updates
- [x] Multi-architecture support (amd64, arm64)

## Disclaimer

- This repo is not open for issues related to ZapFast. This repo is only for _unofficial_ Debian packaging.
