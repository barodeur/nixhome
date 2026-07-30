{ config, lib, pkgs, ... }:

# Light/dark switching for the whole session, driven by one persisted mode.
#
# Two hand-written palettes live here and nowhere else. Everything that gets
# painted — waybar, wofi, mako, hyprlock, hyprland's borders — reads its colours
# through a *name* (`@accent`, `$activeBorder`) resolved from a file in
# ${stateDir}, and switching modes just repoints that file. The consumers' own
# configs never mention a colour, so a palette edit here is the only edit.
#
# The indirection has to go through a mutable path: home-manager writes every
# config as a read-only symlink into the store, so a stylesheet cannot be
# rewritten in place and nothing can be toggled by regenerating it. ~/.local/
# state/theme is ours to flip; the store files it points at are still declarative.

let
  stateDir = "${config.xdg.stateHome}/theme";

  palettes = {
    dark = {
      # The palette this config has always used: near-black translucent panels,
      # cyan accent, green as the second half of the selection gradient.
      css = {
        "bg" = "rgba(15, 15, 25, 0.85)";
        "bg-elevated" = "rgba(15, 15, 25, 0.95)";
        "bg-popup" = "rgba(15, 15, 25, 0.92)";
        "surface" = "rgba(255, 255, 255, 0.04)";
        "surface-hover" = "rgba(51, 204, 255, 0.08)";
        "border" = "rgba(51, 204, 255, 0.12)";
        "border-strong" = "rgba(51, 204, 255, 0.25)";
        "border-focus" = "rgba(51, 204, 255, 0.5)";
        "text" = "#c8d0e0";
        "text-strong" = "#e0e6f0";
        "text-muted" = "rgba(200, 208, 224, 0.35)";
        "text-dim" = "rgba(200, 208, 224, 0.3)";
        "accent" = "#33ccff";
        "accent-hover" = "rgba(51, 204, 255, 0.1)";
        "sel-from" = "rgba(51, 204, 255, 0.25)";
        "sel-to" = "rgba(0, 255, 153, 0.18)";
        "sel-border" = "rgba(51, 204, 255, 0.35)";
        "sel-text" = "#ffffff";
        "urgent-bg" = "rgba(255, 100, 120, 0.25)";
        "blue" = "#7aafff";
        "purple" = "#c4a1f0";
        "green" = "#8edba6";
        "yellow" = "#e0c880";
        "orange" = "#f0b070";
        "red" = "#ff6478";
      };
      hypr = {
        activeBorder = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        inactiveBorder = "rgba(595959aa)";
        lockOuter = "rgba(33ccffee)";
        lockInner = "rgba(0, 0, 0, 0.5)";
        lockFont = "rgb(200, 200, 200)";
      };
      mako = {
        border-color = "#33ccffee";
        background-color = "#1a1b26ee";
        text-color = "#c0caf5";
      };
    };

    light = {
      # The same shapes with the values inverted. The accents are darkened
      # rather than reused: #33ccff on white is roughly 1.9:1, unreadable as
      # text, so the cyan drops to #007aa8 and the green to #009e69. Alphas stay
      # where they are — they carry the depth cues, and copying them keeps the
      # two modes feeling like one design.
      css = {
        "bg" = "rgba(248, 249, 252, 0.85)";
        "bg-elevated" = "rgba(248, 249, 252, 0.97)";
        "bg-popup" = "rgba(248, 249, 252, 0.94)";
        "surface" = "rgba(20, 32, 56, 0.05)";
        "surface-hover" = "rgba(0, 122, 168, 0.10)";
        "border" = "rgba(0, 122, 168, 0.18)";
        "border-strong" = "rgba(0, 122, 168, 0.30)";
        "border-focus" = "rgba(0, 122, 168, 0.55)";
        "text" = "#3c4657";
        "text-strong" = "#1b2432";
        "text-muted" = "rgba(60, 70, 87, 0.45)";
        "text-dim" = "rgba(60, 70, 87, 0.40)";
        "accent" = "#007aa8";
        "accent-hover" = "rgba(0, 122, 168, 0.12)";
        "sel-from" = "rgba(0, 122, 168, 0.22)";
        "sel-to" = "rgba(0, 158, 105, 0.16)";
        "sel-border" = "rgba(0, 122, 168, 0.35)";
        # White-on-a-pale-tint is invisible; the selected row goes dark instead.
        "sel-text" = "#10202c";
        "urgent-bg" = "rgba(214, 45, 75, 0.18)";
        "blue" = "#2f66c8";
        "purple" = "#7a45b8";
        "green" = "#147a4e";
        "yellow" = "#8a6a10";
        "orange" = "#b85c10";
        "red" = "#cc2f4a";
      };
      hypr = {
        activeBorder = "rgba(007aa8ee) rgba(009e69ee) 45deg";
        inactiveBorder = "rgba(c2c8d2aa)";
        lockOuter = "rgba(007aa8ee)";
        lockInner = "rgba(255, 255, 255, 0.6)";
        lockFont = "rgb(40, 48, 64)";
      };
      mako = {
        border-color = "#007aa8ee";
        background-color = "#f8f9fcf2";
        text-color = "#3c4657";
      };
    };
  };

  render = sep: f: attrs: lib.concatStringsSep "\n" (lib.mapAttrsToList f attrs) + sep;

  # One stylesheet for waybar and wofi both — they are the same GTK CSS engine
  # and the same names.
  paletteFiles = lib.mapAttrs
    (mode: p: {
      css = pkgs.writeText "palette-${mode}.css"
        (render "\n" (k: v: "@define-color ${k} ${v};") p.css);
      hypr = pkgs.writeText "palette-${mode}.conf"
        (render "\n" (k: v: "\$${k} = ${v}") p.hypr);
      mako = pkgs.writeText "palette-${mode}-mako.conf"
        (render "\n" (k: v: "${k}=${v}") p.mako);
    })
    palettes;

  linkArms = lib.concatStringsSep "\n    " (lib.mapAttrsToList
    (mode: f: lib.concatStringsSep "\n    " [
      "${mode})"
      "  ln -sfn ${f.css} \"$state/palette.css\""
      "  ln -sfn ${f.hypr} \"$state/hypr.conf\""
      "  ln -sfn ${f.mako} \"$state/mako.conf\""
      "  ;;"
    ])
    paletteFiles);

  # writeShellApplication rather than writeShellScriptBin: this runs from a
  # systemd user unit as well as from waybar, and a user unit inherits no usable
  # PATH — the first version died on `mkdir: command not found`. runtimeInputs
  # pins every binary the script reaches for, whatever the caller's environment.
  theme-mode = pkgs.writeShellApplication {
    name = "theme-mode";
    runtimeInputs = with pkgs; [ coreutils dconf mako systemd hyprland ];
    text = ''
      state="${stateDir}"
      mode_file="$state/mode"

      current() {
        m=$(cat "$mode_file" 2>/dev/null || true)
        case "$m" in
          light | dark) printf '%s' "$m" ;;
          *) printf 'light' ;;
        esac
      }

      link() {
        mkdir -p "$state"
        case "$1" in
          ${linkArms}
        esac
        printf '%s\n' "$1" > "$mode_file"
      }

      # dconf writes travel over the session bus, which does not exist during
      # home-manager activation (it runs from a system service). Skipping there
      # is fine: theme-apply.service repeats this once the session is up.
      signal() {
        [ -n "''${DBUS_SESSION_BUS_ADDRESS-}" ] || return 0
        case "$1" in
          light) scheme=prefer-light gtk=Adwaita ;;
          dark) scheme=prefer-dark gtk=Adwaita-dark ;;
        esac
        # color-scheme is what libadwaita, GTK4 and every flatpak read through
        # the settings portal. gtk-theme is the GTK3 half: those apps have no
        # notion of a colour scheme and switch only by theme name.
        #
        # dconf rather than gsettings: gsettings resolves the key against its
        # schema and dies with "No schemas installed" under a systemd user unit,
        # which gets a stripped XDG_DATA_DIRS. dconf writes the same keys to the
        # same database with no schema lookup, so it works in both environments.
        dconf write /org/gnome/desktop/interface/color-scheme "'$scheme'"
        dconf write /org/gnome/desktop/interface/gtk-theme "'$gtk'"
      }

      # GTK parses @import once, so waybar has to be told to re-read its
      # stylesheet. SIGUSR2 is an in-process reload — it drops out of the GTK
      # main loop and rebuilds the bars, re-running the CSS load — so the bar
      # never blinks out and systemd never sees the unit exit. Its own file
      # watcher (reload_style_on_change) is no use here: it resolves symlinks
      # before watching, so it would monitor the immutable store path and never
      # fire. mako and hyprland re-read their sourced files on demand. Anything
      # already running that missed the signal (a GTK3 window, say) picks the
      # new colours up on its next launch.
      reload() {
        systemctl --user kill --signal=SIGUSR2 waybar.service || true
        makoctl reload || true
        hyprctl reload || true
      }

      case "''${1-apply}" in
        get)
          current
          printf '\n'
          ;;
        apply)
          link "$(current)"
          signal "$(current)"
          ;;
        light | dark)
          link "$1"
          signal "$1"
          reload
          ;;
        toggle)
          if [ "$(current)" = dark ]; then next=light; else next=dark; fi
          link "$next"
          signal "$next"
          reload
          ;;
        *)
          echo "usage: theme-mode [get|apply|toggle|light|dark]" >&2
          exit 1
          ;;
      esac
    '';
  };
