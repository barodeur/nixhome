{ config, lib, pkgs, inputs, ... }:

# Theme switching for the whole session, driven by one persisted theme name.
#
# The palettes are Omarchy's, read straight out of the pinned `omarchy` flake
# input as data — see ./colors.nix for what a colors.toml holds and how its 24
# semantic keys become the role names below. Nothing of Omarchy itself is used
# or needed: it is an Arch distribution whose desktop is now a single Quickshell
# process, and none of that ports. Its palettes do.
#
# Everything that gets painted — waybar, wofi, mako, hyprlock, hyprland's
# borders, ghostty, btop, neovim — reads its colours through a *name*
# (`@accent`, `$activeBorder`) resolved from a file in ${stateDir}, and
# switching themes just repoints those files. The consumers' own configs never
# mention a colour, which is why adding 22 themes changed none of them.
#
# The indirection has to go through a mutable path: home-manager writes every
# config as a read-only symlink into the store, so a stylesheet cannot be
# rewritten in place and nothing can be toggled by regenerating it. ~/.local/
# state/theme is ours to flip; the store files it points at are still
# declarative.

let
  stateDir = "${config.xdg.stateHome}/theme";

  colors = import ./colors.nix { inherit lib; omarchy = inputs.omarchy; };
  backgrounds = import ./backgrounds.nix { inherit lib pkgs; omarchy = inputs.omarchy; };
  backgroundImages = backgrounds.images colors.names;

  # The theme each mode starts on, and what `theme-mode light|dark` falls back
  # to before either side has been picked once. Change these to move the
  # defaults; everything else is runtime state.
  defaultDark = "tokyo-night";
  defaultLight = "catppuccin-latte";

  # One store directory per theme, each holding the same file names, so the
  # switcher is a loop over names rather than a case arm per theme.
  themesDir = pkgs.linkFarm "omarchy-palettes" (lib.concatLists (lib.mapAttrsToList
    (theme: files:
      # The wallpaper joins the generated text files under the same per-theme
      # name, so switching it is the same symlink flip as switching a palette.
      [{
        name = "${theme}/background.jpg";
        path = "${backgroundImages}/${theme}/background.jpg";
      }]
      ++ lib.mapAttrsToList
        (file: text: {
          name = "${theme}/${file}";
          path = pkgs.writeText "${theme}-${file}" (if file == "mode" then "${text}\n" else text);
        })
        files)
    colors.files));

  # writeShellApplication rather than writeShellScriptBin: this runs from a
  # systemd user unit as well as from waybar, and a user unit inherits no usable
  # PATH — the first version died on `mkdir: command not found`. runtimeInputs
  # pins every binary the script reaches for, whatever the caller's environment.
  theme-mode = pkgs.writeShellApplication {
    name = "theme-mode";
    runtimeInputs = with pkgs; [ coreutils dconf mako systemd hyprland procps wofi ];
    text = ''
      state="${stateDir}"
      themes="${themesDir}"

      # Every file the consumers resolve through ${stateDir}. Adding a
      # generated file means adding it here and in colors.nix, nowhere else.
      linked="palette.css hypr.conf mako.conf ghostty.conf btop.theme nvim.lua background.jpg"

      list() {
        for d in "$themes"/*/; do basename "$d"; done
      }

      current() {
        t=$(cat "$state/theme" 2>/dev/null || true)
        if [ -n "$t" ] && [ -d "$themes/$t" ]; then printf '%s' "$t"
        else printf '%s' "${defaultDark}"; fi
      }

      mode_of() {
        cat "$themes/$1/mode"
      }

      # Which theme a mode goes back to. Each side remembers the last theme
      # picked in it, so the light/dark toggle keeps working across 22 themes
      # instead of two: switch to kanagawa, toggle to light, toggle back, and
      # kanagawa is what returns.
      remembered() {
        t=$(cat "$state/last.$1" 2>/dev/null || true)
        if [ -n "$t" ] && [ -d "$themes/$t" ]; then printf '%s' "$t"
        elif [ "$1" = light ]; then printf '%s' "${defaultLight}"
        else printf '%s' "${defaultDark}"; fi
      }

      link() {
        mkdir -p "$state"
        for f in $linked; do
          ln -sfn "$themes/$1/$f" "$state/$f"
        done
        printf '%s\n' "$1" > "$state/theme"
        printf '%s\n' "$1" > "$state/last.$(mode_of "$1")"
      }

      # dconf writes travel over the session bus, which does not exist during
      # home-manager activation (it runs from a system service). Skipping there
      # is fine: theme-apply.service repeats this once the session is up.
      signal() {
        [ -n "''${DBUS_SESSION_BUS_ADDRESS-}" ] || return 0
        case "$(mode_of "$1")" in
          light) scheme=prefer-light; gtk=Adwaita ;;
          *) scheme=prefer-dark; gtk=Adwaita-dark ;;
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
      # fire. mako and hyprland re-read their sourced files on demand.
      #
      # ghostty has re-read its config on SIGUSR2 since 1.2, and that is the
      # only signal it handles — anything else kills it — so the pattern is
      # anchored rather than a plain `pkill ghostty`. The unrelated
      # "ghostty-server" an AppImage on this host runs would otherwise be
      # matched and killed. Not `-x`: NixOS's wrapper makes the process name
      # ".ghostty-wrapped", truncated to 15 characters in /proc, while the
      # command line still reads as ghostty plus its arguments.
      #
      # btop reads its theme once at startup and has no reload, and neovim
      # applies the new colorscheme on its next launch; both are left to pick
      # the change up when they next run.
      reload() {
        systemctl --user kill --signal=SIGUSR2 waybar.service || true
        makoctl reload || true
        hyprctl reload || true
        pkill -USR2 -f '^([^ ]*/)?\.?ghostty(-wrapped)?( |$)' || true

        # hyprpaper 0.8 replaced the text IPC that `hyprctl hyprpaper` speaks
        # with a Hyprwire binary socket, and ships no client for it, so there
        # is no way to hand it a new path at runtime. Restarting the unit is
        # what is left; it re-reads its config, which names the symlink above.
        systemctl --user restart hyprpaper.service || true
      }

      apply() {
        link "$1"
        signal "$1"
      }

      usage() {
        echo "usage: theme-mode [get|mode|list|menu|apply|toggle|light|dark|set <theme>]" >&2
        exit 1
      }

      case "''${1-apply}" in
        get)
          current
          printf '\n'
          ;;
        mode)
          mode_of "$(current)"
          ;;
        list)
          list
          ;;
        apply)
          apply "$(current)"
          ;;
        set)
          name="''${2-}"
          if [ -z "$name" ] || [ ! -d "$themes/$name" ]; then
            printf "theme-mode: unknown theme '%s'. Known themes:\n" "$name" >&2
            list >&2
            exit 1
          fi
          apply "$name"
          reload
          ;;
        menu)
          chosen=$(list | wofi --dmenu --insensitive --prompt 'Theme')
          [ -n "$chosen" ] || exit 0
          apply "$chosen"
          reload
          ;;
        light | dark)
          apply "$(remembered "$1")"
          reload
          ;;
        toggle)
          if [ "$(mode_of "$(current)")" = dark ]; then next=light; else next=dark; fi
          apply "$(remembered "$next")"
          reload
          ;;
        *)
          usage
          ;;
      esac
    '';
  };
