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
        height = 38;
        margin-top = 6;
        margin-left = 8;
        margin-right = 8;
        spacing = 0;

        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "custom/theme" "pulseaudio" "backlight" "network" "bluetooth" "cpu" "memory" "temperature" "custom/fan" "custom/power-profile" "battery" "tray" ];

        "hyprland/workspaces" = {
          format = "{name}";
          on-click = "activate";
          sort-by-number = true;
        };

        clock = {
          format = "󰥔 {:%H:%M}";
          format-alt = "󰃭 {:%A, %B %d}";
          tooltip-format = "<tt>{calendar}</tt>";
        };

        cpu = {
          format = "󰻠 {usage:02}%";
          interval = 2;
        };

        memory = {
          format = "󰍛 {percentage:02}%";
          tooltip-format = "{used:0.1f}G / {total:0.1f}G used";
          interval = 2;
        };

        # Fan RPM from the EC via framework-laptop-kmod's cros_ec hwmon; looked
        # up by name because hwmon indices shift between boots.
        "custom/fan" = {
          exec = "for h in /sys/class/hwmon/hwmon*; do [ \"$(cat $h/name)\" = cros_ec ] && cat $h/fan1_input && break; done";
          interval = 5;
          format = "󰈐 {}rpm";
          tooltip = false;
        };

        # CPU die temperature (k10temp Tctl), addressed by PCI device path
        # because hwmon indices shift between boots.
        temperature = {
          hwmon-path-abs = "/sys/devices/pci0000:00/0000:00:18.3/hwmon";
          input-filename = "temp1_input";
          interval = 5;
          warning-threshold = 80;
          critical-threshold = 95;
          format = "󰔏 {temperatureC}°C";
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

        # Light/dark switch. No interval: the only thing that changes the mode
        # is theme-mode, and applying a mode reloads waybar, so the module is
        # re-read exactly when it needs to be.
        "custom/theme" = {
          return-type = "json";
          exec = pkgs.writeShellScript "theme-status" ''
            m=$(theme-mode get)
            case "$m" in
              dark) i="󰖔" ;;
              *) i="󰖨" ;;
            esac
            printf '{"text":"%s","class":"%s","tooltip":"%s mode — click to switch"}\n' "$i" "$m" "$m"
          '';
          on-click = "theme-mode toggle";
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity:02}%";
          format-charging = "󰂄 {capacity:02}%";
          format-plugged = "󰚥 {capacity:02}%";
          format-icons = [ "󰁺" "󰁼" "󰁾" "󰂀" "󰁹" ];
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
          format = "{icon} {percent:02}%";
          format-icons = [ "󰃞" "󰃟" "󰃠" ];
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
          format-wifi = "󰤨 {signalStrength:02}%";
          format-ethernet = "󰈀 {ipaddr}/{cidr}";
          format-disconnected = "󰤭 Off";
          tooltip-format-wifi = "{essid} ({signalStrength}%)";
          on-click = "ghostty -e nmtui";
        };

        pulseaudio = {
          format = "{icon} {volume:02}%";
          format-muted = "󰝟 Muted";
          format-icons = {
            default = [ "󰕿" "󰖀" "󰕾" ];
          };
          on-click = "pavucontrol";
        };

        tray = {
          spacing = 10;
        };
      };
    };
    style = ''
      /* Colours come from the mode-switched palette; see profiles/home-manager/
         theme. The path is absolute because this file is a store symlink and a
         relative import would resolve next to it, in /nix/store. */
      @import url("file://${stateDir}/palette.css");

      * {
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 13px;
        min-height: 0;
        padding: 0;
        margin: 0;
      }

      window#waybar {
        background: @bg;
        border-radius: 12px;
        border: 1px solid @border;
        color: @text;
      }

      tooltip {
        background: @bg-elevated;
        border: 1px solid @border-strong;
        border-radius: 8px;
      }

      tooltip label {
        color: @text;
      }

      /* ── Workspaces ── */
      #workspaces {
        margin: 3px 6px;
      }

      #workspaces button {
        padding: 2px 10px;
        margin: 3px 2px;
        border-radius: 8px;
        color: @text-muted;
        background: transparent;
        border: 1px solid transparent;
        transition: all 0.25s ease;
        min-width: 20px;
      }

      #workspaces button:hover {
        background: @accent-hover;
        color: @accent;
      }

      #workspaces button.active {
        background: linear-gradient(135deg, @sel-from, @sel-to);
        color: @sel-text;
        border: 1px solid @sel-border;
      }

      #workspaces button.urgent {
        background: @urgent-bg;
        color: @red;
      }

      /* ── Clock ── */
      #clock {
        font-weight: 600;
        font-size: 14px;
        color: @text-strong;
        padding: 4px 14px;
        margin: 3px 2px;
      }

      /* ── Common module styling ── */
      #cpu,
      #memory,
      #battery,
      #network,
      #bluetooth,
      #backlight,
      #pulseaudio,
      #custom-power-profile,
      #custom-fan,
      #custom-theme,
      #temperature,
      #tray {
        padding: 4px 12px;
        margin: 3px 2px;
        border-radius: 8px;
        background: @surface;
        transition: all 0.25s ease;
      }

      #cpu:hover,
      #memory:hover,
      #battery:hover,
      #network:hover,
      #bluetooth:hover,
      #backlight:hover,
      #pulseaudio:hover,
      #custom-power-profile:hover,
      #custom-fan:hover,
      #custom-theme:hover,
      #temperature:hover {
        background: @surface-hover;
      }

      /* ── Module colors ── */
      #cpu { color: @blue; }
      #memory { color: @purple; }
      #pulseaudio { color: @green; }
      #backlight { color: @yellow; }

      #pulseaudio.muted {
        color: @text-dim;
      }

      #network { color: @accent; }
      #network.disconnected { color: @text-dim; }

      #bluetooth { color: @blue; }
      #bluetooth.disabled { color: @text-dim; }
      #bluetooth.off { color: @text-dim; }
      #bluetooth.connected { color: @accent; }

      #custom-fan { color: @yellow; }

      #custom-theme.light { color: @yellow; }
      #custom-theme.dark { color: @blue; }

      #temperature { color: @yellow; }
      #temperature.warning { color: @orange; }
      #temperature.critical { color: @red; }

      #custom-power-profile { color: @green; }
      #custom-power-profile.performance { color: @red; }
      #custom-power-profile.power-saver { color: @blue; }

      #battery { color: @green; }
      #battery.warning { color: @orange; }
      #battery.critical { color: @red; }
      #battery.charging { color: @green; }

      #tray {
        padding: 4px 8px;
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
