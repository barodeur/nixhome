# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Nix flake-based multi-machine dotfiles/system configuration repo managing both macOS (nix-darwin) and Linux (home-manager standalone) hosts.

## Commands

**macOS (nix-darwin) hosts** (jamie, lois, piama):
```
darwin-rebuild switch --flake .
```

**Linux (home-manager standalone) hosts** (otto):
```
home-manager switch --flake .#paul@otto
```

**Format Nix files:**
```
nixpkgs-fmt <file.nix>
```

## Architecture

The flake defines two types of configurations:
- `darwinConfigurations` — macOS hosts using nix-darwin + home-manager as a darwin module
- `homeConfigurations` — standalone home-manager for NixOS/Linux hosts

### Directory structure

- `hosts/<name>/` — Per-machine entry point. Each imports the profiles and user config it needs. Darwin hosts (jamie, lois, piama) import `profiles/base`, `profiles/common`, `profiles/home-manager`, and `users/paul/darwin.nix`. The Linux host (otto) directly imports individual home-manager profile modules.
- `profiles/base/` — Darwin-only system-level config (nix-daemon, fenix overlay).
- `profiles/common/` — Darwin-only shared system config (system packages, nixpkgs settings, gnupg/zsh system programs). `packages.nix` defines the shared package list including Rust toolchain via fenix.
- `profiles/home-manager/` — Home-manager module fragments, each in its own subdirectory (git, zsh, vim, gpg, tmux, direnv, environment, hyprland, waybar). Some have platform-specific variants (e.g., `gpg/linux.nix`, `zsh/linux.nix`).
- `users/paul/` — User definition. `common.nix` sets up the user and imports home-manager profiles. `darwin.nix` extends it with macOS-specific settings.

### Key patterns

- Darwin hosts compose via: host → profiles/{base,common,home-manager} → users/paul/darwin.nix → users/paul/common.nix (which imports home-manager profile modules).
- The Linux host (otto) is a standalone home-manager config that directly imports the profile modules it needs, bypassing base/common/home-manager profiles (those are darwin-specific).
- The fenix overlay provides the Rust toolchain and is applied differently per platform: via `profiles/base` for darwin, via `nixpkgs` overlay in flake.nix for otto.

## Git Commits

Do not include a Co-Authored-By line in commit messages.