in
{
  home.packages = [ theme-mode ];

  # btop only loads themes it discovered in its own theme directories, so the
  # indirection cannot be a bare path in btop.conf: it has to be a .theme file
  # sitting in ~/.config/btop/themes. mkOutOfStoreSymlink because the target is
  # the mutable state path, not a store path.
  xdg.configFile."btop/themes/current.theme".source =
    config.lib.file.mkOutOfStoreSymlink "${stateDir}/btop.theme";

  # The palette symlinks have to exist before anything that imports them starts,
  # and a rebuild may swap the store paths they point at. Deliberately not
  # declaring color-scheme in dconf.settings: home-manager reasserts those on
  # every rebuild, which would drag the apps back to the declared default while
  # the chrome stayed where the switcher left it.
  home.activation.themeMode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${theme-mode}/bin/theme-mode apply
  '';

  # Activation had no session bus, so the dconf half of the theme is applied
  # here instead — once per login, before anything reads it.
  systemd.user.services.theme-apply = {
    Unit = {
      Description = "Apply the persisted theme";
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
  # store symlink — and never see the gtk-theme the switcher writes. With it
  # they take their settings from xdg-desktop-portal-gtk, which serves the live
  # dconf values, so they follow the theme like the GTK4 and flatpak apps do.
  home.sessionVariables.GTK_USE_PORTAL = "1";
}
