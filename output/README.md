<div align="center">

# ZapFast

**WhatsApp, native and fast. A lightweight WhatsApp client for the desktop.**

![GitHub Release](https://img.shields.io/github/v/release/crmne/zapfast?display_name=tag&color=%23a6a)
![GitHub License](https://img.shields.io/github/license/crmne/zapfast)

</div>

## About

ZapFast is a native WhatsApp desktop client written in Rust with egui. It
links to the WhatsApp account on your phone by QR code, like WhatsApp Web,
opens in under a second and uses a fraction of the memory of a browser tab.
It covers chats, media, voice and video calls, polls, notifications, a tray
icon, keyboard shortcuts and themes.

ZapFast is an unofficial client and is not affiliated with WhatsApp or Meta.

**The command is `zapfast`.** Launch it from your desktop's application menu
or run `zapfast` from a terminal. It runs on X11 and Wayland.

The message archive on disk is encrypted with a key kept in your session's
Secret Service keyring (GNOME Keyring, KWallet or KeePassXC). Every mainstream
desktop runs one; on a bare window manager, install `gnome-keyring`. File
dialogs go through the desktop portal, with `zenity` (recommended) as the
fallback.

Updates come through apt: ZapFast's built-in updater only acts on upstream's
portable download and stays off for this package.

**[Read the documentation](https://zapfast.rocks/)**
