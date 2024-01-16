{ pkgs }:

with pkgs; [
  colima
  curl
  git
  git-lfs
  gnupg
  hcloud
  htop
  iterm2
  jq
  kubectl
  lima
  mosh
  nixpkgs-fmt
  packer
  pinentry_mac
  pkg-config
  ripgrep
  tmux
  utm
  youtube-dl
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

  (fenix.combine [
    fenix.latest.rustfmt

    fenix.stable.llvm-tools-preview
    fenix.stable.clippy
    fenix.stable.cargo
    fenix.stable.rust-src
    fenix.stable.rust-std
    fenix.stable.rustc
    fenix.targets.wasm32-unknown-unknown.stable.rust-std
    fenix.targets.x86_64-unknown-linux-musl.stable.rust-std
    fenix.targets.aarch64-unknown-linux-musl.stable.rust-std
    fenix.targets.x86_64-unknown-linux-gnu.stable.rust-std
    fenix.targets.aarch64-unknown-linux-gnu.stable.rust-std
    fenix.targets.x86_64-apple-darwin.stable.rust-std
    fenix.targets.aarch64-apple-darwin.stable.rust-std
  ])
]