in
{
  home.packages = [ theme-mode ];

  # The palette symlinks have to exist before anything that imports them starts,
  # and a rebuild may swap the store paths they point at. Deliberately not
  # declaring color-scheme in dconf.settings: home-manager reasserts those on
  # every rebuild, which would drag the apps back to the declared default while
  # the chrome stayed where the toggle left it.
  home.activation.themeMode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${theme-mode}/bin/theme-mode apply
  '';

  # Activation had no session bus, so the dconf half of the mode is applied here
  # instead — once per login, before anything reads it.
  systemd.user.services.theme-apply = {
    Unit = {
      Description = "Apply the persisted light/dark mode";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      # Its effect outlives the process, so let the unit say so: without this a
      # finished oneshot reads "inactive (dead)", indistinguishable at a glance
      # from one that never ran.
      RemainAfterExit = true;
      ExecStart = "${theme-mode}/bin/theme-mode apply";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # Without this GTK3 apps read ~/.config/gtk-3.0/settings.ini — a read-only
  # store symlink — and never see the gtk-theme the toggle writes. With it they
  # take their settings from xdg-desktop-portal-gtk, which serves the live dconf
  # values, so they follow the mode like the GTK4 and flatpak apps already do.
  home.sessionVariables.GTK_USE_PORTAL = "1";
}
