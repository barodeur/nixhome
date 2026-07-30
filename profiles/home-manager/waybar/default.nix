{ pkgs, ... }:

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
        modules-right = [ "pulseaudio" "backlight" "network" "bluetooth" "cpu" "memory" "temperature" "custom/fan" "custom/power-profile" "battery" "tray" ];

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

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity:02}%";
          format-charging = "󰂄 {capacity:02}%";
          format-plugged = "󰚥 {capacity:02}%";
          format-icons = [ "󰁺" "󰁼" "󰁾" "󰂀" "󰁹" ];
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
      * {
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 13px;
        min-height: 0;
        padding: 0;
        margin: 0;
      }

      window#waybar {
        background: rgba(15, 15, 25, 0.85);
        border-radius: 12px;
        border: 1px solid rgba(51, 204, 255, 0.12);
        color: #c8d0e0;
      }

      tooltip {
        background: rgba(15, 15, 25, 0.95);
        border: 1px solid rgba(51, 204, 255, 0.25);
        border-radius: 8px;
      }

      tooltip label {
        color: #c8d0e0;
      }

      /* ── Workspaces ── */
      #workspaces {
        margin: 3px 6px;
      }

      #workspaces button {
        padding: 2px 10px;
        margin: 3px 2px;
        border-radius: 8px;
        color: rgba(200, 208, 224, 0.35);
        background: transparent;
        border: 1px solid transparent;
        transition: all 0.25s ease;
        min-width: 20px;
      }

      #workspaces button:hover {
        background: rgba(51, 204, 255, 0.1);
        color: #33ccff;
      }

      #workspaces button.active {
        background: linear-gradient(135deg, rgba(51, 204, 255, 0.25), rgba(0, 255, 153, 0.18));
        color: #ffffff;
        border: 1px solid rgba(51, 204, 255, 0.35);
      }

      #workspaces button.urgent {
        background: rgba(255, 100, 120, 0.25);
        color: #ff6478;
      }

      /* ── Clock ── */
      #clock {
        font-weight: 600;
        font-size: 14px;
        color: #e0e6f0;
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
      #temperature,
      #tray {
        padding: 4px 12px;
        margin: 3px 2px;
        border-radius: 8px;
        background: rgba(255, 255, 255, 0.04);
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
      #temperature:hover {
        background: rgba(51, 204, 255, 0.08);
      }

      /* ── Module colors ── */
      #cpu { color: #7aafff; }
      #memory { color: #c4a1f0; }
      #pulseaudio { color: #8edba6; }
      #backlight { color: #e0c880; }

      #pulseaudio.muted {
        color: rgba(200, 208, 224, 0.3);
      }

      #network { color: #33ccff; }
      #network.disconnected { color: rgba(200, 208, 224, 0.3); }

      #bluetooth { color: #7aafff; }
      #bluetooth.disabled { color: rgba(200, 208, 224, 0.3); }
      #bluetooth.off { color: rgba(200, 208, 224, 0.3); }
      #bluetooth.connected { color: #33ccff; }

      #custom-fan { color: #e0c880; }

      #temperature { color: #e0c880; }
      #temperature.warning { color: #f0b070; }
      #temperature.critical { color: #ff6478; }

      #custom-power-profile { color: #8edba6; }
      #custom-power-profile.performance { color: #ff6478; }
      #custom-power-profile.power-saver { color: #7aafff; }

      #battery { color: #8edba6; }
      #battery.warning { color: #f0b070; }
      #battery.critical { color: #ff6478; }
      #battery.charging { color: #8edba6; }

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
