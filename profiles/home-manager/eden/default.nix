{ pkgs, ... }:

let
  pname = "eden";
  version = "0.2.1";

  # Eden (Switch emulator, yuzu lineage) is distributed only as an AppImage
  # from its self-hosted forge — it is in neither nixpkgs nor Flathub, and
  # given Nintendo's takedown campaign it is unlikely to land in either.
  # Bump version + hash together when a new release appears:
  # https://git.eden-emu.dev/eden-emu/eden/releases
  src = pkgs.fetchurl {
    url = "https://git.eden-emu.dev/eden-emu/eden/releases/download/v${version}/Eden-Linux-v${version}-amd64-clang-pgo.AppImage";
    hash = "sha256-eii/mIsGSIMZiXIr26qQqzE3G0A4CBmYE+DqfIslum0=";
  };

  # Not appimageTools: this is a DwarFS-compressed "anylinux" AppImage, and
  # appimageTools extracts with unsquashfs, which fails on it. Its static
  # uruntime can extract itself, and the sharun-based payload bundles its own
  # loader and libraries, so the tree runs on NixOS with no FHS wrapping.
  unwrapped = pkgs.stdenv.mkDerivation {
    pname = "${pname}-unwrapped";
    inherit version src;

    dontUnpack = true;
    dontBuild = true;
    dontFixup = true; # sharun's bundled loader/libs must not be patchelf'd

    installPhase = ''
      cp $src eden.AppImage
      chmod +x eden.AppImage
      ./eden.AppImage --appimage-extract

      # squashfs-root may be a symlink to the real extraction dir (AppDir),
      # so copy its contents rather than the name itself.
      mkdir -p $out
      cp -r squashfs-root/. $out
    '';
  };

  # Flatpak-grade sandbox, hand-rolled with bwrap since there is no Eden
  # flatpak: the emulator runs untrusted dumped binaries, so it gets to see
  # its own state, ~/Games, and the display/GPU/audio plumbing — not $HOME
  # (no ~/.ssh, ~/.gnupg, browser profiles). No D-Bus either, so file dialogs
  # are Qt-native and only show the dirs bound below; game dumps therefore
  # belong in ~/Games, which Lutris already shares.
  eden = pkgs.writeShellScriptBin "eden" ''
    mkdir -p "$HOME/.local/share/eden" "$HOME/.config/eden" \
      "$HOME/.cache/eden" "$HOME/Games"

    exec ${pkgs.bubblewrap}/bin/bwrap \
      --unshare-all --share-net \
      --die-with-parent \
      --proc /proc \
      --dev /dev \
      --dev-bind-try /dev/dri /dev/dri \
      --dev-bind-try /dev/input /dev/input \
      --ro-bind-try /run/udev /run/udev \
      --ro-bind /sys /sys \
      --ro-bind /nix/store /nix/store \
      --ro-bind-try /run/opengl-driver /run/opengl-driver \
      --ro-bind /bin /bin \
      --ro-bind /usr/bin /usr/bin \
      --ro-bind-try /etc/static /etc/static \
      --ro-bind-try /etc/fonts /etc/fonts \
      --ro-bind-try /etc/resolv.conf /etc/resolv.conf \
      --ro-bind-try /etc/hosts /etc/hosts \
      --ro-bind-try /etc/nsswitch.conf /etc/nsswitch.conf \
      --ro-bind-try /etc/ssl /etc/ssl \
      --ro-bind-try /etc/machine-id /etc/machine-id \
      --ro-bind-try /etc/localtime /etc/localtime \
      --tmpfs /tmp \
      --ro-bind-try /tmp/.X11-unix /tmp/.X11-unix \
      --dir "$XDG_RUNTIME_DIR" \
      --ro-bind-try "$XDG_RUNTIME_DIR/''${WAYLAND_DISPLAY:-wayland-0}" \
        "$XDG_RUNTIME_DIR/''${WAYLAND_DISPLAY:-wayland-0}" \
      --ro-bind-try "$XDG_RUNTIME_DIR/pipewire-0" "$XDG_RUNTIME_DIR/pipewire-0" \
      --ro-bind-try "$XDG_RUNTIME_DIR/pulse" "$XDG_RUNTIME_DIR/pulse" \
      --bind "$HOME/.local/share/eden" "$HOME/.local/share/eden" \
      --bind "$HOME/.config/eden" "$HOME/.config/eden" \
      --bind "$HOME/.cache/eden" "$HOME/.cache/eden" \
      --bind "$HOME/Games" "$HOME/Games" \
      ${unwrapped}/AppRun "$@"
  '';
in
{
  # Keys, firmware and game dumps are stateful and live outside nix, in
  # ~/.local/share/eden (keys/ and nand/system/Contents/registered/).
  home.packages = [ eden ];

  xdg.desktopEntries.eden = {
    name = "Eden";
    exec = "eden %f";
    icon = "dev.eden_emu.eden";
    comment = "Nintendo Switch emulator";
    categories = [ "Game" "Emulator" ];
  };

  home.file.".local/share/icons/hicolor/scalable/apps/dev.eden_emu.eden.svg".source =
    "${unwrapped}/dev.eden_emu.eden.svg";
}
