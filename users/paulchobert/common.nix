{ pkgs, ... }:

{
  users = {
    users.paulchobert = {
      description = "Paul Chobert";
      shell = pkgs.zsh;
    };
  };

  home-manager.users.paulchobert = { ... }: {
    imports = [
      ../../profiles/home-manager/direnv
      ../../profiles/home-manager/environment
      ../../profiles/home-manager/git
      ../../profiles/home-manager/git/paul.nix
      # ../../profiles/home-manager/gpg
      ../../profiles/home-manager/vim
      ../../profiles/home-manager/zsh
      ../../profiles/home-manager/tmux
      ../../profiles/home-manager/mise
      ../../profiles/home-manager/vscode
    ];
  };
}
