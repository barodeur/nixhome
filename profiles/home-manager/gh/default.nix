{ pkgs, ... }:

{
  # Just the binary, not programs.gh: that makes ~/.config/gh/config.yml a
  # read-only store symlink, and gh rewrites config.yml whenever it saves
  # account data (auth login/refresh/switch), failing with permission
  # denied. The SSH git protocol picked at `gh auth login` is kept
  # per-host in hosts.yml, which gh owns.
  home.packages = [ pkgs.gh ];
}
