# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Nix flake-based multi-machine dotfiles/system configuration repo managing both macOS (nix-darwin) and Linux (home-manager standalone) hosts.

## Commands

**macOS (nix-darwin) hosts** (jamie, lois, piama):
```
darwin-rebuild switch --flake .
```

**Linux host (otto)** — home-manager runs as a NixOS module, so one rebuild
applies system (`hosts/otto/system/`) and home (`hosts/otto/default.nix`)
together (`otto-rebuild` is a wrapper for this):
```
sudo nixos-rebuild switch --flake .#otto
```
Do not use plain `nixos-rebuild switch` on otto — it builds from the channel and
would undo the flake-managed system config.

**Format Nix files:**
```
nixpkgs-fmt <file.nix>
```

## Architecture

The flake defines three types of configurations:
- `darwinConfigurations` — macOS hosts using nix-darwin + home-manager as a darwin module
- `nixosConfigurations` — otto's system + home, built entirely from `nixpkgs-stable` (pinned to the stable release) with `home-manager-stable` as a NixOS module, rather than the unstable `nixpkgs` the rest of the flake uses
- `homeConfigurations` — standalone home-manager for non-NixOS Linux hosts (devcontainers)

### Directory structure

- `hosts/<name>/` — Per-machine entry point. Each imports the profiles and user config it needs. Darwin hosts (jamie, lois, piama) import `profiles/base`, `profiles/common`, `profiles/home-manager`, and `users/paul/darwin.nix`. The Linux host (otto) directly imports individual home-manager profile modules.
- `profiles/base/` — Darwin-only system-level config (nix-daemon, fenix overlay).
- `profiles/common/` — Darwin-only shared system config (system packages, nixpkgs settings, gnupg/zsh system programs). `packages.nix` defines the shared package list including Rust toolchain via fenix.
- `profiles/home-manager/` — Home-manager module fragments, each in its own subdirectory (git, zsh, vim, gpg, tmux, direnv, environment, hyprland, waybar). Some have platform-specific variants (e.g., `gpg/linux.nix`, `zsh/linux.nix`).
- `users/paul/` — User definition. `common.nix` sets up the user and imports home-manager profiles. `darwin.nix` extends it with macOS-specific settings.

### Key patterns

- Darwin hosts compose via: host → profiles/{base,common,home-manager} → users/paul/darwin.nix → users/paul/common.nix (which imports home-manager profile modules).
- The Linux host (otto) wires `hosts/otto` (the home config, which directly imports the profile modules it needs, bypassing the darwin-specific base/common/home-manager profiles) into its system config via the home-manager NixOS module in flake.nix. `hosts/otto/system/` holds the system half.
- The fenix overlay provides the Rust toolchain on darwin via `profiles/base`; otto does not use it.

## Git Commits

Do not include a Co-Authored-By line in commit messages.
