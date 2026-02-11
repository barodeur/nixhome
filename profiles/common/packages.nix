{ pkgs }:

with pkgs; [
  colima
  git
  git-lfs
  hcloud
  htop
  iterm2
  jq
  kubectl
  lima
  mosh
  nixpkgs-fmt
  packer
  # pinentry_mac
  pkg-config
  ripgrep
  tmux
  utm
  yt-dlp
  yubikey-manager
  yubikey-personalization

  # ocaml
  opam

  # k8s
  helmfile
  (pkgs.wrapHelm pkgs.kubernetes-helm {
    plugins = [
      pkgs.kubernetes-helmPlugins.helm-secrets
      pkgs.kubernetes-helmPlugins.helm-git
    ];
  })
  kustomize
]
