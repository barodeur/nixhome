{ pkgs, ... }:

{
  users = {
    users.paul = {
      description = "Paul Chobert";
      shell = pkgs.zsh;
    };
  };

  home-manager.users.paul = { ... }: {
    imports = [
      ../../profiles/home-manager/direnv
      ../../profiles/home-manager/git
      ../../profiles/home-manager/git/paul.nix
      ../../profiles/home-manager/gpg
      ../../profiles/home-manager/vim
      ../../profiles/home-manager/zsh
    ];
  };
}
