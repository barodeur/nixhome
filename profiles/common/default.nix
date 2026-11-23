{ pkgs, ... }:

{
  environment = { systemPackages = import ./packages.nix { inherit pkgs; }; };

  fonts.packages = with pkgs; [
    # Nerd Font glyphs for tmux's tokyo-night theme, starship, neovim.
    nerd-fonts.jetbrains-mono
    # tokyo-night-tmux's default 7-segment window numbers (🯰🯱🯲) live in
    # Symbols for Legacy Computing, which only this Noto font covers.
    # Just that one variant, not the whole multi-GB Noto collection.
    (noto-fonts.override { variants = [ "NotoSansSymbols2" ]; })
  ];

  nixpkgs.config = {
    allowBroken = true;
    allowUnsupportedSystem = true;
    allowUnfree = true;
  };

  programs = {
    gnupg = {
      agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };
    zsh.enable = true;
  };
}
