{ config, pkgs, ... }:

let
  stateDir = "${config.xdg.stateHome}/theme";
in
{
  programs.waybar = {
    enable = true;
    # Run as a user service under graphical-session.target (UWSM activates it)
    # rather than exec-once: restarts on crash, and home-manager switch
    # restarts it so config changes apply without relogging.
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        # Omarchy's bar is a strip flush against the screen edge, not a
        # floating island: no margins, no rounding, no border, and 26px at a
        # 12px font rather than 38. The gap between bar and windows is
        # Hyprland's gaps_out alone.
        height = 26;
        spacing = 0;

        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "custom/theme" "backlight" "pulseaudio" "network" "bluetooth" "custom/power-profile" "battery" "tray" ];

        # A filled square for the focused workspace, plain numbers for the
        # rest. waybar resolves a workspace icon urgent -> active -> special ->
        # by-name -> visible -> empty -> persistent -> default, and returns the
        # workspace's own name when none of those matched. Mapping *only*
        # "active" therefore leaves every other workspace falling through to
        # its number, which is the whole effect — occupancy is carried by
        # colour instead (the .empty class below), not by a second glyph.
        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons.active = "󰝤";
          on-click = "activate";
          sort-by-number = true;
          # 1-5 always present, so the row does not reflow as workspaces come
          # and go. Without this, only workspaces holding a window exist.
          persistent-workspaces."*" = 5;
        };

        clock = {
          format = "{:%A %H:%M}";
          format-alt = "{:%A, %B %d}";
          tooltip-format = "<tt>{calendar}</tt>";
        };

        # A custom module instead of the built-in power-profiles-daemon one:
        # that module hardcodes click-to-cycle and ignores on-click, and we
        # want a wofi picker.
        "custom/power-profile" = {
          return-type = "json";
          interval = 5;
          exec = pkgs.writeShellScript "power-profile-status" ''
            p=$(powerprofilesctl get)
            case "$p" in
              performance) i="󰓅" ;;
              power-saver) i="󰾆" ;;
              *) i="󰾅" ;;
            esac
            printf '{"text":"%s","class":"%s","tooltip":"Power profile: %s"}\n' "$i" "$p" "$p"
          '';
          on-click = pkgs.writeShellScript "power-profile-menu" ''
            chosen=$(printf 'power-saver\nbalanced\nperformance\n' \
              | wofi --dmenu --insensitive --prompt 'Power profile')
            [ -n "$chosen" ] && powerprofilesctl set "$chosen"
          '';
        };

        # Theme switch. No interval: the only thing that changes the theme is
        # theme-mode, and applying a theme reloads waybar, so the module is
        # re-read exactly when it needs to be.
        "custom/theme" = {
          return-type = "json";
          exec = pkgs.writeShellScript "theme-status" ''
            name=$(theme-mode get)
            mode=$(theme-mode mode)
            case "$mode" in
              dark) i="󰖔" ;;
              *) i="󰖨" ;;
            esac
            printf '{"text":"%s","class":"%s","tooltip":"%s — click to switch mode, right-click to pick a theme"}\n' "$i" "$mode" "$name"
          '';
          on-click = "theme-mode toggle";
          on-click-right = "theme-mode menu";
        };

        # Every readout below is icon-only; the number it used to print lives
        # in the tooltip. Battery is the one that loses real information, so
        # its five icons are the coarse gauge and the exact figure is a hover
        # away.
        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon}";
          format-charging = "󰂄";
          format-plugged = "󰚥";
          format-icons = [ "󰁺" "󰁼" "󰁾" "󰂀" "󰁹" ];
          tooltip-format = "{capacity}% — {time}";
          # The sudo rule in hosts/otto/system allows exactly these two
          # framework_tool invocations without a password.
          on-click = pkgs.writeShellScript "charge-limit-menu" ''
            chosen=$(printf '80%% — battery health (default)\n100%% — full charge for travel\n' \
              | wofi --dmenu --insensitive --prompt 'Charge limit')
            case "$chosen" in
              80*) limit=80 ;;
              100*) limit=100 ;;
              *) exit 0 ;;
            esac
            sudo -n ${pkgs.framework-tool}/bin/framework_tool --charge-limit "$limit" \
              && notify-send "Battery" "Charge limit set to $limit%"
          '';
        };

        backlight = {
          format = "{icon}";
          format-icons = [ "󰃞" "󰃟" "󰃠" ];
          tooltip-format = "Brightness {percent}%";
          scroll-step = 5;
          on-scroll-up = "brightnessctl set +5%";
          on-scroll-down = "brightnessctl set 5%-";
        };

        bluetooth = {
          format = "󰂯";
          format-off = "󰂲";
          format-disabled = "󰂲";
          format-connected = "󰂱";
          tooltip-format = "Devices connected: {num_connections}";
          on-click = "rfkill unblock bluetooth; ghostty -e bluetui";
        };

        network = {
          format-wifi = "{icon}";
          format-icons = [ "󰤟" "󰤢" "󰤥" "󰤨" ];
          format-ethernet = "󰈀";
          format-disconnected = "󰤭";
          tooltip-format-wifi = "{essid} — {signalStrength}%";
          tooltip-format-ethernet = "{ipaddr}/{cidr}";
          on-click = "ghostty -e nmtui";
        };

        pulseaudio = {
          format = "{icon}";
          format-muted = "󰝟";
          format-icons = {
            default = [ "󰕿" "󰖀" "󰕾" ];
          };
          tooltip-format = "{desc} — {volume}%";
          on-click = "pavucontrol";
        };

        tray = {
          spacing = 8;
        };
      };
    };
    style = ''
      /* Colours come from the mode-switched palette; see profiles/home-manager/
         theme. The path is absolute because this file is a store symlink and a
         relative import would resolve next to it, in /nix/store. */
      @import url("file://${stateDir}/palette.css");

      /* Omarchy's bar is icons on a flat ground. The pill background, rounded
         corner and border every module used to carry are cleared here once
         rather than unset one at a time below. */
      * {
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 12px;
        min-height: 0;
        padding: 0;
        margin: 0;
        border: none;
        border-radius: 0;
        box-shadow: none;
        text-shadow: none;
      }

      window#waybar {
        background: @bg-elevated;
        color: @text;
      }

      tooltip {
        background: @bg-elevated;
        border: 1px solid @border-strong;
      }

      tooltip label {
        color: @text;
      }

      /* ── Workspaces ── */
      #workspaces {
        margin-left: 4px;
      }

      #workspaces button {
        padding: 0 7px;
        color: @text;
        background: transparent;
      }

      /* Occupancy, since every workspace but the focused one renders as a bare
         number: dim means nothing is open there. */
      #workspaces button.empty {
        color: @text-dim;
      }

      #workspaces button.active {
        color: @text-strong;
      }

      #workspaces button.urgent {
        color: @red;
      }

      #workspaces button:hover {
        color: @accent;
        background: transparent;
      }

      /* ── Clock ── */
      #clock {
        padding: 0 8px;
        color: @text-strong;
      }

      /* ── Status icons ──
         One colour for all of them. Colour is spent on state instead: an
         unreachable or muted device dims, a dying battery reddens. */
      #custom-theme,
      #backlight,
      #pulseaudio,
      #network,
      #bluetooth,
      #custom-power-profile,
      #battery,
      #tray {
        padding: 0 7px;
        color: @text;
        background: transparent;
      }

      #custom-theme:hover,
      #backlight:hover,
      #pulseaudio:hover,
      #network:hover,
      #bluetooth:hover,
      #custom-power-profile:hover,
      #battery:hover {
        color: @accent;
      }

      #pulseaudio.muted,
      #network.disconnected,
      #bluetooth.off,
      #bluetooth.disabled {
        color: @text-dim;
      }

      #battery.warning {
        color: @orange;
      }

      #battery.critical {
        color: @red;
      }

      #tray {
        padding: 0 8px 0 6px;
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
      }
    '';
  };
}
